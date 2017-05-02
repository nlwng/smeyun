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
		- [1.1.6 配置GlusterFS客户端硬盘](#116-配置glusterfs客户端硬盘)
		- [1.1.7 删除节点](#117-删除节点)

<!-- /TOC -->

# GlusterFS
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


### 1.1.6 配置GlusterFS客户端硬盘
yum -y install centos-release-gluster38  
yum -y install glusterfs glusterfs-fuse  

配置好hosts以后直接配置挂载:  
mount -t glusterfs node01:/vol_distributed /mnt   

### 1.1.7 删除节点
删除集群    
gluster peer detach node02  
