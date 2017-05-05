

# ubuntu14.04环境
# 初始环境安装
apt-get -qy install crudini chrony

控制节点:  
cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime  
echo  "server time.windows.com iburst" >> /etc/chrony/chrony.conf  
/etc/init.d/chrony restart

启用OpenStack库:  
apt-get -qy install software-properties-common  
add-apt-repository cloud-archive:mitaka  

内网源使用:  
echo "deb [arch=amd64] http://192.168.2.88:1888/ubuntu trusty-updates/mitaka main" >> /etc/apt/sources.list  

apt-get update  
apt-get install ubuntu-cloud-keyring  
apt-get update  

安装 OpenStack 客户端:  
apt-get -qy install python-openstackclient  

# 控制节点安装
## 1.1 install Mysql:  
apt-get -qy install mariadb-server python-pymysql  

vim /etc/mysql/conf.d/openstack.cnf
```config-file
[mysqld]
bind-address = 192.168.31.135
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
```
/etc/init.d/mysql restart  
mysql_secure_installation  

## 1.2 mongodb install:  
apt-get -qy install mongodb-server mongodb-clients python-pymongo  

crudini --set /etc/mongodb.conf '' bind_ip 192.168.31.135  
crudini --set /etc/mongodb.conf '' smallfiles true  

/etc/init.d/mongodb stop  
rm /var/lib/mongodb/journal/prealloc.*  
/etc/init.d/mongodb start  

## 1.3 消息队列
apt-get -qy install rabbitmq-server  
rabbitmqctl add_user openstack pass  
rabbitmqctl set_permissions openstack ".*" ".*" ".*"  

## 1.4 Install Memcached
apt-get install memcached python-memcache  

vim /etc/memcached.conf   
-l 192.168.31.135  
/etc/init.d/memcached restart  

## 1.5 install keystone
```shell
mysql -uroot -ppass <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF
```
安装后禁止keystone 服务自动启动:  
echo "manual" > /etc/init/keystone.override  
apt-get -qy install keystone apache2 libapache2-mod-wsgi  

定义初始管理令牌的值:  
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token pass  
crudini --set /etc/keystone/keystone.conf database connection   mysql+pymysql://keystone:pass@controller/keystone  
crudini --set /etc/keystone/keystone.conf token provider fernet  

初始化身份认证服务的数据库:  
su -s /bin/sh -c "keystone-manage db_sync" keystone  
初始化Fernet keys:  
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone  

## 1.6 配置 Apache HTTP 服务器
crudini --set /etc/apache2/apache2.conf '' ServerName controller

vim /etc/apache2/sites-available/wsgi-keystone.conf
```
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
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled  
service apache2 restart  
rm -f /var/lib/keystone/keystone.db  

设置环境变量:  
```
export OS_TOKEN=pass
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
```

## 1.7 创建keystone认证
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

因为安全性的原因，关闭临时认证令牌机制:  
```
编辑 /etc/keystone/keystone-paste.ini 文件，从``[pipeline:public_api]``，
[pipeline:admin_api]``和``[pipeline:api_v3]``部分删除``admin_token_auth 。
```

Verify operation:  
unset OS_TOKEN OS_URL  

作为 admin 用户，请求认证令牌:
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue  

作为``demo`` 用户，请求认证令牌:  
openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo token issue  
