#--------------------------------------------------------------------------------------------------------

sed -i s/"#net.ipv4.conf.default.rp_filter=1"/"net.ipv4.conf.default.rp_filter=0"/g /etc/sysctl.conf
sed -i s/"#net.ipv4.conf.all.rp_filter=1"/"net.ipv4.conf.all.rp_filter=0"/g /etc/sysctl.conf
sysctl -p



  #安装软件包
apt-get install neutron-server neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent -y

#-----------------------------------------------------------------------------------------------------------

crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:pass@controller/neutron

crudini --set /etc/neutron/neutron.conf DEFAULT verbose True
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

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
#-----------------------------------------------------------------------------------------------------

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan,gre
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types gre
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers openvswitch,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks external

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre tunnel_id_ranges 1:1000

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
#--------------------------------------------------------------------------------------------------------
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip $net_ip
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings external:br-ex

crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types gre
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing True
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup enable_security_group True

#--------------------------------------------------------------------------------------------------------

crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge 
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True 

#--------------------------------------------------------------------------------------------------------

crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT verbose True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dnsmasq_config_file /etc/neutron/dnsmasq-neutron.conf

echo 'dhcp-option-force=26,1454' | tee /etc/neutron/dnsmasq-neutron.conf

#--------------------------------------------------------------------------------------------------------
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret pass

#创建网桥
ovs-vsctl add-br br-ex

ovs-vsctl add-port br-ex $interface

#重启服务
service openvswitch-switch restart
service neutron-openvswitch-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-l3-agent restart
