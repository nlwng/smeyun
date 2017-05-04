----------------
控制节点
----------------
#控制节点上安装及配置 Orchestration 服务，即heat

mysql -uroot -ppass <<EOF
CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

#key
openstack user create --domain default --password-prompt heat
openstack role add --project service --user heat admin

#创建``heat`` 和 heat-cfn 服务实体：
openstack service create --name heat \
  --description "Orchestration" orchestration

openstack service create --name heat-cfn \
  --description "Orchestration"  cloudformation

#创建 Orchestration 服务的 API 端点：
openstack endpoint create --region RegionOne \
  orchestration public http://controller:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  orchestration internal http://controller:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  orchestration admin http://controller:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  cloudformation public http://controller:8000/v1

openstack endpoint create --region RegionOne \
  cloudformation internal http://controller:8000/v1

openstack endpoint create --region RegionOne \
  cloudformation admin http://controller:8000/v1

#为栈创建 heat 包含项目和用户的域：
openstack domain create --description "Stack projects and users" heat

#在 heat 域中创建管理项目和用户的``heat_domain_admin``用户：
openstack user create --domain heat --password-prompt heat_domain_admin

#添加``admin``角色到 heat 域 中的``heat_domain_admin``用户，启用``heat_domain_admin``用户管理栈的管理权限：
openstack role add --domain heat --user-domain heat --user heat_domain_admin admin

#创建 heat_stack_owner 角色：
openstack role create heat_stack_owner
#添加``heat_stack_owner`` 角色到``demo`` 项目和用户，启用``demo`` 用户管理栈。
openstack role add --project demo --user demo heat_stack_owner
#创建 heat_stack_user 角色：
openstack role create heat_stack_user


#安装软件包：
apt-get install heat-api heat-api-cfn heat-engine

crudini --set /etc/heat/heat.conf database connection mysql+pymysql://heat:pass@controller/heat
crudini --set /etc/heat/heat.conf DEFAULT rpc_backend rabbit
crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_password pass

crudini --set /etc/heat/heat.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/heat/heat.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/heat/heat.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/heat/heat.conf keystone_authtoken auth_type password
crudini --set /etc/heat/heat.conf keystone_authtoken project_domain_name default
crudini --set /etc/heat/heat.conf keystone_authtoken user_domain_name default
crudini --set /etc/heat/heat.conf keystone_authtoken project_name service
crudini --set /etc/heat/heat.conf keystone_authtoken username heat
crudini --set /etc/heat/heat.conf keystone_authtoken password pass

crudini --set /etc/heat/heat.conf trustee auth_plugin password
crudini --set /etc/heat/heat.conf trustee auth_url http://controller:35357
crudini --set /etc/heat/heat.conf trustee username heat
crudini --set /etc/heat/heat.conf trustee password pass
crudini --set /etc/heat/heat.conf trustee user_domain_name default

crudini --set /etc/heat/heat.conf clients_keystone auth_uri http://controller:35357

crudini --set /etc/heat/heat.conf ec2authtoken auth_uri http://controller:5000
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin heat_domain_admin
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password pass
crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name heat

#同步Orchestration数据库：
su -s /bin/sh -c "heat-manage db_sync" heat

# service heat-api restart
# service heat-api-cfn restart
# service heat-engine restart

for i in {heat-api,heat-api-cfn,heat-engine};do service $i restart;done

#验证
openstack orchestration service list
haproxy openstack-neutron-lbaas 