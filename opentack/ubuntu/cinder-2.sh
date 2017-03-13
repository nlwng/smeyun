-----------------------
Control Node
-----------------------
                                     +------------------+
                             10.0.0.50| [ Storage Node ] |
+------------------+            +-----+   Cinder-Volume  |
| [ Control Node ] |            | eth0|                  |
|     Keystone     |10.0.0.30   |     +------------------+
|      Glance      |------------+
|     Nova API     |eth0        |     +------------------+
|    Cinder API    |            | eth0| [ Compute Node ] |
+------------------+            +-----+   Nova Compute   |
                             10.0.0.51|                  |
                                      +------------------+


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

mysql -uroot -ppass <<EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

#Install Cinder Service.
apt-get -y install cinder-api cinder-scheduler python-cinderclient

crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.31.135
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

chmod 640 /etc/cinder/cinder.conf 
chgrp cinder /etc/cinder/cinder.conf 
su -s /bin/sh -c "cinder-manage db sync" cinder

for i in {nova-api,cinder-scheduler,cinder-api};do service $i restart;done
# show status
cinder service-list 

---------------------------
Cinder Node
---------------------------
                                     +------------------+           +------------------+
                             10.0.0.50| [ Storage Node ] |  10.0.0.61|                  |
+------------------+            +-----+   Cinder-Volume  |     +-----+   GlusterFS #1   |
| [ Control Node ] |            | eth0|                  |     | eth0|                  |
|     Keystone     |10.0.0.30   |     +------------------+     |     +------------------+
|      Glance      |------------+------------------------------+
|     Nova API     |eth0        |     +------------------+     |     +------------------+
|    Cinder API    |            | eth0| [ Compute Node ] |     | eth0|                  |
+------------------+            +-----+   Nova Compute   |     +-----+   GlusterFS #2   |
                             10.0.0.51|                  |  10.0.0.62|                  |
                                      +------------------+           +------------------+


apt-get -y install cinder-volume python-mysqldb

crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.31.139
crudini --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rootwrap_config  /etc/cinder/rootwrap.conf
crudini --set /etc/cinder/cinder.conf DEFAULT api_paste_confg  /etc/cinder/api-paste.ini
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v1_api  True
crudini --set /etc/cinder/cinder.conf DEFAULT enable_v2_api  True

crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen  0.0.0.0
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen_port  8776
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy  keystone
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend  rabbit
# specify Glance server
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers  http://10.0.0.30:9292
crudini --set /etc/cinder/cinder.conf DEFAULT scheduler_driver  cinder.scheduler.filter_scheduler.FilterScheduler
crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:pass@192.168.31.135/cinder

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

chmod 640 /etc/cinder/cinder.conf 
chgrp cinder /etc/cinder/cinder.conf 
systemctl restart cinder-volume

------------------
LVM
------------------
pvcreate /dev/sdb1 
vgcreate -s 32M vg_volume01 /dev/sdb1 

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf lvm iscsi_helper tgtadm
crudini --set /etc/cinder/cinder.conf lvm volume_group vg_volume01
crudini --set /etc/cinder/cinder.conf lvm iscsi_ip_address 10.0.0.50
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volumes_dir "\$state_path/volumes"
crudini --set /etc/cinder/cinder.conf lvm iscsi_protocol iscsi

systemctl restart cinder-volume

#Configure Nova on Compute Node.
crudini --set /etc/nova/nova.conf DEFAULT volume_api_class nova.volume.cinder.API


------------------
NFS
------------------
	
Configure NFS Server to share directories on your Network.
+----------------------+          |          +----------------------+
| [    NFS Server    ] |10.0.0.30 | 10.0.0.31| [    NFS Client    ] |
|     dlp.srv.world    +----------+----------+    client.srv.world  |
|                      |                     |                      |
+----------------------+                     +----------------------+

#Configure NFS Server.
apt-get -y install nfs-kernel-server
crudini --set /etc/idmapd.conf '' Domain srv.world

#vim /etc/exports
/home 10.0.0.0/24(rw,no_root_squash)

systemctl restart nfs-server

#Configure Storage Node.
apt-get -y install nfs-common

#line 6: uncomment and change to the own domain name
crudini --set /etc/idmapd.conf '' Domain srv.world

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends nfs

