<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

 - [ubuntu14.04环境](#ubuntu1404环境)

  - [初始环境安装](#初始环境安装)
  - [控制节点](#控制节点)

  - [安装数据库](#安装数据库)

    - [安装Mysql](#安装mysql)
    - [安装mongodb](#安装mongodb)
    - [安装rabbitmq](#安装rabbitmq)
    - [安装Memcached](#安装memcached)

  - [安装keystone](#安装keystone)

    - [初始化数据库](#初始化数据库)
    - [定义初始管理令牌的值:](#定义初始管理令牌的值)
    - [初始化身份认证服务的数据库:](#初始化身份认证服务的数据库)
    - [初始化Fernet keys:](#初始化fernet-keys)
    - [设置环境变量:](#设置环境变量)
    - [创建keystone认证](#创建keystone认证)
    - [关闭临时认证令牌机制](#关闭临时认证令牌机制)
    - [创建用户租户](#创建用户租户)
    - [创建调试文件](#创建调试文件)

  - [glance安装](#glance安装)

    - [初始化数据库账号](#初始化数据库账号)
    - [设置keystone](#设置keystone)
    - [glance](#glance)
    - [初始化数据库](#初始化数据库)
    - [测试glance](#测试glance)

  - [nova](#nova)

    - [设置数据库账号](#设置数据库账号)
    - [设置keystone](#设置keystone)
    - [安装nova](#安装nova)
    - [初始化数据库](#初始化数据库)

  - [horizon](#horizon)

    - [安装horizon](#安装horizon)
    - [去除ubuntu皮肤](#去除ubuntu皮肤)
    - [配置horizon页面](#配置horizon页面)
    - [设置django](#设置django)

  - [neutron](#neutron)

    - [设置数据库账号](#设置数据库账号)
    - [设置keystone](#设置keystone)
    - [设置网卡](#设置网卡)
    - [安装neutron](#安装neutron)

      - [安装ml2](#安装ml2)
      - [设置nova](#设置nova)

    - [初始化数据库](#初始化数据库)

  - [cinder](#cinder)

    - [创建数据库账号](#创建数据库账号)
    - [设置keystone](#设置keystone)
    - [安装cinder](#安装cinder)
    - [初始化数据](#初始化数据)
    - [测试](#测试)

- [网络节点](#网络节点)

  - [neutron安装](#neutron安装)
  - [配置网络节点](#配置网络节点)

    - [neutron](#neutron)
    - [ml2](#ml2)
    - [linuxbridge,l3_agent,dhcp,metadata](#linuxbridgel3agentdhcpmetadata)
    - [重启服务](#重启服务)

- [计算节点](#计算节点)

  - [安装nava-computer](#安装nava-computer)
  - [安装网络服务](#安装网络服务)

- [cinder存储节点](#cinder存储节点)

  - [安装cinder](#安装cinder)
  - [安装网络](#安装网络)

    - [ml2](#ml2)
    - [nova](#nova)

  - [配置存储](#配置存储)

    - [glusterfs](#glusterfs)

      - [安装](#安装)
      - [添加节点](#添加节点)

    - [ceph](#ceph)

<!-- /TOC -->

 # ubuntu14.04环境

# 初始环境安装

apt-get -qy install crudini chrony

控制节点:<br>
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime<br>
echo "server time.windows.com iburst" >> /etc/chrony/chrony.conf<br>
/etc/init.d/chrony restart

启用OpenStack库:<br>
apt-get -qy install software-properties-common<br>
add-apt-repository cloud-archive:mitaka

内网源使用:<br>
echo "deb [arch=amd64] <http://192.168.2.88:1888/ubuntu> trusty-updates/mitaka main" >> /etc/apt/sources.list

apt-get update<br>
apt-get install ubuntu-cloud-keyring<br>
apt-get update

安装 OpenStack 客户端:<br>
apt-get -qy install python-openstackclient

# 控制节点

## 安装数据库

### 安装Mysql

apt-get -qy install mariadb-server python-pymysql

vim /etc/mysql/conf.d/openstack.cnf

```config
[mysqld]
bind-address = 192.168.1.11
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
```

/etc/init.d/mysql restart<br>
mysql_secure_installation

### 安装mongodb

apt-get -qy install mongodb-server mongodb-clients python-pymongo

crudini --set /etc/mongodb.conf '' bind_ip 192.168.1.11<br>
crudini --set /etc/mongodb.conf '' smallfiles true

/etc/init.d/mongodb stop<br>
rm /var/lib/mongodb/journal/prealloc.*<br>
/etc/init.d/mongodb start

### 安装rabbitmq

apt-get -qy install rabbitmq-server<br>
rabbitmqctl add_user openstack pass<br>
rabbitmqctl set_permissions openstack "._" "._" ".*"

### 安装Memcached

apt-get install memcached python-memcache

```
vim /etc/memcached.conf   
-l 192.168.1.11   
/etc/init.d/memcached restart
```

## 安装keystone

### 初始化数据库

```shell
mysql -uroot -ppass <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF
```

安装后禁止keystone 服务自动启动:<br>
echo "manual" > /etc/init/keystone.override<br>
apt-get -qy install keystone apache2 libapache2-mod-wsgi

### 定义初始管理令牌的值:

crudini --set /etc/keystone/keystone.conf DEFAULT admin_token pass<br>
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:pass@controller/keystone<br>
crudini --set /etc/keystone/keystone.conf token provider fernet

### 初始化身份认证服务的数据库:

su -s /bin/sh -c "keystone-manage db_sync" keystone

### 初始化Fernet keys:

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

### 设置环境变量:

```
export OS_TOKEN=pass
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
```

### 创建keystone认证

```shell
Create the service entity and API endpoints:   
openstack service create --name keystone --description "OpenStack Identity" identity  
openstack endpoint create --region RegionOne identity public http://controller:5000/v3  
openstack endpoint create --region RegionOne identity internal http://controller:5000/v3  
openstack endpoint create --region RegionOne identity admin http://controller:35357/v3  

Create a domain, projects, users, and roles:  
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
```

### 关闭临时认证令牌机制

```
编辑 /etc/keystone/keystone-paste.ini 文件，从``[pipeline:public_api]``，
[pipeline:admin_api]``和``[pipeline:api_v3]``部分删除``admin_token_auth 。
```

### 创建用户租户

unset OS_TOKEN OS_URL

```shell
作为 admin 用户，请求认证令牌:
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue  

作为``demo`` 用户，请求认证令牌:  
openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo token issue
```

### 创建调试文件

admin-openrc:

```shell
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

demo-openrc

```shell
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

source admin-openrc 请求认证令牌:<br>
openstack token issue

## glance安装

### 初始化数据库账号

```shell
mysql -uroot -ppass <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF
```

### 设置keystone

```shell
openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292
```

### glance

apt-get -qy install glance

```shell
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
配置本地文件系统存储和镜像文件位置：
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
```

### 初始化数据库

su -s /bin/sh -c "glance-manage db_sync" glance<br>
for i in {glance-registry,glance-api};do service $i restart;done

### 测试glance

```shell
wget http://images.trystack.cn/cirros/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
wget http://images.trystack.cn/centos/CentOS-6-x86_64-GenericCloud-20141129_01.qcow2
openstack image create "centos6" --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2 --disk-format qcow2 --container-format bare --public
```

## nova

### 设置数据库账号

```shell
mysql -uroot -ppass <<EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF
```

### 设置keystone

```shell
openstack user create --domain default --password-prompt nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
```

### 安装nova

apt-get -qy install nova-api nova-conductor nova-consoleauth \ nova-novncproxy nova-scheduler

```shell
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
crudini --set  /etc/nova/nova.conf DEFAULT my_ip 192.168.1.11
crudini --set  /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set  /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set  /etc/nova/nova.conf vnc vncserver_listen "\$my_ip"
crudini --set  /etc/nova/nova.conf vnc vncserver_proxyclient_address "\$my_ip"
crudini --set  /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set  /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
```

### 初始化数据库

su -s /bin/sh -c "nova-manage api_db sync" nova<br>
su -s /bin/sh -c "nova-manage db sync" nova

for i in {nova-api,nova-consoleauth,nova-scheduler,nova-conductor,nova-novncproxy};do service $i restart;done

## horizon

### 安装horizon

apt-get -qy install openstack-dashboard

### 去除ubuntu皮肤

```
apt-get remove --purge openstack-dashboard-ubuntu-theme
cd /usr/share/openstack-dashboard
./manage.py collectstatic
./manage.py compress
```

### 配置horizon页面

crudini --set /etc/apache2/apache2.conf '' ServerName controller

vim /etc/apache2/sites-available/wsgi-keystone.conf

```html
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
```

ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled<br>
service apache2 restart<br>
rm -f /var/lib/keystone/keystone.db

### 设置django

vim /etc/openstack-dashboard/local_settings.py

```python
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
```

## neutron

### 设置数据库账号

```shell
mysql -uroot -ppass <<EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF
```

### 设置keystone

```shell
openstack user create --domain default --password-prompt neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696
```

### 设置网卡

设置通讯网卡模式

```shell
auto eth1
iface eth1 inet manual
up ip link set dev $IFACE up
down ip link set dev $IFACE down
```

### 安装neutron

apt-get -qy install neutron-server neutron-plugin-ml2

```shell
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
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
```

#### 安装ml2

```shell
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan,gre
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset true
```

#### 设置nova

```shell
crudini --set /etc/nova/nova.conf neutron url  http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url  http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type  password
crudini --set /etc/nova/nova.conf neutron project_domain_name  default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name  RegionOne
crudini --set /etc/nova/nova.conf neutron project_name  service
crudini --set /etc/nova/nova.conf neutron username  neutron
crudini --set /etc/nova/nova.conf neutron password  pass
 #crudini --set /etc/nova/nova.conf neutron service_metadata_proxy  True
 #crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret  pass
```

### 初始化数据库

```shell
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```

for i in {nova-api,neutron-server,};do service $i restart;done

## cinder

### 创建数据库账号

```shell
mysql -uroot -ppass <<EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF
```

### 设置keystone

```shell
openstack user create --domain default --password-prompt cinder
openstack role add --project service --user cinder admin

 #创建 cinder 和 cinderv2 服务实体：
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

 #创建块设备存储服务的 API 入口点
openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s
```

### 安装cinder

apt-get -y install cinder-api cinder-scheduler python-cinderclient

# apt-get -qy cinder-volume

```shell
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.41
crudini --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rootwrap_config  /etc/cinder/rootwrap.conf
crudini --set /etc/cinder/cinder.conf DEFAULT api_paste_confg  /etc/cinder/api-paste.ini
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v1_api  True
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v2_api  True
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy  keystone
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend  rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT scheduler_driver  cinder.scheduler.filter_scheduler.FilterScheduler

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:pass@controller/cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password pass
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path "\$state_path/tmp"

crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_port 5672
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password pass
```

## 初始化数据

chmod 640 /etc/cinder/cinder.conf<br>
chgrp cinder /etc/cinder/cinder.conf<br>
su -s /bin/sh -c "cinder-manage db sync" cinder<br>
for i in {nova-api,cinder-scheduler,cinder-api};do service $i restart;done

## 测试

cinder service-list

# 网络节点

## neutron安装

```shell
apt-get install neutron-server neutron-plugin-ml2 \
  neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent \
  neutron-metadata-agent -y
```

## 配置网络节点

### neutron

```shell
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
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
```

### ml2

```shell
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
```

### linuxbridge,l3_agent,dhcp,metadata

```shell
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:eth1
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.21
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret pass
```

### 重启服务

for i in {neutron-server,neutron-linuxbridge-agent,neutron-dhcp-agent,neutron-metadata-agent,neutron-l3-agent};do service $i restart;done

# 计算节点

## 安装nava-computer

apt-get install nova-compute -y

```shell
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
crudini --set /etc/nova/nova.conf DEFAULT my_ip 192.168.1.41
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf vnc enabled True
crudini --set /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address 192.168.1.41
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://controller:6080/vnc_auto.html
crudini --set /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path  /var/lib/nova/tmp
crudini --del /etc/nova/nova.conf DEFAULT logdir
 #启动实例调整大小
crudini --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host True
crudini --set /etc/nova/nova.conf DEFAULT scheduler_default_filters AllHostsFilter
```

service nova-compute restart

## 安装网络服务

apt-get install neutron-linuxbridge-agent -y

```shell
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
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:em2
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.41
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
```

service neutron-linuxbridge-agent restart

# cinder存储节点

## 安装cinder

apt-get -y install cinder-volume python-mysqldb

```shell
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.31
crudini --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rootwrap_config  /etc/cinder/rootwrap.conf
crudini --set /etc/cinder/cinder.conf DEFAULT api_paste_confg  /etc/cinder/api-paste.ini
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v1_api  True
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v2_api  True
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen  0.0.0.0
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen_port  8776
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy  keystone
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend  rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers  http://10.0.0.30:9292
crudini --set /etc/cinder/cinder.conf DEFAULT scheduler_driver  cinder.scheduler.filter_scheduler.FilterScheduler
crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:pass@controller/cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password pass
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path "\$state_path/tmp"
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_port 5672
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password pass
```

chmod 640 /etc/cinder/cinder.conf<br>
chgrp cinder /etc/cinder/cinder.conf<br>
systemctl restart cinder-volume

## 安装网络

apt-get install neutron-linuxbridge-agent -y

```shell
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
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
```

### ml2

```shell
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:em2
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.1.41
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
```

### nova

```shell
crudini --set /etc/nova/nova.conf neutron url http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type password
crudini --set /etc/nova/nova.conf neutron project_domain_name default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name RegionOne
crudini --set /etc/nova/nova.conf neutron project_name service
crudini --set /etc/nova/nova.conf neutron username neutron
crudini --set /etc/nova/nova.conf neutron password pass
```

service neutron-linuxbridge-agent restart

## 配置存储

### glusterfs

#### 安装

apt-get install glusterfs-server service glusterfs-server start

#### 添加节点

添加节点IP:<br>
gluster peer probe cinder2 设置节点目录:<br>
mkdir -p /node1 设置节点集群:<br>
gluster volume create demo replica 2 cinder1:/node1 cinder2:/node1 cinder3:/node1 cinder4:/node1 force<br>
启动卷:<br>
gluster vol start demo<br>
配置驱动:<br>
vim /etc/cinder/cinder.conf

```shell
crudini --set /etc/cinder/cinder.conf glusterfs volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_shares_config /etc/cider/glusterfs_shares
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_mount_point_base "$state_path/mnt"
 #crudini --set /etc/cinder/cinder.conf glusterfs nas_volume_prov_type thin
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends glusterfs
```

配置卷自动挂载:<br>
vim /etc/cider/glusterfs_shares 192.168.1.31:/demo

chmod 640 /etc/cinder/glusterfs_shares<br>
chgrp cinder /etc/cinder/glusterfs_shares<br>
service cinder-volume restart

计算节点配置:<br>
crudini --set /etc/nova/nova.conf DEFAULT volume_api_class nova.volume.cinder.API service nova-compute restart

### ceph

# 镜像定制

## kvm制作

安装kvm:<br>
sudo apt-get install qemu-kvm libvirt-bin kvm qemu virt-manager bridge-util

创建img:<br>
qemu-img create -f qcow2 server.img 20G

安装系统:<br>
sudo kvm -m 1024 -cdrom ubuntu-14.04.5-server-amd64.iso -drive file=server.img,if=virtio,index=0 -boot d -net nic -net user -nographic -vnc 192.168.88.140:0

安装vnc:<br>
apt-get install gvncviewer

登录测试:<br>
gvncviewer 192.168.88.140:0

检查镜像:<br>
sudo kvm -m 1024 -drive file=server.img,if=virtio,index=0 -boot c -net nic -net user -nographic -vnc 192.168.88.140:0

openstack image create "centos6" --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2 --disk-format qcow2 --container-format bare --public<br>
openstack image create "ubunut14.04" --file /root/ubuntu14.04.5 --disk-format qcow2 --container-format bare --public

更新镜像:<br>
sudo apt-get update<br>
sudo apt-get upgrade<br>
sudo apt-get install openssh-server cloud-init<br>
创建镜像:<br>
qemu-img create -f qcow2 /home/neildev/img/trusty.qcow2 20G

启动镜像:<br>
sudo virt-install --virt-type kvm --name trusty --ram 1024 \ --cdrom=/home/neildev/img/ubuntu-14.04.5-server-amd64.iso \ --disk /home/neildev/img/trusty.qcow2,format=qcow2 \ --network network=default \ --graphics vnc,listen=0.0.0.0 --noautoconsole \ --os-type=linux

sudo virsh start trusty --paused<br>
删除光驱:<br>
sudo virsh attach-disk --type cdrom --mode readonly trusty "" hdb

sudo virsh resume trusty<br>
apt-get install cloud-init<br>
dpkg-reconfigure cloud-init<br>
sudo virt-sysprep -d trusty<br>
sudo virsh undefine trusty

## virt-df

注意:xfs磁盘扩展不支持<br>
apt-get install libguestfs-tools -y<br>
查看镜像文件大小，并对其进行扩展<br>
virt-filesystems --long --parts --blkdevs -h -a CentOS-6-x86_64-GenericCloud.qcow2<br>
virt-df -h CentOS-6-x86_64-GenericCloud.qcow2

扩充系统盘<br>
qemu-img create -f qcow2 CentOS6_20G 20G<br>
virt-resize CentOS-6-x86_64-GenericCloud.qcow2 CentOS6_20G --expand /dev/sda1<br>
virt-df -h CentOS6_20G

### 修改证书

guestmount -a CentOS6_20G -i /mnt/guest/<br>
touch /mnt/guest/etc/1<br>
mkdir /mnt/guest/root/.ssh

```
echo << EOF >>/mnt/guest/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr0CdJmr1dT4InF/1lBv53qPrF1xP7ivv3tbXe5AhGx2trG1S5r1vnSsG2eRUaQ01NAsjvdSf9fIHaa2pDHJ7zrvRq+y2oVoGRWJEnB8mCFDP5n6i3gpf7CRxUra8c7TXo7bP3MWkeeXCFcMOQHUD
EOF
```

chmod 600 /mnt/guest/root/.ssh/authorized_keys<br>
guestunmount /mnt/guest/<br>
openstack image create "ubunut14.04" --file /root/ubuntu14.04.5 --disk-format qcow2 --container-format bare --public
