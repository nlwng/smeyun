#------------------------------------------------------------------

#创建 keystone 数据库、对keystone数据库授予恰当的权限：

mysql -u$sql_user -p$passwd <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY 'pass';
EOF

#获得 admin 凭证来获取只有管理员能执行的命令的访问权限：
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

#创建 glance 用户：
openstack user create --domain default --password="pass" glance

#添加 admin 角色到 glance 用户和 service 项目上。
openstack role add --project service --user glance admin

#创建glance服务实体：
openstack service create --name glance --description "OpenStack Image" image

#创建镜像服务的 API 端点：
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

#------------------------------------------------------------------

#安装软件包
apt-get install glance -y
#配置文件
crudini --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:pass@controller/glance
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
crudini --set /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:pass@controller/glance
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

#同步数据库
su -s /bin/sh -c "glance-manage db_sync" glance

#重启服务
service glance-registry restart
service glance-api restart


#安装工具
apt-get install axel -y
#下载镜像包
axel http://10.0.0.1:1888/cirros-0.3.4-x86_64-disk.img
#将镜像载入
openstack image create "cirros" \
  --file cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

#查询镜像列表用以验证
openstack image list
