
#------------------------------------------------------------------

#创建 keystone 数据库、对keystone数据库授予恰当的权限：
mysql -u$sql_user -p$passwd <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
  IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
  IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

#安装后禁止keystone 服务自动启动：
echo "manual" > /etc/init/keystone.override

#运行以下命令来安装包
apt-get install keystone apache2 libapache2-mod-wsgi -y

#编辑文件 /etc/keystone/keystone.conf
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $token
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:pass@controller/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet

#初始化身份认证服务的数据库：
su -s /bin/sh -c "keystone-manage db_sync" keystone

#初始化Fernet keys：
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

export OS_TOKEN=pass
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3

#编辑/etc/apache2/apache2.conf
sed -in '221a ServerName controller ' /etc/apache2/apache2.conf

#创建/etc/apache2/sites-available/wsgi-keystone.conf
echo "
Listen 5000
Listen 35357
<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat \"%{cu}t %M\"
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
    ErrorLogFormat \"%{cu}t %M\"
    ErrorLog /var/log/apache2/keystone.log
    CustomLog /var/log/apache2/keystone_access.log combined
    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>
">/etc/apache2/sites-available/wsgi-keystone.conf

#开启认证服务虚拟主机：
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

#重启Apache HTTP服务器
service apache2 restart

#删除SQLite 服务库文件
rm -f /var/lib/keystone/keystone.db

#配置认证令牌
export OS_TOKEN=$token
#配置端点URL：
export OS_URL=http://controller:35357/v3
#配置认证 API 版本：
export OS_IDENTITY_API_VERSION=3

#创建服务实体和身份认证服务：
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://controller:5000/v3
openstack endpoint create --region RegionOne identity internal http://controller:5000/v3
openstack endpoint create --region RegionOne identity admin http://controller:35357/v3
#创建域default
openstack domain create --description "Default Domain" default
#创建 admin 项目：
openstack project create --domain default --description "Admin Project" admin
#创建 admin 用户：
openstack user create --domain default --password="pass" admin
#创建 admin 角色：
openstack role create admin
#添加admin 角色到 admin 项目和用户上：
openstack role add --project admin --user admin admin
#创建service项目：
openstack project create --domain default --description "Service Project" service
#创建demo 项目：
openstack project create --domain default --description "Demo Project" demo
#创建demo 用户：
openstack user create --domain default --password="pass" demo
#创建 user 角色：
openstack role create user
#添加 user角色到demo 项目和用户：
openstack role add --project demo --user demo user

#重置OS_TOKEN和OS_URL 环境变量：
unset OS_TOKEN OS_URL

#作为 admin 用户，请求认证令牌：
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin --os-password="pass" token issue

#作为demo 用户，请求认证令牌：
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name demo --os-username demo --os-password="pass" token issue
