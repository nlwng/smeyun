#--------------------------------------------------------------------------------------------------------

sed -i s/"#net.ipv4.conf.default.rp_filter=1"/"net.ipv4.conf.default.rp_filter=0"/g /etc/sysctl.conf
sed -i s/"#net.ipv4.conf.all.rp_filter=1"/"net.ipv4.conf.all.rp_filter=0"/g /etc/sysctl.conf
sysctl -p



#安装软件包
apt-get install neutron-plugin-openvswitch-agent -y

#--------------------------------------------------------------------------------------------------------

crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:pass@controller/neutron

crudini --set /etc/neutron/neutron.conf DEFAULT verbose True
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True

crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password pass

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password pass
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
#--------------------------------------------------------------------------------------------------------

crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip $compute1_ip

crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types gre
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing True

crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_security_group True
#--------------------------------------------------------------------------------------------------------

crudini --set /etc/nova/nova.conf neutron url http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type password
crudini --set /etc/nova/nova.conf neutron project_domain_name default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name RegionOne
crudini --set /etc/nova/nova.conf neutron project_name service
crudini --set /etc/nova/nova.conf neutron username neutron
crudini --set /etc/nova/nova.conf neutron password pass

#重启服务
service openvswitch-switch restart
service neutron-openvswitch-agent restart
service nova-compute restart
