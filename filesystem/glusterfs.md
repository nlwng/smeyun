<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

 - [GlusterFS](#glusterfs)

  - [1 安装](#1-安装)
  - [1.1 centos6.8环境下安装使用](#11-centos68环境下安装使用)

    - [1.1.1 安装GlusterFS](#111-安装glusterfs)
    - [1.1.2 分布式配置](#112-分布式配置)
    - [1.1.3 复制卷配置](#113-复制卷配置)
    - [1.1.4 磁盘条带化配置](#114-磁盘条带化配置)
    - [1.1.5 分布式+复制](#115-分布式复制)
    - [1.1.6 磁条化+复制](#116-磁条化复制)
    - [1.1.7 配置GlusterFS客户端硬盘](#117-配置glusterfs客户端硬盘)
    - [1.1.8 GlusterFS卷维护](#118-glusterfs卷维护)

      - [1.1.7.1 删除节点和卷](#1171-删除节点和卷)
      - [1.1.7.2 配额管理](#1172-配额管理)
      - [1.1.7.3 地域复制](#1173-地域复制)
      - [1.1.7.4 平衡卷](#1174-平衡卷)
      - [1.1.7.5 I/O 信息查看](#1175-io-信息查看)
      - [1.1.7.6 top监控](#1176-top监控)
      - [1.1.7.7 性能优化配置选项](#1177-性能优化配置选项)

  - [1.2 ubutnu下安装](#12-ubutnu下安装)

  - [1.3 压力测试](#13-压力测试)

    - [1.3.1 dd测试](#131-dd测试)
    - [1.3.2 iozone测试](#132-iozone测试)

- [故障处理案例](#故障处理案例)

  - [案例1](#案例1)
  - [案例2](#案例2)

<!-- /TOC -->

 # GlusterFS

GlusterFS适合存储大文件，小文件性能较差 官方下载网站:<br>
<https://download.gluster.org/pub/gluster/><br>
<https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.10/>

## 1 安装

## 1.1 安装使用

### 1.1.1 安装GlusterFS

#### centos

vim /etc/hosts

```
10.0.0.51 node01
10.0.0.52 node02
10.0.0.53 node03sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-Gluster-3.10.repo
10.0.0.54 node04
```

yum -y install xfsprogs wget fuse fuse-libs<br>
yum -y install centos-release-gluster310.noarch

glusterfs-server:<br>
<https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.10/glusterfs-server-3.10.1-1.el6.x86_64.rpm><br>
glusterfs-client:<br>
<https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-3.10/glusterfs-client-xlators-3.10.1-1.el6.x86_64.rpm><br>
glusterfs-common

glusterfs-dbg

sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-Gluster-3.10.repo

yum clean all;yum makecache yum --enablerepo=centos-gluster310,epel -y install glusterfs-server

/etc/rc.d/init.d/glusterd start<br>
chkconfig glusterd on gluster peer status

### 1.1.2 分布式配置

mkdir -p /glusterfs/distributed

创建集群:[node01]<br>
增加集群:<br>
gluster peer probe node02

查看节点:<br>
gluster peer status

创建卷:

```
gluster volume create vol_distributed transport tcp \
node01:/glusterfs/distributed \
node02:/glusterfs/distributed force
```

启动卷:<br>
gluster volume start vol_distributed

查看卷信息:<br>
gluster volume info

### 1.1.3 复制卷配置

Replicated:复制式卷，类似raid1，replica数必须等于volume中brick所包含的存储服务器数，可用性高。

创建目录:<br>
mkdir /glusterfs/replica<br>
配置节点:<br>
gluster peer probe node02<br>
查看节点:<br>
gluster peer status

创建卷:<br>
gluster volume create vol_replica replica 2 transport tcp \ node01:/glusterfs/replica \ node02:/glusterfs/replica force

启动卷:<br>
gluster volume start vol_replica

查看卷:<br>
gluster volume info

### 1.1.4 磁盘条带化配置

Stripe相当于RAID0，即分片存储，文件被划分成固定长度的数据分片以Round-Robin轮转方式存储在所有存储节点。Stripe所有存储节点组成完整的名字空间，查找文件时需要询问所有节点，这点非常低效。读写数据时，Stripe涉及全部分片存储节点，操作可以在多个节点之间并发执行，性能非常高。Stripe通常与AFR组合使用，构成RAID10/RAID01，同时获得高性能和高可用性，当然存储利用率会低于50%。

创建目录:<br>
mkdir /glusterfs/striped<br>
配置节点:<br>
gluster peer probe node02<br>
查看节点:<br>
gluster peer status

创建卷:<br>
gluster volume create vol_striped stripe 2 transport tcp \ node01:/glusterfs/striped \ node02:/glusterfs/striped force

启动卷:<br>
gluster volume start vol_striped

查看卷:<br>
gluster volume info

### 1.1.5 分布式+复制

Distributed Replicated:分布式的复制卷，volume中brick所包含的存储服务器数必须是 replica 的倍数(>=2倍)，兼顾分布式和复制式的功能。

```
+----------------------+          |          +----------------------+
| [GlusterFS Server#1] |10.0.0.51 | 10.0.0.52| [GlusterFS Server#2] |
|   node01             +----------+----------+   node02             |
|                      |          |          |                      |
+----------------------+          |          +----------------------+
                                  |
+----------------------+          |          +----------------------+
| [GlusterFS Server#3] |10.0.0.53 | 10.0.0.54| [GlusterFS Server#4] |
|   node03             +----------+----------+   node04             |
|                      |                     |                      |
+----------------------+                     +----------------------+
```

创建目录:<br>
mkdir /glusterfs/dist-replica<br>
配置节点:<br>
gluster peer probe node02<br>
gluster peer probe node03<br>
gluster peer probe node04<br>
查看节点:<br>
gluster peer status

创建卷:<br>
gluster volume create vol_dist-replica replica 2 transport tcp \ node01:/glusterfs/dist-replica \ node02:/glusterfs/dist-replica \ node03:/glusterfs/dist-replica \ node04:/glusterfs/dist-replica force

启动卷:<br>
gluster volume start vol_dist-replica

查看卷:<br>
gluster volume info

### 1.1.6 磁条化+复制

Distributed Striped:分布式的条带卷，volume中brick所包含的存储服务器数必须是stripe的倍数(>=2倍)，兼顾分布式和条带式的功能。

```
+----------------------+          |          +----------------------+
| [GlusterFS Server#1] |10.0.0.51 | 10.0.0.52| [GlusterFS Server#2] |
|   node01             +----------+----------+   node02\.            |
|                      |          |          |                      |
+----------------------+          |          +----------------------+
                                  |
+----------------------+          |          +----------------------+
| [GlusterFS Server#3] |10.0.0.53 | 10.0.0.54| [GlusterFS Server#4] |
|   node03             +----------+----------+   node04             |
|                      |                     |                      |
+----------------------+                     +----------------------+
```

创建目录:<br>
mkdir /glusterfs/strip-replica<br>
配置节点:<br>
gluster peer probe node02<br>
gluster peer probe node03<br>
gluster peer probe node04<br>
查看节点:<br>
gluster peer status

创建卷:<br>
gluster volume create vol_strip-replica stripe 2 replica 2 transport tcp \ node01:/glusterfs/strip-replica \ node02:/glusterfs/strip-replica \ node03:/glusterfs/strip-replica \ node04:/glusterfs/strip-replica force

启动卷:<br>
gluster volume start vol_strip-replica

查看卷:<br>
gluster volume info

### 1.1.7 配置GlusterFS客户端硬盘

yum -y install xfsprogs wget fuse fuse-libs<br>
yum -y install centos-release-gluster310<br>
yum -y install glusterfs glusterfs-fuse

配置好hosts以后直接配置挂载:

```
mount -t glusterfs node01:/strip-replica /data
echo "172.28.26.102:/img /mnt/ glusterfs defaults,_netdev 0 0" >> /etc/fstab (开机自动挂载)
```

### 1.1.8 GlusterFS卷维护

删除集群[本文以vol_distributed为列]

#### 1.1.7.1 删除节点和卷

启动/停止/删除卷:<br>
gluster volume start vol_distributed<br>
gluster volume stop vol_distributed<br>
gluster volume delete vol_distributed

删除节点:<br>
gluster peer status<br>
gluster peer detach node02

列出集群中的所有卷:<br>
gluster volume list

查看集群中的卷信息:<br>
gluster volume info vol_distributed

查看集群中的卷状态:<br>
gluster volume status vol_distributed

限制IP访问:<br>
gluster volume set vol_distributed auth.allow 192.168.1.*

后续增加节点时使用,扩容:<br>
gluster peer probe node05<br>
删除集群节点:<br>
gluster peer detach node05<br>
增加到卷,向卷中添加brick:<br>
gluster volume add-brick vol_distributed node03:/glusterfs/distributed force<br>
修复GlusterFS磁盘数据<br>
比如在使用IP1的过程总宕机了，使用IP2替换，需要执行数据同步<br>
gluster volume replace-brick gv0 IP1: /export/sdb1/brick IP2: /export/sdb1/brick commit -force<br>
gluster volume heal gv0 full

若是副本卷，则一次添加的Bricks 数是replica 的整数倍；stripe 具有同样的要求<br>
gluster volume add-brick vol_distributed replica 2 node05:/brick1 node06:/brick1 force<br>
平衡卷内容:<br>
volume rebalance gv0 start

#### 1.1.7.2 配额管理

开启/关闭系统配额:<br>
gluster volume quota vol_distributed enable/disable

设置(重置)目录配额:<br>
gluster volume quota vol_distributed limit-usage /img limit-value gluster volume quota img limit-usage /quota 10GB

配额查看:<br>
gluster volume quota vol_distributed list

#### 1.1.7.3 地域复制

gluster volume geo-replication MASTER SLAVE start/status/stop

地域复制是系统提供的灾备功能，能够将系统的全部数据进行异步的增量备份到另外的磁盘中:

将img卷中的所有内容备份到10.8下的/data1/brick1 中的task,备份目标不能是系统中的Brick<br>
gluster volume geo-replication img 192.168.10.8:/data1/brick1 start

#### 1.1.7.4 平衡卷

平衡布局是很有必要的，因为布局结构是静态的，当新的bricks 加入现有卷，新创建的文件会分布到旧的bricks 中，所以需要平衡布局结构，使新加入的bricks 生效。布局平衡只是使新布局生效，并不会在新的布局移动老的数据，如果你想在新布局生效后，重新平衡卷中的数据，还需要对卷中的数据进行平衡

当你扩展或者缩小卷之后，需要重新在服务器直接重新平衡一下数据，重新平衡的操作被分为两个步骤:<br>
1.Fix Layout:<br>
修改扩展或者缩小后的布局，以确保文件可以存储到新增加的节点中<br>
2.Migrate Data<br>
重新平衡数据在新加入bricks 节点之后

先重新修改布局然后移动现有的数据(重新平衡)<br>
gluster volume rebalance vol_distributed fix-layout start<br>
gluster volume rebalance vol_distributed migrate-data start

gluster volume rebalance vol_distributed start<br>
你可以在在平衡过程中查看平衡信息<br>
gluster volume rebalance vol_distributed status<br>
你也可以暂停平衡，再次启动平衡的时候会从上次暂停的地方继续开始平衡<br>
gluster volume rebalance vol_distributed stop

#### 1.1.7.5 I/O 信息查看

提供接口查看一个卷中的每一个brick 的IO 信息<br>
Profile Command<br>
启动profiling，之后则可以进行IO 信息查看<br>
gluster volume profile VOLNAME start<br>
查看IO 信息，可以查看到每一个Brick 的IO 信息<br>
gluster volume profile VOLNAME info<br>
查看结束之后关闭profiling 功能<br>
gluster volume profile VOLNAME stop

#### 1.1.7.6 top监控

Top command 允许你查看bricks 的性能例如:<br>
read, write, fileopen calls, file read calls, file,write calls,directory open calls, and directory real calls<br>
查看打开的fd<br>
gluster volume top VOLNAME open [brick BRICK-NAME] [list-cnt cnt]<br>
查看调用次数最多的读调用<br>
gluster volume top VOLNAME read [brick BRICK-NAME] [list-cnt cnt]<br>
查看调用次数最多的写调用<br>
gluster volume top VOLNAME write [brick BRICK-NAME] [list-cnt cnt]<br>
查看次数最多的目录调用<br>
gluster volume top VOLNAME opendir [brick BRICK-NAME] [list-cnt cnt]<br>
查看次数最多的目录调用<br>
gluster volume top VOLNAME readdir [brick BRICK-NAME] [list-cnt cnt]<br>
查看每个Brick 的读性能<br>
gluster volume top VOLNAME read-perf [bs blk-size count count] [brickBRICK-NAME] [list-cnt cnt]<br>
查看每个Brick 的写性能<br>
gluster volume top VOLNAME write-perf [bs blk-size count count] [brickBRICK-NAME] [list-cnt cnt]

#### 1.1.7.7 性能优化配置选项

默认是10% 磁盘剩余告警<br>
gluster volume set vol_distributed cluster.min-free-disk<br>
默认是5% inodes 剩余告警<br>
gluster volume set vol_distributed cluster.min-free-inodes<br>

开启指定volume配额:<br>
gluster volume quota models enable

限制 models 中 / (既总目录) 最大使用 80GB 空间:<br>
gluster volume quota models limit-usage / 80GB

设置 cache 4GB,默认128M 或32MB<br>
gluster volume set demo performance.cache-size 2GB

开启 异步后台操作<br>
gluster volume set demo performance.flush-behind on

设置 io 线程 32,默认为16M<br>
gluster volume set demo performance.io-thread-count 32

设置 回写 (写数据时间，先写入缓存内，再写入硬盘)<br>
gluster volume set demo performance.write-behind on

默认是1M 能提高写性能单个文件后写缓冲区的大小默认1M:<br>
gluster volume set demo performance.write-behind-window-size 512MB

gluster volume set demo network.ping-timeout 10 默认42s

gluster volume set demo performance.read-ahead-page-count 8 默认4，预读取的数量

gluster volume set demo cluster.self-heal-daemon on 开启目录索引的自动愈合进程

gluster volume set demo cluster.heal-timeout 300 自动愈合的检测间隔，默认为600s

## 1.2 ubutnu下安装

依赖环境:<br>
apt-get install fuse libdevmapper-event1.02.1 libaio1 libibverbs1 liblvm2app2.2 librdmacm1

mount.glusterfs node:test /data

## 1.3 压力测试

### 1.3.1 dd测试

dd if=/dev/zero of=test.img bs=1024k count=1000

### 1.3.2 iozone测试

如果你直接使用DD，不见得可以测试出真实带宽，估计是和多线程有关

```
wget http://www.iozone.org/src/current/iozone-3-434.src.rpm
rpm -ivh iozone-3-434.src.rpm
cd ~/rpmbuild/SOURCES

tar -xvf iozone3_434.tar
make linux-AMD64
iozone -t 250 -i 0 -r 512k -s 500M -+n -w
```

# 故障处理案例

## 案例1

一台主机故障:

1. 物理故障
2. 同时有多块硬盘故障，造成数据丢失
3. 系统损坏不可修复

解决:<br>
找一台完全一样的机器，至少要保证硬盘数量和大小一致，安装系统，配置和故障机同样的 IP，安装 gluster 软件，保证配置一样，在其他健康节点上执行命令 gluster peer status，查看故障服务器的 uuid

修改新加机器的 /var/lib/glusterd/glusterd.info 和 故障机器一样:<br>
vim /var/lib/glusterd/glusterd.info

```
UUID=6e6a84af-ac7a-44eb-85c9-50f1f46acef1
operating-version=30712
```

在信任存储池中任意节点执行<br>
gluster volume heal gv2 full<br>
可以查看状态:<br>
gluster volume heal gv2 info

## 案例2

硬盘故障:<br>
解决:<br>
正常节点执行:gluster volume status 记录uuid<br>
执行：getfattr -d -m '.*' /brick 记录 trusted.gluster.volume-id 及 trusted.gfid

```
 系统提示如下：
Message from syslogd@linux-node01 at Jul 30 08:41:46 ...
 storage-brick2[5893]: [2016-07-30 00:41:46.729896] M [MSGID: 113075] [posix-helpers.c:1844:posix_health_check_thread_proc] 0-gv2-posix: health-check failed, going down

Message from syslogd@linux-node01 at Jul 30 08:42:16 ...
 storage-brick2[5893]: [2016-07-30 00:42:16.730518] M [MSGID: 113075] [posix-helpers.c:1850:posix_health_check_thread_proc] 0-gv2-posix: still alive! -> SIGTERM

  查看卷状态，mystorage1:/storage/brick2 不在线了，不过这是分布式复制卷，还可以访问另外 brick 上的数据
[root@mystorage1 ~]# gluster volume status gv2
Status of volume: gv2
Gluster process                             TCP Port  RDMA Port  Online  Pid
```

修复过程:<br>
故障mystorage1 主机的第三块硬盘,对应 sdc /storage/brick2<br>
增加一块新硬盘并执行:

```
mkfs.xfs -f /dev/sdc
mkdir -p /storage/brick2
mount -a
df -h
```

配置新硬盘gluser参数:

```

 在 mystorage2 是获取 glusterfs 相关参数：
[root@mystorage2 tmp]# getfattr -d -m '.*'  /storage/brick2
getfattr: Removing leading '/' from absolute path names
 file: storage/brick2
trusted.gfid=0sAAAAAAAAAAAAAAAAAAAAAQ==
trusted.glusterfs.dht=0sAAAAAQAAAAAAAAAAf////g==
trusted.glusterfs.dht.commithash="3168624641"
trusted.glusterfs.quota.dirty=0sMAA=
trusted.glusterfs.quota.size.1=0sAAAAAATiAAAAAAAAAAAAAwAAAAAAAAAE
trusted.glusterfs.volume-id=0sEZKGliY6THqhVVEVrykiHw==

 在 mystorage1 上执行配置 glusterfs 参数和上述一样

setfattr -n trusted.gfid -v 0sAAAAAAAAAAAAAAAAAAAAAQ== /storage/brick2
setfattr -n trusted.glusterfs.dht -v 0sAAAAAQAAAAAAAAAAf////g== /storage/brick2
setfattr -n trusted.glusterfs.dht.commithash -v "3168624641" /storage/brick2
setfattr -n trusted.glusterfs.quota.dirty -v 0sMAA= /storage/brick2
setfattr -n trusted.glusterfs.quota.size.1 -v 0sAAAAAATiAAAAAAAAAAAAAwAAAAAAAAAE /storage/brick2
setfattr -n trusted.glusterfs.volume-id -v 0sEZKGliY6THqhVVEVrykiHw== /storage/brick2

[root@mystorage1 ~]# /etc/init.d/glusterd restart
Starting glusterd:                                         [  OK  ]


[root@mystorage1 ~]# gluster volume heal gv2 info
Brick mystorage1:/storage/brick2
Status: Connected
Number of entries: 0

Brick mystorage2:/storage/brick2
/data
Status: Connected
Number of entries: 1        # 显示一个条目在修复，自动修复完成后会为 0

Brick mystorage3:/storage/brick1
Status: Connected
Number of entries: 0

Brick mystorage4:/storage/brick1
Status: Connected
Number of entries: 0

 自动修复同步完成后，查看新硬盘的数据同步过来了
[root@mystorage1 ~]# ll /storage/brick2
total 40012
-rw-r--r-- 2 root root 20480000 Jul 30 02:41 20M.file
-rw-r--r-- 2 root root 20480000 Jul 30 03:13 20M.file1
drwxr-xr-x 2 root root       21 Jul 30 09:14 data
```
