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
crudini --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.31.136
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron  True
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver
crudini --set  /etc/nova/nova.conf vnc enabled  True
crudini --set  /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address  "\$my_ip"
crudini --set  /etc/nova/nova.conf vnc novncproxy_base_url  http://192.168.31.135:6080/vnc_auto.html
crudini --set  /etc/nova/nova.conf glance api_servers  http://controller:9292
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set  /etc/nova/nova.conf libvirt virt_type kvm

#支持修改帐号，key
#crudini --set  /etc/nova/nova.conf libvirt inject_password True
#crudini --set  /etc/nova/nova.conf libvirt inject_key True

service nova-compute restart





