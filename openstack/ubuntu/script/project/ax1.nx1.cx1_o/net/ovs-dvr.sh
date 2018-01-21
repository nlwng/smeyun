#Controller
crudini --set /etc/neutron/neutron.conf DEFAULT router_distributed True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "openvswitch,l2population"

for i in {nova-api,neutron-server};do service $i restart;done

#Network
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "openvswitch,l2population"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 agent l2_population True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 agent enable_distributed_routing True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 agent arp_responder True
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode dvr_snat

Controller节点上重启：
for i in {nova-api,};do service $i restart;done
Network节点上重启：
for i in {openvswitch-switch,neutron-openvswitch-agent,neutron-l3-agent,neutron-dhcp-agent,neutron-metadata-agent};do service $i restart;done


#Computer
crudini --set /etc/sysctl.conf '' net.ipv4.ip_forward 1
crudini --set /etc/sysctl.conf '' net.ipv4.conf.default.rp_filter 0
crudini --set /etc/sysctl.conf '' net.ipv4.conf.all.rp_filter 0
crudini --set /etc/sysctl.conf '' net.bridge.bridge-nf-call-iptables 1
crudini --set /etc/sysctl.conf '' net.bridge.bridge-nf-call-ip6tables 1

sysctl -p

sudo apt-get install -y neutron-l3-agent  neutron-metadata-agent
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "openvswitch,l2population"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs local_ip TUNNEL_INTERFACE_IP_ADDRESS
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings "external:br-ex"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent l2_population True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent tunnel_types gre
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent enable_distributed_routing True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent arp_responder True

crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge
crudini --set /etc/neutron/l3_agent.ini DEFAULT router_delete_namespaces True
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode dvr

crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_uri http://controller:5000
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_url http://controller:35357
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_region RegionOne
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_plugin password
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_domain_id default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT user_domain_id default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_name service
crudini --set /etc/neutron/metadata_agent.ini DEFAULT username neutron
crudini --set /etc/neutron/metadata_agent.ini DEFAULT password pass
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret pass

service openvswitch-switch restart

增加外部網路橋接：
sudo ovs-vsctl add-br br-ex
增加連接到實體外部網路介面的外部橋接埠口：
sudo ovs-vsctl add-port br-ex eth0

根據網路介面的驅動，可能需要禁用generic receive offload (GRO)來實現Instance和外部網路之間的合適的吞吐量。測試環境時，在外部網路介面上暫時關閉GRO：
ethtool -K INTERFACE_NAME gro off

for i in {nova-compute,neutron-openvswitch-agent,neutron-metadata-agent,neutron-l3-agent};do service $i restart;done



@neil
##Controller节点
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT router_distributed True
crudini --set /etc/neutron/neutron.conf DEFAULT l3_ha True
crudini --set /etc/neutron/neutron.conf DEFAULT l3_ha_net_cidr 169.254.192.0/18
crudini --set /etc/neutron/neutron.conf DEFAULT max_l3_agents_per_router 3
crudini --set /etc/neutron/neutron.conf DEFAULT max_l3_agents_per_router 2

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini type_drivers flat,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini tenant_network_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini mechanism_drivers openvswitch,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini extension_drivers port_security

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks external
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:100

##Controller节点 or Network
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs local_ip 10.10.10.11
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings external:br-ex
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent enable_distributed_routing True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent tunnel_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent l2_population True

crudini --set /etc/neutron/l3_agent.ini DEFAULT ha_vrrp_auth_password password
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver openvswitch
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge ''
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode dvr_snat

Controller节点上重启：
for i in {nova-api,openvswitch-switch,neutron-openvswitch-agent,neutron-l3-agent,neutron-dhcp-agent,neutron-metadata-agent};do service $i restart;done

## 计算节点
apt-get install neutron-l3-agent  neutron-metadata-agent neutron-plugin-ml2

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs local_ip 10.10.10.31
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings external:br-ex
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent enable_distributed_routing True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent tunnel_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini agent l2_population True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver openvswitch
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge ''
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode dvr

for i in {nova-compute,neutron-openvswitch-agent,neutron-metadata-agent,neutron-l3-agent};do service $i restart;done
