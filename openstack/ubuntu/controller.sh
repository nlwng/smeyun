#!/bin/bash
CONTRO_IP='192.168.246.148'
PASSWD='pass'

apt-get -qy install crudini chrony

cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
echo  "server time.windows.com iburst" >> /etc/chrony/chrony.conf
/etc/init.d/chrony restart

#启用OpenStack库
apt-get -qy install software-properties-common
add-apt-repository cloud-archive:mitaka

#update
apt-get -qy update && apt-get -qy dist-upgrade
#安装 OpenStack 客户端：
apt-get -qy install python-openstackclient

#install Mysql
#/etc/mysql/my.cnf中#!includedir /etc/mysql/mariadb.conf.d/注释这行
apt-get -qy install mariadb-server python-pymysql

#vim /etc/mysql/conf.d/openstack.cnf
[mysqld]
bind-address = 192.168.31.135
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8

/etc/init.d/mysql restart
mysql_secure_installation

#mongodb install
apt-get -qy install mongodb-server mongodb-clients python-pymongo

crudini --set /etc/mongodb.conf '' bind_ip 192.168.31.135
crudini --set /etc/mongodb.conf '' smallfiles true

/etc/init.d/mongodb stop
rm /var/lib/mongodb/journal/prealloc.*
/etc/init.d/mongodb start

#消息队列
apt-get -qy install rabbitmq-server
rabbitmqctl add_user openstack pass
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

#Install Memcached
apt-get install memcached python-memcache

##crudini --set /etc/memcached.conf '' -l 192.168.31.135
/etc/init.d/memcached restart

#install keystone
mysql -uroot -ppass <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

#安装后禁止keystone 服务自动启动：
echo "manual" > /etc/init/keystone.override
apt-get -qy install keystone apache2 libapache2-mod-wsgi

#定义初始管理令牌的值：
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token pass
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:pass@controller/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet

#初始化身份认证服务的数据库：
su -s /bin/sh -c "keystone-manage db_sync" keystone
#初始化Fernet keys：
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone


#配置 Apache HTTP 服务器
crudini --set /etc/apache2/apache2.conf '' ServerName controller

vim /etc/apache2/sites-available/wsgi-keystone.conf
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>


ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
service apache2 restart
rm -f /var/lib/keystone/keystone.db

----------------------------------------
export OS_TOKEN=pass
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
-----------------------------------------

#Create the service entity and API endpoints
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://controller:5000/v3
openstack endpoint create --region RegionOne identity internal http://controller:5000/v3
openstack endpoint create --region RegionOne identity admin http://controller:35357/v3

#Create a domain, projects, users, and roles
openstack domain create --description "Default Domain" default
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password-prompt admin
openstack role create admin
openstack role add --project admin --user admin admin

openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password-prompt demo
openstack role create user
openstack role add --project demo --user demo user

#因为安全性的原因，关闭临时认证令牌机制：
#编辑 /etc/keystone/keystone-paste.ini 文件，从``[pipeline:public_api]``，
#[pipeline:admin_api]``和``[pipeline:api_v3]``部分删除``admin_token_auth 。

#Verify operation
unset OS_TOKEN OS_URL

#作为 admin 用户，请求认证令牌：
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue

#作为``demo`` 用户，请求认证令牌：
openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo token issue

-------------------------------------------- admin-openrc
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
----------------------------------------

-------------------------------------------- demo-openrc
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
----------------------------------------
source admin-openrc
#请求认证令牌:
openstack token issue

#glance install
mysql -uroot -ppass <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

apt-get -qy install glance
crudini --set /etc/glance/glance-api.conf database connection  mysql+pymysql://glance:pass@controller/glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name default
crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name default
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken password pass
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store default_store file
#配置本地文件系统存储和镜像文件位置：
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

crudini --set /etc/glance/glance-registry.conf database connection  mysql+pymysql://glance:pass@controller/glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name default
crudini --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name default
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken password pass
crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone

su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
service glance-api restart

wget http://images.trystack.cn/cirros/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
wget http://images.trystack.cn/centos/CentOS-6-x86_64-GenericCloud-20141129_01.qcow2
openstack image create "centos6" --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2 --disk-format qcow2 --container-format bare --public

#install nova
mysql -uroot -ppass <<EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

openstack user create --domain default --password-prompt nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s

apt-get -qy install nova-api nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler

crudini --set  /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
crudini --set  /etc/nova/nova.conf api_database connection mysql+pymysql://nova:pass@controller/nova_api
crudini --set  /etc/nova/nova.conf database connection  mysql+pymysql://nova:pass@controller/nova
crudini --set  /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host controller
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password pass
crudini --set  /etc/nova/nova.conf DEFAULT auth_strategy keystone
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_url http://controller:35357
crudini --set  /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
crudini --set  /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set  /etc/nova/nova.conf keystone_authtoken project_domain_name default
crudini --set  /etc/nova/nova.conf keystone_authtoken user_domain_name default
crudini --set  /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set  /etc/nova/nova.conf keystone_authtoken username nova
crudini --set  /etc/nova/nova.conf keystone_authtoken password pass
crudini --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.31.135
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set  /etc/nova/nova.conf vnc vncserver_listen "\$my_ip"
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address "\$my_ip"
crudini --set  /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

for i in {nova-api,nova-consoleauth,nova-scheduler,nova-conductor,nova-novncproxy};do service $i restart;done

#install dashboard
apt-get -qy install openstack-dashboard
#Ubuntu 安裝 openstack-dashboard 時，會自動安裝` ``ubuntu-theme``` 樣板套件，若發生問題或者不需要，可以直接刪除該套件。
apt-get remove --purge openstack-dashboard-ubuntu-theme
cd /usr/share/openstack-dashboard
./manage.py collectstatic
./manage.py compress

vim /etc/openstack-dashboard/local_settings.py
#在 controller 节点上配置仪表盘以使用 OpenStack 服务：
OPENSTACK_HOST = "controller"
#允许所有主机访问仪表板：
ALLOWED_HOSTS = ['*', ]

#配置 memcached 会话存储服务：
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'controller:11211',
    }
}

OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
#启用对域的支持
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = true
#配置API版本:
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
#通过仪表盘创建用户时的默认域配置为 default :
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

#如果您选择网络参数1，禁用支持3层网络服务：
OPENSTACK_NEUTRON_NETWORK = {
    ...
    'enable_router': False,
    'enable_quotas': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
}

TIME_ZONE = "Asia/Shanghai"
service apache2 reload


#network
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

#安装控制节点
#通讯网卡配置
auto eth1
iface eth1 inet manual
up ip link set dev $IFACE up
down ip link set dev $IFACE down

apt-get -qy install neutron-server neutron-plugin-ml2

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

-----------------------------
#nova 为计算服务配置网络服务
-----------------------------
crudini --set /etc/nova/nova.conf neutron url  http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type  password
crudini --set /etc/nova/nova.conf neutron project_domain_name  default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  pass
crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  True
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret  pass


su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

for i in {nova-api,neutron-server,};do service $i restart;done
