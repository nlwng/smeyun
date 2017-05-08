[TOC]
# 环境准备
##配置网络接口
``不同的节点配置不同的IP地址，如下为控制节点的配置``
将第一个接口配置为管理网络接口：

 IP 地址: 10.0.0.11

 子网掩码: 255.255.255.0 (or /24)

 默认网关: 10.0.0.1

 提供者网络接口使用一个特殊的配置，不分配给它IP地址。配置第二块网卡作为提供者网络：
 ``将其中的 INTERFACE_NAME替换为实际的接口名称,例如，eth1 或者*ens224*。``

 编辑``/etc/network/interfaces``文件包含以下内容：
```
#The provider network interface
auto INTERFACE_NAME
iface INTERFACE_NAME inet manual
up ip link set dev $IFACE up
down ip link set dev $IFACE down
```
##修改主机名
修改主机名，方便后期安装验证，以及解析
修改/etc/hostname文件，设置对应的主机名
如控制节点 设置为 controller
网络节点 设置为 net
计算节点 设置为compute1

然后命令修改：
```
# hostname controller
# hostname net
# hostname compute1
```

##配置主机名解析
设置节点主机名为
编辑 /etc/hosts 文件包含以下内容：
```
# controller
10.0.0.11       controller

# net
10.0.0.21        net
 
# compute1
10.0.0.31       compute1
 
# compute2
10.0.0.41       compute2
```
##配置域名解析
修改 /etc/resolvconf/resolv.conf.d/base文件，设置合适的DNS服服务器：
```
# nameserver 221.7.92.98
```

##设置软件源
如下例子(系统版本为ubuntu 14.04 阿里云源)：

备份
```
# mv /etc/apt/sources.list /etc/apt/sources.list.bak 
```
修改
```
# vim /etc/apt/sources.list 
```
```
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse

deb [arch=amd64] http://192.168.2.88:1888/ubuntu trusty-updates/mitaka main 
apt-get update 
apt-get install ubuntu-cloud-keyring
```

更新列表
```
# apt-get update 
```

##配置NTP服务
``控制节点作为内网NTP服务器``
安装软件包：
```
apt-get install chrony
```
编辑 /etc/chrony/chrony.conf 文件，按照你环境的要求，对下面的键进行添加，修改或者删除：
```
server controller iburst 
```
``使用NTP服务器的主机名或者IP地址替换 controller (这里设置的控制节点)``,配置支持设置多个 server 值
重启 NTP 服务：
```
service chrony restart
```
更改时区
```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
控制节点同步时间
```
ntpdate time.windows.com
```
所有节点同步（每台机器上执行）
```
chronyc sources
```

##OpenStack包
由于不同的发布日程，发行版发布 OpenStack 的包作为发行版的一部分，或使用其他方式。请在``所有节点``上执行这些程序。
启用OpenStack库

```
# apt-get install software-properties-common
# add-apt-repository cloud-archive:mitaka  #内网源不要执行这一句
```

在主机上升级包：
```
# apt-get update && apt-get dist-upgrade
```
安装 OpenStack 客户端：
```
# apt-get install python-openstackclient
```

##sql数据库
安装在控制节点
```
apt-get install mariadb-server python-pymysql
```
为数据库用户``root``设置适当的密码
创建并编辑 /etc/mysql/conf.d/openstack.cnf，然后完成如下动作：
```
[mysqld]
bind-address = 10.0.0.11
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
```
重启数据库服务：
```
service mysql restart
```
执行 mysql_secure_installation 脚本来对数据库进行安全加固
```
mysql_secure_installation
```
##NoSQL 数据库

安装MongoDB包：
```
# apt-get install mongodb-server mongodb-clients python-pymongo
```
编辑文件 /etc/mongodb.conf 并完成如下动作：

配置 bind_ip 使用控制节点管理网卡的IP地址。
```
crudini --set /etc/mongodb.conf '' bind_ip 10.0.0.11
```
默认情况下，MongoDB会在``/var/lib/mongodb/journal`` 目录下创建几个 1 GB 大小的日志文件。如果你想将每个日志文件大小减小到128MB并且限制日志文件占用的总空间为512MB，配置 smallfiles 的值：
```
crudini --set /etc/mongodb.conf '' smallfiles true
```
如果您修改 journaling 的配置，请停止 MongoDB 服务，删除 journal 的初始化文件，并启动服务：
```
# service mongodb stop
# rm /var/lib/mongodb/journal/prealloc.*
# service mongodb start
```
##消息队列
安装在控制节点
安装包：
```
# apt-get install rabbitmq-server
```
添加 openstack 用户：
```
# rabbitmqctl add_user openstack pass
```
给``openstack``用户配置写和读权限：
```
# rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

