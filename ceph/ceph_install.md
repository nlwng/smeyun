<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [ceph原理](#ceph原理)
	- [相关特性](#相关特性)
	- [相关模块](#相关模块)
	- [实现过程](#实现过程)
- [网络结构](#网络结构)
- [创建存储池](#创建存储池)
- [设置Ceph客户端认证](#设置ceph客户端认证)
- [配置Glance](#配置glance)
- [配置Cinder:](#配置cinder)
- [配置Nova](#配置nova)

<!-- /TOC -->

# ceph原理
## 相关特性
算法：
``` s
Crush算法是ceph的两大创新之一，简单来说，ceph摒弃了传统的集中式存储元数据寻址的方案，
转而使用CRUSH算法完成数据的寻址操作.CRUSH在一致性哈希基础上很好的考虑了容灾域的隔离，
能够实现各类负载的副本放置规则，例如跨机房、机架感知等。Crush算法有相当强大的扩展性，理论上支持数千个存储节点.  
```
高可用：
```s
Ceph中的数据副本数量可以由管理员自行定义，并可以通过CRUSH算法指定副本的物理存储位置以分隔故障域，
支持数据强一致性； ceph可以忍受多种故障场景并自动尝试并行修复。
```
高扩展性
```s
Ceph不同于swift，客户端所有的读写操作都要经过代理节点。一旦集群并发量增大时，代理节点很容易成为单点瓶颈。
Ceph本身并没有主控节点，扩展起来比较容易，并且理论上，它的性能会随着磁盘数量的增加而线性增长。
```
特性丰富
```s
Ceph支持三种调用接口：对象存储，块存储，文件系统挂载。三种方式可以一同使用。在国内一些公司的云环境中，
通常会采用ceph作为openstack的唯一后端存储来提升数据转发效率。
```
## 相关模块
Osd
```s
用于集群中所有数据与对象的存储。处理集群数据的复制、恢复、回填、再均衡。并向其他osd守护进程发送心跳，然后向Mon提供一些监控信息。
当Ceph存储集群设定数据有两个副本时（一共存两份），则至少需要两个OSD守护进程即两个OSD节点，集群才能达到active+clean状态。
```
MDS(可选)
```s
为Ceph文件系统提供元数据计算、缓存与同步。在ceph中，元数据也是存储在osd节点中的，
mds类似于元数据的代理缓存服务器。MDS进程并不是必须的进程，只有需要使用CEPHFS时，才需要配置MDS节点。
```
Monitor
```s
监控整个集群的状态，维护集群的cluster MAP二进制表，保证集群数据的一致性。ClusterMAP描述了对象块存储的物理位置，以及一个将设备聚合到物理位置的桶列表。
```
## 实现过程
```s
   无论使用哪种存储方式（对象、块、挂载），存储的数据都会被切分成对象（Objects）。Objects size大小可以由管理员调整，
通常为2M或4M。每个对象都会有一个唯一的OID，由ino与ono生成，虽然这些名词看上去很复杂，其实相当简单。
ino即是文件的File ID，用于在全局唯一标示每一个文件，而ono则是分片的编号。

   对象并不会直接存储进OSD中，因为对象的size很小，在一个大规模的集群中可能有几百到几千万个对象。这么多对象光是遍历寻址，
速度都是很缓慢的；并且如果将对象直接通过某种固定映射的哈希算法映射到osd上，当这个osd损坏时，
对象无法自动迁移至其他osd上面（因为映射函数不允许）。为了解决这些问题，ceph引入了归置组的概念，即PG。

   PG：是一个逻辑概念，我们linux系统中可以直接看到对象，但是无法直接看到PG。它在数据寻址时类似于数据库中的索引：
每个对象都会固定映射进一个PG中，所以当我们要寻找一个对象时，只需要先找到对象所属的PG，然后遍历这个PG就可以了，
无需遍历所有对象。而且在数据迁移时，也是以PG作为基本单位进行迁移，ceph不会直接操作对象。

   对象时如何映射进PG的？还记得OID么？首先使用静态hash函数对OID做hash取出特征码，用特征码与PG的数量去模，
得到的序号则是PGID。由于这种设计方式，PG的数量多寡直接决定了数据分布的均匀性，所以合理设置的PG数量可以很好的提升CEPH集群的性能并使数据均匀分布。
最后PG会根据管理员设置的副本数量进行复制，然后通过crush算法存储到不同的OSD节点上（其实是把PG中的所有对象存储到节点上），第一个osd节点即为主节点，其余均为从节点。

   Pool：是管理员自定义的命名空间，像其他的命名空间一样，用来隔离对象与PG。我们在调用API存储即使用对象存储时，
需要指定对象要存储进哪一个POOL中。除了隔离数据，我们也可以分别对不同的POOL设置不同的优化策略，比如副本数、数据清洗次数、数据块及对象大小等。



参考：http://www.jianshu.com/p/25163032f57f
```
# 网络结构
monitor、mds、osd0 节点：openstack(controller)192.168.1.131  
osd1：compute 192.168.1.132  
osd2：storage 192.168.1.133  

# 创建存储池
ceph osd pool create volumes 128  
ceph osd pool create images 128  
ceph osd pool create vms 128  

# 设置Ceph客户端认证
在OpenStack节点执行如下命令  
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images'  
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images'  

为client.cinder，client.glance添加密钥文件来访问节点并改变属主：
```s
ceph auth get-or-create client.glance | ssh openstack sudo tee /etc/ceph/ceph.client.glance.keyring  
ssh openstack sudo chown glance:glance /etc/ceph/ceph.client.glance.keyring
ceph auth get-or-create client.glance | ssh compute sudo tee /etc/ceph/ceph.client.glance.keyring
ssh compute sudo chown nova:nova /etc/ceph/ceph.client.glance.keyring
ceph auth get-or-create client.cinder | ssh compute sudo tee /etc/ceph/ceph.client.cinder.keyring
ssh compute sudo chown nova:nova /etc/ceph/ceph.client.cinder.keyring
ceph auth get-or-create client.cinder | ssh storage sudo tee /etc/ceph/ceph.client.cinde.keyring
ssh storage sudo chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
```

运行nova-compute的节点nova-compute进程需要密钥文件。它们也存储client.cinder用户的密钥在libvirt。libvirt进程在Cinder中绑定块设备时需要用到它来访问集群。  
在nova-compute节点创建一个临时的密钥副本：  
```code
 # uuidgen
457eb676-33da-42ec-9a8c-9293d545c337
 # cat > secret.xml <
457eb676-33da-42ec-9a8c-9293d545c337
client.cinder secret
EOF
sudo virsh secret-define --file secret.xml
sudo virsh secret-set-value --secret 457eb676-33da-42ec-9a8c-9293d545c337 --base64 $(cat client.cinder.key) && rm client.cinder.key secret.xml
```

# 配置Glance  
编辑 /etc/glance/glance-api.conf并添加如下内容：
```code
[DEFAULT]
default_store = rbd
[glance_store]
stores = rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
```
如果要启动镜像的写时复制功能，添加下面的 [DEFAULT] 部分：  
show_image_direct_url = True

# 配置Cinder:
```code
在openstack节点和storage节点编辑 /etc/cinder/cinder.conf配置文件并添加如下内容：
volume_driver = cinder.volume.drivers.rbd.RBDDriver
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
glance_api_version = 2
```
如果使用cephx验证，需要配置user和uuid：
```code
rbd_user = cinder
rbd_secret_uuid = 457eb676-33da-42ec-9a8c-9293d545c337
```
# 配置Nova
为了挂载Cinder设备(普通设备或可引导卷)，必须指明使用的用户及UUID。libvirt将使用期在Ceph集群中进行连接和验证：
```code
rbd_user = cinder
rbd_secret_uuid = 457eb676-33da-42ec-9a8c-9293d545c337
```
编辑 /etc/nova/nova.conf并添加如下内容：
```code
[libvirt]
images_type = rbd
images_rbd_pool = vms
images_rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_user = cinder
rbd_secret_uuid = 457eb676-33da-42ec-9a8c-9293d545c337
libvirt_live_migration_flag="VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST"
```
禁用文件注入。当启动一个实例的时候，nova通常会尝试打开rootfs。这时，nova注入一些数据，  
如密码、ssh 密钥，配置文件等到文件系统中。然而，这最好依靠元数据服务和cloud-init来完成。  
在每个计算节点，编辑 /etc/nova/nova.conf 在 [libvirt] 标签添加：  
```code
libvirt_inject_password = false
libvirt_inject_key = false
libvirt_inject_partition = -2
```
重启服务:
for i in {nova-compute,inder-volume,cinder-backup};do service $i restart;done  
sudo glance-control api restart  
