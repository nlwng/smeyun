#设置软件源
mv /etc/apt/sources.list /etc/apt/sources.list.bak
echo "deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb [arch=amd64] http://10.0.0.1:1888/ubuntu trusty-updates/mitaka main">/etc/apt/sources.list

apt-get update

apt-get install ubuntu-cloud-keyring crudini lrzsz -y  #此处软件园解决，安装基本依赖工具

apt-get update
#OpenStack包
apt-get install software-properties-common -y
apt-get update && apt-get dist-upgrade
apt-get install python-openstackclient -y
#------------------------------------------------------------------

#配置NTP服务
apt-get install chrony -y

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


service chrony restart

chronyc sources


#------------------------------------------------------------------
#安装软件包
ip="10.0.0.31"
apt-get install crudini -y
apt-get install nova-compute -y

#配置文件
crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password pass
crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password pass
crudini --set /etc/nova/nova.conf DEFAULT my_ip $ip
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf vnc enabled True
crudini --set /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address $ip
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://controller:6080/vnc_auto.html
crudini --set /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path  /var/lib/nova/tmp
crudini --del /etc/nova/nova.conf DEFAULT logdir
crudini --del /etc/nova/nova.conf cinder os_region_name RegionOne

#启动实例调整大小
crudini --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host True
crudini --set /etc/nova/nova.conf DEFAULT scheduler_default_filters AllHostsFilter

#重启服务
service nova-compute restart
