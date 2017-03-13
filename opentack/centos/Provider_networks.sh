#install neutron
mysql -uroot -p$PASSWD <<EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'pass';

openstack user create --domain default --password-prompt neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696

#1: Provider networks
yum -qy install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables

crudini --set /etc/neutron/neutron.conf database connection  mysql+pymysql://neutron:pass@controller/neutron
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin  ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend  rabbit
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
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
#ml2
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  flat,vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
#linuxbridge
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  provider:enp4s0
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan  False
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group  True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

#dhcp
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata true

#nova
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

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

systemctl restart openstack-nova-api.service
systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service

安装完成以后
------------------------
admin-openrc

neutron net-create --shared --provider:physical_network provider --provider:network_type flat provider
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:enp4s0

neutron subnet-create --name provider \
  --allocation-pool start=192.168.246.100,end=192.168.246.150 \
  --dns-nameserver 114.114.114.114 --gateway 192.168.246.1 \
  provider 192.168.246.0/24

