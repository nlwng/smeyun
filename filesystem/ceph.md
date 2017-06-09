

# 安装ceph
## 安装相关软件
echo "neildev ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/neildev && sudo chmod 440 /etc/sudoers.d/neildev

```s
apt-get -y install python-pip
pip install ceph-deploy
```

## 初始化
```s
ceph-deploy new cinder1
ceph-deploy install cinder1
ceph-deploy mon create-initial

各节点上准备数据盘:[prepare 和 activate 两个命令参数的区别，前者是使用磁盘，后者是使用分区]
ceph-deploy --overwrite-conf osd prepare cinder1:/data/osd2:/dev/sdb cinder1:/data/osd3:/dev/sdc
chown -R ceph.ceph /data/*
并激活 OSD:
ceph-deploy --overwrite-conf osd activate cinder1:/data/osd2:/dev/sdb cinder1:/data/osd3:/dev/sdc

删除分区:
如果是第二次安装的话，需要删除已经存在的 /dev/sdd1 这样的分区，然后再使用命令 ceph-deploy disk zap /dev/sdd 来将其数据全部删除

挂载完成之后:
会将 osd 盘挂载到 /var/lib/ceph/osd 下面的两个目录，目录名为 ceph-<osd id>
root@cinder1:/etc/ceph# ll  /var/lib/ceph/osd
lrwxrwxrwx  1 root root   10 Jun  8 14:23 ceph-0 -> /data/osd2/
lrwxrwxrwx  1 root root   10 Jun  8 14:23 ceph-1 -> /data/osd3/

查看os状态:
ceph osd tree

将Admin key复制到其余各个节点,然后安装 MDS集群:
ceph-deploy admin  cinder1
ceph-deploy mds  create cinder1

mds集群状态:
ceph mds stat



create pool:
ceph osd pool create volumes 128
ceph osd pool create backups 128
```


```s
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images'
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'
ceph auth get-or-create client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups'
```

volume 上设置:
```s
ceph auth get-or-create client.cinder | ssh cinder1 sudo tee /etc/ceph/client.cinder.keyring
ssh cinder1 sudo chown cinder:cinder /etc/ceph/client.cinder.keyring
```
Block Node:  
sudo apt-get install cinder-volume python-mysqldb qemu  

```s
crudini --set /etc/ceph/ceph.conf client.cinder keyring /etc/ceph/client.cinder.keyring
crudini --set /etc/ceph/ceph.conf client.cinder-backup keyring /etc/ceph/client.cinder-backup.keyring

```
sudo service cinder-volume restart

cinder-backup使用:
```s
ceph auth get-or-create client.cinder-backup | ssh <cinder-backup> sudo tee /etc/ceph/client.cinder-backup.keyring
ssh <cinder-backup> sudo chown cinder:cinder /etc/ceph/client.cinder-backup.keyring
```

```s
backup:
crudini --set /etc/cinder/cinder.conf DEFAULT backup_driver cinder.backup.drivers.ceph
crudini --set /etc/cinder/cinder.conf DEFAULT backup_ceph_conf /etc/ceph/ceph.conf
crudini --set /etc/cinder/cinder.conf DEFAULT backup_ceph_user cinder-backup
crudini --set /etc/cinder/cinder.conf DEFAULT backup_ceph_chunk_size 134217728  
crudini --set /etc/cinder/cinder.conf DEFAULT backup_ceph_pool backups
crudini --set /etc/cinder/cinder.conf DEFAULT backup_ceph_stripe_unit 0
crudini --set /etc/cinder/cinder.conf DEFAULT backup_ceph_stripe_count 0
crudini --set /etc/cinder/cinder.conf DEFAULT restore_discard_excess_bytes true
```
sudo service cinder-backup restart



```s
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends rbd
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.0.0.51
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:pass@controller/cinder
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password pass
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password pass
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

crudini --set /etc/cinder/cinder.conf rbd volume_backend_name rbd-backend
crudini --set /etc/cinder/cinder.conf rbd volume_driver cinder.volume.drivers.rbd.RBDDriver
crudini --set /etc/cinder/cinder.conf rbd rbd_pool volumes
crudini --set /etc/cinder/cinder.conf rbd rbd_ceph_conf /etc/ceph/ceph.conf
crudini --set /etc/cinder/cinder.conf rbd rbd_flatten_volume_from_snapshot false
crudini --set /etc/cinder/cinder.conf rbd rbd_max_clone_depth 5
crudini --set /etc/cinder/cinder.conf rbd rbd_store_chunk_size 4
crudini --set /etc/cinder/cinder.conf rbd rados_connect_timeout -1
crudini --set /etc/cinder/cinder.conf rbd glance_api_version 2
crudini --set /etc/cinder/cinder.conf rbd rbd_user cinder
crudini --set /etc/cinder/cinder.conf rbd rbd_secret_uuid ec6913ec-bac6-4e00-9c6b-6217c4b045c2


```

chmod 640 /etc/cinder/cinder.conf  
chgrp cinder /etc/cinder/cinder.conf   
chown -R cinder.cinder /mnt/  
service cinder-volume restart  






# 控制节点
### 安装cinder

apt-get -y install cinder-api cinder-scheduler python-cinderclient

```s
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.11
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

chmod 640 /etc/cinder/cinder.conf  
chgrp cinder /etc/cinder/cinder.conf  
su -s /bin/sh -c "cinder-manage db sync" cinder  
for i in {nova-api,cinder-scheduler,cinder-api};do service $i restart;done
