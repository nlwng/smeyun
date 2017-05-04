#!/bin/bash
CONTRO_IP='192.168.246.147'
PASSWD='pass'

#确定您的计算节点是否支持虚拟机的硬件加速。
egrep -c '(vmx|svm)' /proc/cpuinfo

apt-get -qy install crudini
apt-get -qy install chrony

cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
echo  "server controller iburst" >> /etc/chrony/chrony.conf
/etc/init.d/chrony restart

#启用OpenStack库
apt-get install software-properties-common
add-apt-repository cloud-archive:mitakaS

#update
apt-get update && apt-get dist-upgrade
#安装 OpenStack 客户端：
apt-get install python-openstackclient

#install nova
apt-get -qy install nova-compute

crudini --set  /etc/nova/nova.conf DEFAULT rpc_backend  rabbit
crudini --set  /etc/nova/nova.conf DEFAULT auth_strategy  keystone
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host  controller
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid  openstack
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password  pass
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_uri  http://controller:5000
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_url  http://controller:35357
crudini --set  /etc/nova/nova.conf keystone_authtoken memcached_servers  controller:11211
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_type  password
crudini --set  /etc/nova/nova.conf keystone_authtoken project_domain_name  default
crudini --set  /etc/nova/nova.conf keystone_authtoken user_domain_name  default
crudini --set  /etc/nova/nova.conf keystone_authtoken project_name  service
crudini --set  /etc/nova/nova.conf keystone_authtoken sername  nova
crudini --set  /etc/nova/nova.conf keystone_authtoken password  pass
crudini --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.1.90
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron  True
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver
crudini --set  /etc/nova/nova.conf vnc enabled  True
crudini --set  /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address  "\$my_ip"
crudini --set  /etc/nova/nova.conf vnc novncproxy_base_url  http://10.23.127.21:6080/vnc_auto.html
crudini --set  /etc/nova/nova.conf glance api_servers  http://controller:9292
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set  /etc/nova/nova.conf libvirt virt_type kvm

#支持修改帐号，key
#crudini --set  /etc/nova/nova.conf libvirt inject_password True
#crudini --set  /etc/nova/nova.conf libvirt inject_key True

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
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.90
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
