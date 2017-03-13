二.网络节点部署
2.1.允许转发
/etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

sysctl -p

#install neutron
mysql -uroot -ppass <<EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

openstack user create --domain default --password-prompt neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696


#2: Self-service networks
apt-get -qy install neutron-server neutron-plugin-ml2 \
  neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent \
  neutron-metadata-agent

crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:pass@controller/neutron
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password pass
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password pass
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
crudini --set /etc/neutron/neutron.conf nova auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf nova auth_type password
crudini --set /etc/neutron/neutron.conf nova project_domain_name default
crudini --set /etc/neutron/neutron.conf nova user_domain_name default
crudini --set /etc/neutron/neutron.conf nova region_name RegionOne
crudini --set /etc/neutron/neutron.conf nova project_name service
crudini --set /etc/neutron/neutron.conf nova username nova
crudini --set /etc/neutron/neutron.conf nova password pass

#ml2
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan,gre
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset true


#linuxbridge
#将公共虚拟网络和公共物理网络接口对应起来
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:eth1
#替换为处理覆盖网络的底层物理网络接口的IP地址
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip  192.168.31.135
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population  True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
#阻止arp欺骗
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini prevent_arp_spoofing true

#l3配置Linuxbridge接口驱动和外部网络网桥
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver  neutron.agent.linux.interface.BridgeInterfaceDriver
#选项故意缺乏一个值，以便在一个代理上启用多个外部网络。
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge 
#dhcp
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True

#metadata
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret pass

-----------------------------
#nova 为计算节点配置网络服务
-----------------------------
crudini --set /etc/nova/nova.conf neutron url  http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type  password
crudini --set /etc/nova/nova.conf neutron project_domain_name  default
crudini --set /etc/nova/nova.conf neutron user_domain_name =default
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  pass
crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  True
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret  pass

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

service nova-api restart

service neutron-server restart
service neutron-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

service neutron-l3-agent restart

for i in {nova-api,neutron-server,neutron-linuxbridge-agent,neutron-dhcp-agent,neutron-metadata-agent,neutron-l3-agent};do service $i restart;done
----------------------------------------------------------------------------------------------------------
#计算节点安装网络
apt-get -qy install neutron-linuxbridge-agent

crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password pass
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken roject_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password pass

#2: Self-service networks 将公共虚拟网络和公共物理网络接口对应起来
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:eth1
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.31.136
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

crudini --set /etc/nova/nova.conf neutron url http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type password
crudini --set /etc/nova/nova.conf neutron project_domain_name default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name RegionOne
crudini --set /etc/nova/nova.conf neutron project_name service
crudini --set /etc/nova/nova.conf neutron username neutron
crudini --set /etc/nova/nova.conf neutron password pass

service nova-compute restart
service neutron-linuxbridge-agent restart

----------------------------------------------------------------------------------------------------------
#创建网络：创建self-service network之前必须创建Provider network
#创建Provider网络,
source admin-openrc
neutron net-create --shared --provider:physical_network provider \
  --provider:network_type flat provider

#创建子网
neutron subnet-create --name provider \
  --allocation-pool start=192.168.2.10,end=192.168.2.50 \
  --dns-nameserver 114.114.114.114 --gateway 192.168.2.1 \
  provider 192.168.2.0/24

neutron net-create ex-net

#在网络上创建一个子网：
neutron subnet-create --name ex-net --dns-nameserver 114.114.114.114 \
	--gateway 10.10.30.1 ex-net 10.10.30.0/24

# Self-service 网络连接到Provider网络使用一个虚拟路由器通常是双向NAT。
#每个路由器包含一个或多个self-service网络的接口和一个provider网络的网关。
#这个provider 网络必须包含 router:external选项才能是self-service路由器使用它连接到外部网络如Internet。
#admin或其他特定权限用户在网络创建或添加过程中必须包含这个选项。
neutron net-update provider --router:external
neutron router-create router
neutron router-interface-add router ex-net
neutron router-gateway-set router provider

#验证操作
ip netns
neutron router-port-list router
#手动增加防火墙22、icmp端口
ping -c 4 192.168.2.12



