-------------------------------------------------------------
控制节点
-------------------------------------------------------------
#块存储服务（cinder）为实例提供块存储。存储的分配和消耗是由块存储驱动器，或者多后端配置的驱动器决定的。还有很多驱动程序可用：NAS/SAN，NFS，ISCSI，Ceph等。

mysql -uroot -ppass <<EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

source admin-openrc

openstack user create --domain default --password-prompt cinder
openstack role add --project service --user cinder admin

#创建 cinder 和 cinderv2 服务实体：
openstack service create --name cinder \
  --description "OpenStack Block Storage" volume

openstack service create --name cinderv2 \
  --description "OpenStack Block Storage" volumev2

#创建块设备存储服务的 API 入口点
openstack endpoint create --region RegionOne \
  volume public http://controller:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  volume internal http://controller:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  volume admin http://controller:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  volumev2 public http://controller:8776/v2/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  volumev2 internal http://controller:8776/v2/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  volumev2 admin http://controller:8776/v2/%\(tenant_id\)s

apt-get -qy install cinder-api cinder-scheduler

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

#在 [DEFAULT 部分，配置``my_ip`` 来使用控制节点的管理接口的IP 地址。
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.31.135
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

su -s /bin/sh -c "cinder-manage db sync" cinder
#配置计算节点以使用块设备存储
crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne

service nova-api restart
service cinder-scheduler restart
service cinder-api restart

for i in {nova-api,cinder-scheduler,cinder-api};do service $i restart;done

-------------------------------------------------------------
cinder节点
-------------------------------------------------------------
#安装支持的工具包：
apt-get install lvm2
#创建LVM 物理卷 /dev/sdb
pvcreate /dev/sdb
#创建 LVM 卷组 cinder-volumes：
vgcreate cinder-volumes /dev/sdb

#vim /etc/lvm/lvm.conf
#在``devices``部分，添加一个过滤器，只接受``/dev/sdb``设备，拒绝其他所有设备
devices {
filter = [ "a/sdb/", "r/.*/"]
#如果您的存储节点在操作系统磁盘上使用了 LVM，您还必需添加相关的设备到过滤器中。例如，如果 /dev/sda 设备包含操作系统：
filter = [ "a/sda/", "a/sdb/", "a/sdc/","r/.*/"]

apt-get install cinder-volume


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
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.31.139

#new
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_mount_attempts 3
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_mount_options None
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_mount_point_base $state_path/mnt
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_shares_config /etc/cinder/nfs_shares
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_sparsed_volumes True

#在``[lvm]``部分，配置LVM后端以LVM驱动结束，卷组``cinder-volumes`` ，iSCSI 协议和正确的 iSCSI服务:
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm iscsi_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm iscsi_helper tgtadm

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

service tgt restart
service cinder-volume restart

for i in {tgt,cinder-volume};do service $i restart;done



---------------------------
nfs
---------------------------
#apt-get -qy install rpcbind nfs-kernel-server
mkdir -p /data/storage

vim /etc/exports
/data/storage *(rw,no_root_squash)
#/data/storage *(rw,sync,no_root_squash,no_subtree_check)

for i in {rpcbind,nfs-kernel-server};do service $i restart;done

#nfs_shares_config=/etc/cinder/nfs_shares
#nfs_mount_point_base=$state_path/mnt

crudini --set /etc/cinder/cinder.conf DEFAULT nfs_mount_attempts 3
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_mount_options None
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_mount_point_base $state_path/mnt
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_shares_config /etc/cinder/nfs_shares
crudini --set /etc/cinder/cinder.conf DEFAULT nfs_sparsed_volumes true
#crudini --set /etc/cinder/cinder.conf DEFAULT nas_secure_file_operations False
#crudini --set /etc/cinder/cinder.conf DEFAULT nas_option false
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends nfs

crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.nfs.NfsDriver

#挂载盘位置
vim /etc/cinder/nfs_shares
#192.168.31.139:/data/storage
#mount -t nfs 192.168.31.139:/data/storage
chmod 777 /etc/cinder/nfs_shares
chmod 777 /data/storage

python setup.py install
mkdir -p /etc/cinder /var/log/cinder /var/lib/cinder /var/run/cider
apt-get -qy install git git-core python-pip
pip install tox;cp /usr/local/bin/tox /usr/bin/
tox -egenconfig  


----------------------------------
glusterfs ceph 云盘控制节点直接装, 集群计算，控制节点都装
----------------------------------
apt-get install  glusterfs-server
service glusterfs-server start 
gluster peer status
#将控制节点上主机加入集群，多个ip地址问题
gluster peer probe 192.168.31.136
#删除集群
gluster peer detach 192.168.31.136

#创建目录
mkdir -p /data/glusterfs-node1
mkdir -p /data/glusterfs-node2

#创建卷
gluster volume create demo replica 2 192.168.31.135:/data/glusterfs-node1 192.168.31.136:/data/glusterfs-node2 force

#启动卷
gluster vol start demo
#查看分布式节点
gluster vol info

#使用
vim /etc/cinder/cinder.conf
crudini --set /etc/cinder/cinder.conf glusterfs volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_shares_config /etc/cider/glusterfs_shares
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_mount_point_base "$state_path/mnt"
#crudini --set /etc/cinder/cinder.conf glusterfs nas_volume_prov_type thin

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends glusterfs

vim /etc/cider/glusterfs_shares
192.168.33.135:/demo

#安装cinder模块
apt-get -qy install cinder-api cinder-scheduler cinder-volume
for i in {nova-api,cinder-volume,cinder-scheduler,cinder-api};do service $i restart;done


----------------------------------------
NEW
----------------------------------------







install glusterfs in all nodes
---------------------
apt-get -y install glusterfs-server
systemctl enable glusterfs-server 

systemctl start rpcbind 
systemctl enable rpcbind 

Create a Directory for GlusterFS Volume on all Nodes.
--------------------------------
mkdir /glusterfs/replica 

# probe the node
gluster peer probe node02 
# show status
gluster peer status 

# create volume
gluster volume create vol_replica replica 2 transport tcp \
node01:/glusterfs/replica \
node02:/glusterfs/replica 
# start volume
gluster volume start vol_replica 

# show volume info
gluster volume info 

Storage Node
---------------------
apt-get -y install glusterfs-client
crudini --set /etc/cinder/cinder.conf glusterfs volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_shares_config /etc/cider/glusterfs_shares
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_mount_point_base "$state_path/mnt"

vim /etc/cider/glusterfs_shares
# create new : specify GlusterFS volumes
192.168.31.135:/demo

chmod 640 /etc/cinder/glusterfs_shares 
chgrp cinder /etc/cinder/glusterfs_shares  
service  cinder-volume restart

Compute Node
---------------------
apt-get -y install glusterfs-client

crudini --set /etc/nova/nova.conf DEFAULT volume_api_class nova.volume.cinder.API
service nova-compute restart


