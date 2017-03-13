yum -qy --disablerepo=\*   --enablerepo=CentOS7-Localsource install lib*
yum install -qy wget gcc gcc-c++ gcc-g77 autoconf automake zlib* fiex* libxml* ncurses* libmcrypt* libtool-ltdl-devel* make cmake openssl* pcre* lrzsz

systemctl stop firewalld.service
systemctl disable firewalld.service
#!/bin/bash
CONTRO_IP='192.168.246.131'
PASSWD='pass'

#check file bak
[ ! -f /etc/yum.repos.d/CentOS-Base.repo.bak ] && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
[ ! -f /etc/chrony.conf ] && cp /etc/chrony.conf /etc/chrony.conf.bak

#sys set lan yum
#wget -O /etc/yum.repos.d/CentOS-Base.repo  http://192.168.2.88:911/centos7/CentOS-Base.repo
cp -rvf /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum clean all
yum makecache

#yum clean all
#yum repolist
#yum makecache

#install crudini
yum -y install epel-release
yum -qy install crudini

#ntp
yum -qy install chrony
echo  "server NTP_SERVER iburst" >> /etc/chrony.conf 
echo  "allow 192.168.246.0/24" >> /etc/chrony.conf 
systemctl enable chronyd.service
systemctl start chronyd.service

#验证ntp
chronyc sources

#yum -qy install centos-release-openstack-mitaka
#更新系统
yum install https://rdoproject.org/repos/rdo-release.rpm
yum -y upgrade

#安装OpenStack客户端
yum -qy install python-openstackclient
#RHEL和CentOS默认启用SELinux。安装OpenStack SELinux软件包自动管理OpenStack服务安全政策：
yum -qy install openstack-selinux


#mysql install
yum -qy install mariadb mariadb-server python2-PyMySQL
[mysqld]
bind-address = 192.168.246.150
default-storage-engine = innodb
innodb_file_per_table
max_connections = 1024
collation-server = utf8_general_ci
character-set-server = utf8
------------------------------------

crudini --set  /etc/my.cnf.d/openstack.cnf mysqld bind-address  192.168.246.131
crudini --set  /etc/my.cnf.d/openstack.cnf mysqld default-storage-engine  innodb
crudini --set  /etc/my.cnf.d/openstack.cnf mysqld innodb_file_per_table
crudini --set  /etc/my.cnf.d/openstack.cnf mysqld max_connections  1024
crudini --set  /etc/my.cnf.d/openstack.cnf mysqld collation-server  utf8_general_ci
crudini --set  /etc/my.cnf.d/openstack.cnf mysqld character-set-server  utf8

systemctl enable mariadb.service
systemctl start mariadb.service
mysql_secure_installation

#mongodb install
yum -qy install mongodb-server mongodb
echo "bind_ip = 192.168.246.131" >> /etc/mongod.conf
echo "smallfiles = true" >> /etc/mongod.conf
systemctl enable mongod.service
systemctl start mongod.service

#rabbitmq install
yum -qy install rabbitmq-server
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

rabbitmqctl add_user openstack pass
#rabbitmqctl set_user_tags openstack administrator
#rabbitmqctl change_password openstack pass
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
查看用户：
# rabbitmqctl list_users

#memcached  install
yum -qy install memcached python-memcached
systemctl enable memcached.service
systemctl start memcached.service


#install keystone
mysql -uroot -p$PASSWD <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

yum -qy install openstack-keystone httpd mod_wsgi
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token pass
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:pass@controller/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

echo "ServerName controller" >> /etc/httpd/conf/httpd.conf

echo "Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

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
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>" >> /etc/httpd/conf.d/wsgi-keystone.conf

systemctl enable httpd.service
systemctl start httpd.service

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

Edit the /etc/keystone/keystone-paste.ini file and remove admin_token_auth from the [pipeline:public_api], 
[pipeline:admin_api], and [pipeline:api_v3] sections.

#Verify operation 
unset OS_TOKEN OS_URL

openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue

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

#glance install
mysql -uroot -p$PASSWD <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'pass';

openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

yum -qy install openstack-glance
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
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl start openstack-glance-api.service openstack-glance-registry.service

wget http://images.trystack.cn/cirros/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
wget http://images.trystack.cn/centos/CentOS-6-x86_64-GenericCloud-20141129_01.qcow2
openstack image create "centos6" --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2 --disk-format qcow2 --container-format bare --public


#install nova
mysql -uroot -p$PASSWD <<EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'pass';

openstack user create --domain default --password-prompt nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s

yum -qy install openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler

crudini --set  /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
crudini --set  /etc/nova/nova.conf api_database connection mysql+pymysql://nova:pass@controller/nova_api
crudini --set  /etc/nova/nova.conf database connection  mysql+pymysql://nova:pass@controller/nova
crudini --set  /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host  controller
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid  openstack
crudini --set  /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password  pass
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
crudini --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.246.131
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set  /etc/nova/nova.conf vnc vncserver_listen 192.168.246.131
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address 192.168.246.131
crudini --set  /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service


#install dashboard
yum -qy install openstack-dashboard

vim /etc/openstack-dashboard/local_settings
"OPENSTACK_HOST = "controller"" 
ALLOWED_HOSTS = ['*', ]

SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'controller:11211',
    }
}

OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
#启用对域的支持
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
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
systemctl restart httpd.service memcached.service


#cindor
#配置控制节点块设备存储
mysql -u root -p
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'pass';

source admin-openrc
openstack user create --domain default --password-prompt cinder
openstack role add --project service --user cinder admin

#创建 cinder 和 cinderv2 服务实体：
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s

yum install openstack-cinder

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:pass@controller/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password pass
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password pass
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.131
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

su -s /bin/sh -c "cinder-manage db sync" cinder

#cindor
#配置计算节点以使用块设备存储
crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne

#重启计算API 服务：
systemctl restart openstack-nova-api.service
systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service

