

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

crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends rbd
crudini --set /etc/cinder/cinder.conf rbd volume_backend_name backend
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