crudini --set /etc/cinder/cinder.conf nfs volume_driver cinder.volume.drivers.nfs.NfsDriver
crudini --set /etc/cinder/cinder.conf nfs nfs_shares_config /etc/cinder/nfs_shares
crudini --set /etc/cinder/cinder.conf nfs nfs_mount_point_base "\$state_path/mnt"

vim /etc/cinder/nfs_shares
# create new : specify NFS shared directory
192.168.31.135:/storage


chmod 640 /etc/cinder/nfs_shares 
chgrp cinder /etc/cinder/nfs_shares 
systemctl restart cinder-volume 
chown -R cinder. /var/lib/cinder/mnt


#Change Nova settings to mount NFS.
apt-get -y install nfs-common

## line 6: uncomment and change to the own domain name
crudini --set /etc/idmapd.conf '' Domain srv.world

#Configure Nova on Compute Node.
crudini --set /etc/nova/nova.conf DEFAULT volume_api_class nova.volume.cinder.API
systemctl restart nova-compute

#nfs客户端设置
apt-get -y install nfs-common
systemctl enable rpcbind
mount -t nfs -o mountvers=3 node01.srv.world:/vol_distributed /mnt 


------------------
GlusterFS
------------------
#Install Cinder Volume.
apt-get -y install cinder-volume python-mysqldb

crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen 0.0.0.0
crudini --set /etc/cinder/cinder.conf DEFAULT osapi_volume_listen_port 8776
crudini --set /etc/cinder/cinder.conf DEFAULT glance_host 192.168.31.135
crudini --set /etc/cinder/cinder.conf DEFAULT glance_port 9292
crudini --set /etc/cinder/cinder.conf DEFAULT notification_driver cinder.openstack.common.notifier.rpc_notifier
crudini --set /etc/cinder/cinder.conf DEFAULT scheduler_driver cinder.scheduler.filter_scheduler.FilterScheduler


+----------------------+          |          +----------------------+
| [GlusterFS Server#1] |10.0.0.51 | 10.0.0.52| [GlusterFS Server#2] |
|   node01.srv.world   +----------+----------+   node02.srv.world   |
|                      |                     |                      |
+----------------------+                     +----------------------+

#Install GlusterFS Server on All Nodes, refer to here.
apt-get -y install glusterfs-server
service glusterfs-server  start

service rpcbind start
                                      +------------------+           +------------------+
                             10.0.0.50| [ Storage Node ] |  10.0.0.61|                  |
+------------------+            +-----+   Cinder-Volume  |     +-----+   GlusterFS #1   |
| [ Control Node ] |            | eth0|                  |     | eth0|                  |
|     Keystone     |10.0.0.30   |     +------------------+     |     +------------------+
|      Glance      |------------+------------------------------+
|     Nova API     |eth0        |     +------------------+     |     +------------------+
|    Cinder API    |            | eth0| [ Compute Node ] |     | eth0|                  |
+------------------+            +-----+   Nova Compute   |     +-----+   GlusterFS #2   |
                             10.0.0.51|                  |  10.0.0.62|                  |
                                      +------------------+           +------------------+

mkdir -p /glusterfs/replica 
#probe the node
gluster peer probe 192.168.31.136
gluster peer status 

# create volume
gluster volume create vol_replica replica 2 transport tcp 192.168.31.135:/glusterfs/replica 192.168.31.136:/glusterfs/replica force

# start volume
gluster volume start vol_replica 
gluster volume info 

#shutdown NFS  Clients
gluster volume set vol_replica nfs.disable off 

apt-get -y install glusterfs-client
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends glusterfs
crudini --set /etc/cinder/cinder.conf glusterfs volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_shares_config  /etc/cinder/glusterfs_shares
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_mount_point_base  "\$state_path/mnt_gluster"

vim /etc/cinder/glusterfs_shares
192.168.31.135:/vol_replica

chmod 640 /etc/cinder/glusterfs_shares 
chgrp cinder /etc/cinder/glusterfs_shares 

for i in {nova-api,cinder-volume,cinder-scheduler,cinder-api};do service $i restart;done


----
Compute Node
----
apt-get -y install glusterfs-client
crudini --set /etc/nova/nova.conf DEFAULT osapi_volume_listen 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT os_region_name RegionOne

service nova-compute restart 


#glusterfs客户端设置
apt-get -y install glusterfs-client
mount -t glusterfs node01.srv.world:/vol_distributed /mnt 
