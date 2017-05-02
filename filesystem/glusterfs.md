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

<!-- /TOC -->

# GlusterFS
GlusterFS适合存储大文件，小文件性能较差
## 1 安装
## 1.1 centos6.8环境下安装使用
vim /etc/hosts  
```
10.0.0.51 node01
10.0.0.52 node02
10.0.0.53 node03
10.0.0.54 node04
```

### 1.1.1 安装GlusterFS  
yum -y install xfsprogs wget fuse fuse-libs  
yum -y install centos-release-gluster38.noarch  
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-Gluster-3.8.repo  
yum --enablerepo=centos-gluster38,epel -y install glusterfs-server  

/etc/rc.d/init.d/glusterd start    
chkconfig glusterd on
gluster peer status  

### 1.1.2 分布式配置
mkdir -p /glusterfs/distributed  

创建集群:[node01]  
增加集群:  
gluster peer probe node02  

查看节点:  
gluster peer status  

创建卷:  
```
gluster volume create vol_distributed transport tcp \
node01:/glusterfs/distributed \
node02:/glusterfs/distributed force
```

启动卷:  
gluster volume start vol_distributed   

查看卷信息:  
gluster volume info  

### 1.1.3 复制卷配置
Replicated:复制式卷，类似raid1，replica数必须等于volume中brick所包含的存储服务器数，可用性高。  

创建目录:  
mkdir /glusterfs/replica  
配置节点:  
gluster peer probe node02  
查看节点:   
gluster peer status  

创建卷:  
gluster volume create vol_replica replica 2 transport tcp \
node01:/glusterfs/replica \
node02:/glusterfs/replica force  

启动卷:   
gluster volume start vol_replica  

查看卷:  
gluster volume info

### 1.1.4 磁盘条带化配置
Stripe相当于RAID0，即分片存储，文件被划分成固定长度的数据分片以Round-Robin轮转方式存储在所有存储节点。Stripe所有存储节点组成完整的名字空间，查找文件时需要询问所有节点，这点非常低效。读写数据时，Stripe涉及全部分片存储节点，操作可以在多个节点之间并发执行，性能非常高。Stripe通常与AFR组合使用，构成RAID10/RAID01，同时获得高性能和高可用性，当然存储利用率会低于50%。

创建目录:  
mkdir /glusterfs/striped  
配置节点:  
gluster peer probe node02  
查看节点:  
gluster peer status  

创建卷:  
gluster volume create vol_striped stripe 2 transport tcp \
node01:/glusterfs/striped \
node02:/glusterfs/striped force

启动卷:  
gluster volume start vol_striped  

查看卷:  
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
创建目录:  
mkdir /glusterfs/dist-replica    
配置节点:  
gluster peer probe node02  
gluster peer probe node03   
gluster peer probe node04   
查看节点:  
gluster peer status  

创建卷:  
gluster volume create  vol_dist-replica replica 2 transport tcp \
node01:/glusterfs/dist-replica \
node02:/glusterfs/dist-replica \
node03:/glusterfs/dist-replica \
node04:/glusterfs/dist-replica force

启动卷:  
gluster volume start vol_dist-replica   

查看卷:  
gluster volume info

### 1.1.6 磁条化+复制
Distributed Striped:分布式的条带卷，volume中brick所包含的存储服务器数必须是stripe的倍数(>=2倍)，兼顾分布式和条带式的功能。  
```
+----------------------+          |          +----------------------+
| [GlusterFS Server#1] |10.0.0.51 | 10.0.0.52| [GlusterFS Server#2] |
|   node01             +----------+----------+   node02.            |
|                      |          |          |                      |
+----------------------+          |          +----------------------+
                                  |
+----------------------+          |          +----------------------+
| [GlusterFS Server#3] |10.0.0.53 | 10.0.0.54| [GlusterFS Server#4] |
|   node03             +----------+----------+   node04             |
|                      |                     |                      |
+----------------------+                     +----------------------+
```
创建目录:  
mkdir /glusterfs/strip-replica   
配置节点:  
gluster peer probe node02    
gluster peer probe node03    
gluster peer probe node04    
查看节点:  
gluster peer status  

创建卷:  
gluster volume create vol_strip-replica stripe 2 replica 2 transport tcp \
node01:/glusterfs/strip-replica \
node02:/glusterfs/strip-replica \
node03:/glusterfs/strip-replica \
node04:/glusterfs/strip-replica force  

启动卷:  
gluster volume start vol_strip-replica    

查看卷:  
gluster volume info  

### 1.1.7 配置GlusterFS客户端硬盘
yum -y install centos-release-gluster38  
yum -y install glusterfs glusterfs-fuse  

配置好hosts以后直接配置挂载:  
mount -t glusterfs node01:/vol_distributed /mnt   

