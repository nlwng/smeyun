-------------------------------------------------------------
���ƽڵ�
-------------------------------------------------------------
#���洢������cinder��Ϊʵ���ṩ���洢���洢�ķ������������ɿ��洢�����������߶��������õ������������ġ����кܶ������������ã�NAS/SAN��NFS��ISCSI��Ceph�ȡ�

mysql -uroot -ppass <<EOF
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'pass';
FLUSH PRIVILEGES;
EOF

source admin-openrc

openstack user create --domain default --password-prompt cinder
openstack role add --project service --user cinder admin

#���� cinder �� cinderv2 ����ʵ�壺
openstack service create --name cinder \
  --description "OpenStack Block Storage" volume

openstack service create --name cinderv2 \
  --description "OpenStack Block Storage" volumev2

#�������豸�洢������ API ���ڵ�
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

#�� [DEFAULT ���֣�����``my_ip`` ��ʹ�ÿ��ƽڵ��Ĺ����ӿڵ�IP ��ַ��
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.31.135
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

su -s /bin/sh -c "cinder-manage db sync" cinder
#���ü����ڵ���ʹ�ÿ��豸�洢
crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne

service nova-api restart
service cinder-scheduler restart
service cinder-api restart

for i in {nova-api,cinder-scheduler,cinder-api};do service $i restart;done

-------------------------------------------------------------
cinder�ڵ�
-------------------------------------------------------------
#��װ֧�ֵĹ��߰���
apt-get install lvm2
#����LVM ������ /dev/sdb
pvcreate /dev/sdb
#���� LVM ���� cinder-volumes��
vgcreate cinder-volumes /dev/sdb

#vim /etc/lvm/lvm.conf
#��``devices``���֣�����һ����������ֻ����``/dev/sdb``�豸���ܾ����������豸
devices {
filter = [ "a/sdb/", "r/.*/"]
#�������Ĵ洢�ڵ��ڲ���ϵͳ������ʹ���� LVM�����������������ص��豸���������С����磬���� /dev/sda �豸��������ϵͳ��
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

#��``[lvm]``���֣�����LVM������LVM��������������``cinder-volumes`` ��iSCSI Э������ȷ�� iSCSI����:
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

#������λ��
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
glusterfs ceph ���̿��ƽڵ�ֱ��װ, ��Ⱥ���㣬���ƽڵ㶼װ
----------------------------------
apt-get install  glusterfs-server
service glusterfs-server start
gluster peer status
#�����ƽڵ����������뼯Ⱥ������ip��ַ����
gluster peer probe 192.168.31.136
gluster peer probe cinder1
#ɾ����Ⱥ
gluster peer detach 192.168.31.136

#����Ŀ¼
mkdir -p /data/glusterfs-node1
mkdir -p /data/glusterfs-node2

#������
gluster volume create demo replica 2 cinder1:/node1 cinder1:/node2 cinder1:/node3 cinder1:/node4 force

#������
gluster vol start demo
#�鿴�ֲ�ʽ�ڵ�
gluster vol info

#ʹ��
vim /etc/cinder/cinder.conf
crudini --set /etc/cinder/cinder.conf glusterfs volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_shares_config /etc/cider/glusterfs_shares
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_mount_point_base "$state_path/mnt"
#crudini --set /etc/cinder/cinder.conf glusterfs nas_volume_prov_type thin

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends glusterfs

vim /etc/cider/glusterfs_shares
192.168.33.135:/demo

#��װcinderģ��
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
