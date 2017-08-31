#-----------------------------------------------------------------------------------------------------------------
#获得 admin 凭证来获取只有管理员能执行的命令的访问权限：
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

neutron agent-list
#创建网络
neutron net-create ext-net --shared --router:external --provider:physical_network external --provider:network_type flat

#创建外部网络的子网
neutron subnet-create ext-net 192.168.253.0/24 --allocation-pool start=192.168.253.50,end=192.168.253.150 --gateway 192.168.253.1 --disable-dhcp --name ext-subnet --dns-nameserver 114.114.114.114

#获取demo用户令牌
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=pass
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

#创建内网
neutron net-create demo-net
#创建内网子网
neutron subnet-create demo-net 172.168.1.0/24 --gateway 172.168.1.1 --dns-nameserver 114.114.114.114 --name demo-subnet

#创建demo用户路由
neutron router-create demo-router

#在路由上添加接口
neutron router-interface-add demo-router demo-subnet
#将外部网络加入路由
neutron router-gateway-set demo-router ext-net
#-----------------------------------------------------------------------------------------------------------------
note：
1.手动添加网络在添加外部网络时物理网络要填external，不能使用默认default，网络类型看是flat,vlan vxlan根据需要设置
供应商网络
网络类型： flat
物理网络： external
2.设置路由主要创建时候直接指定外部网络，在添加内部网络就ok。
3.内部网络使用gre模式
MTU  1458
供应商网络
网络类型： gre
物理网络： -段标识 15