### 1.1.8 GlusterFS卷维护
删除集群[本文以vol_distributed为列]  
#### 1.1.7.1 删除节点和卷
启动/停止/删除卷:  
gluster volume start vol_distributed  
gluster volume stop vol_distributed  
gluster volume delete vol_distributed  

删除节点:  
gluster peer status  
gluster peer detach node02  

列出集群中的所有卷:  
gluster volume list  

查看集群中的卷信息:  
gluster volume info vol_distributed  

查看集群中的卷状态:  
gluster volume status vol_distributed  

#### 1.1.7.2 配额管理
开启/关闭系统配额:  
gluster volume quota vol_distributed enable/disable  

设置(重置)目录配额:  
gluster volume quota vol_distributed limit-usage /img limit-value
gluster volume quota img limit-usage /quota 10GB

配额查看:  
gluster volume quota vol_distributed list

#### 1.1.7.3 地域复制
gluster volume geo-replication MASTER SLAVE start/status/stop  

地域复制是系统提供的灾备功能，能够将系统的全部数据进行异步的增量备份到另外的磁盘中:  

将img卷中的所有内容备份到10.8下的/data1/brick1 中的task,备份目标不能是系统中的Brick  
gluster volume geo-replication img 192.168.10.8:/data1/brick1 start  

#### 1.1.7.4 平衡卷
平衡布局是很有必要的，因为布局结构是静态的，当新的bricks 加入现有卷，新创建的文件会分布到旧的bricks 中，所以需要平衡布局结构，使新加入的bricks 生效。布局平衡只是使新布局生效，并不会在新的布局移动老的数据，如果你想在新布局生效后，重新平衡卷中的数据，还需要对卷中的数据进行平衡  

当你扩展或者缩小卷之后，需要重新在服务器直接重新平衡一下数据，重新平衡的操作被分为两个步骤:  
1.Fix Layout:  
修改扩展或者缩小后的布局，以确保文件可以存储到新增加的节点中  
2.Migrate Data   
重新平衡数据在新加入bricks 节点之后  

先重新修改布局然后移动现有的数据(重新平衡)  
gluster volume rebalance vol_distributed fix-layout start  
gluster volume rebalance vol_distributed migrate-data start  

gluster volume rebalance vol_distributed start  
你可以在在平衡过程中查看平衡信息  
gluster volume rebalance vol_distributed status  
你也可以暂停平衡，再次启动平衡的时候会从上次暂停的地方继续开始平衡    
gluster volume rebalance vol_distributed stop  

#### 1.1.7.5 I/O 信息查看
提供接口查看一个卷中的每一个brick 的IO 信息   
Profile Command  
启动profiling，之后则可以进行IO 信息查看  
gluster volume profile VOLNAME start  
查看IO 信息，可以查看到每一个Brick 的IO 信息  
gluster volume profile VOLNAME info  
查看结束之后关闭profiling 功能  
gluster volume profile VOLNAME stop  

#### 1.1.7.6 top监控
Top command 允许你查看bricks 的性能例如:  
read, write, fileopen calls, file read calls, file,write calls,directory open calls, and directory real calls  
查看打开的fd  
gluster volume top VOLNAME open [brick BRICK-NAME] [list-cnt cnt]   
查看调用次数最多的读调用   
gluster volume top VOLNAME read [brick BRICK-NAME] [list-cnt cnt]  
查看调用次数最多的写调用   
gluster volume top VOLNAME write [brick BRICK-NAME] [list-cnt cnt]  
查看次数最多的目录调用   
gluster volume top VOLNAME opendir [brick BRICK-NAME] [list-cnt cnt]   
查看次数最多的目录调用   
gluster volume top VOLNAME readdir [brick BRICK-NAME] [list-cnt cnt]  
查看每个Brick 的读性能  
gluster volume top VOLNAME read-perf [bs blk-size count count]   [brickBRICK-NAME] [list-cnt cnt]    
查看每个Brick 的写性能  
gluster volume top VOLNAME write-perf [bs blk-size count count] [brickBRICK-NAME] [list-cnt cnt]   

#### 1.1.7.7 性能优化配置选项
默认是10% 磁盘剩余告警  
gluster volume set arch-img cluster.min-free-disk  
默认是5% inodes 剩余告警  
gluster volume set arch-img cluster.min-free-inodes   
默认4，预读取的数量  
gluster volume set img performance.read-ahead-page-count 8  
默认16 io 操作的最大线程  
gluster volume set img performance.io-thread-count 16  
默认42s  
gluster volume set arch-img network.ping-timeout 10  
默认128M 或32MB  
gluster volume set arch-img performance.cache-size 2GB   
开启目录索引的自动愈合进程  
gluster volume set arch-img cluster.self-heal-daemon on    
自动愈合的检测间隔，默认为600s #3.4.2版本才有  
gluster volume set arch-img cluster.heal-timeout 300  
默认是1M 能提高写性能单个文件后写缓冲区的大小默认1M   
gluster volume set arch-img performance.write-behind-window-size 256MB  
