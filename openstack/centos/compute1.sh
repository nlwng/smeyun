systemctl stop firewalld.service
systemctl disable firewalld.service
#!/bin/bash
#check file bak
[ ! -f /etc/yum.repos.d/CentOS-Base.repo.bak ] && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
[ ! -f /etc/chrony.conf ] && cp /etc/chrony.conf /etc/chrony.conf.bak

#sys set lan yum
#wget -O /etc/yum.repos.d/CentOS-Base.repo  http://192.168.2.88:911/centos7/CentOS-Base.repo
cp -rvf /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum clean all
yum makecache
#yum repolist

#install crudini
yum -y install epel-release
yum -qy install crudini

#ntp
yum -qy install chrony
echo  "server controller iburst" >> /etc/chrony.conf 
systemctl enable chronyd.service
systemctl start chronyd.service

#验证ntp
chronyc sources

yum -qy install centos-release-openstack-mitaka
#更新系统
yum -y upgrade

#安装OpenStack客户端
#yum -qy install python-openstackclient
#RHEL和CentOS默认启用SELinux。安装OpenStack SELinux软件包自动管理OpenStack服务安全政策：
yum -qy install openstack-selinux

#install nova
yum -qy install openstack-nova-compute

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
crudini --set  /etc/nova/nova.conf DEFAULT my_ip  192.168.246.132
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron  True
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver
crudini --set  /etc/nova/nova.conf vnc enabled  True
crudini --set  /etc/nova/nova.conf vnc vncserver_listen  0.0.0.0
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address  "\$my_ip"
crudini --set  /etc/nova/nova.conf vnc novncproxy_base_url  http://192.168.246.131:6080/vnc_auto.html
crudini --set  /etc/nova/nova.conf glance api_servers  http://controller:9292
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set  /etc/nova/nova.conf libvirt virt_type kvm

systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service


#install neutron
yum -qy install openstack-neutron-linuxbridge ebtables ipset

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
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp


#1: Provider networks
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:enp1s0
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan false
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver  neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

crudini --set /etc/nova/nova.conf neutron url http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type password
crudini --set /etc/nova/nova.conf neutron project_domain_name default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name RegionOne
crudini --set /etc/nova/nova.conf neutron project_name service
crudini --set /etc/nova/nova.conf neutron username neutron
crudini --set /etc/nova/nova.conf neutron password pass

systemctl restart openstack-nova-compute.service
systemctl enable neutron-linuxbridge-agent.service
systemctl start neutron-linuxbridge-agent.service


#2: Self-service networks
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:enp1s0
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.246.132
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

systemctl restart openstack-nova-compute.service
systemctl enable neutron-linuxbridge-agent.service
systemctl start neutron-linuxbridge-agent.service




#类似地，如果您的计算节点在操作系统磁盘上使用了 LVM，您也必需修改这些节点上 /etc/lvm/lvm.conf 文件中的过滤器，
#将操作系统磁盘包含到过滤器中。例如，如果``/dev/sda`` 设备包含操作系统：
#/etc/lvm/lvm.conf
filter = [ "a/sda/", "r/.*/"]