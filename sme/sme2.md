<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [安装](#安装)
	- [java](#java)
	- [redis](#redis)
	- [mariadb-10.1.23](#mariadb-10123)
		- [centos7](#centos7)
- [优化](#优化)
	- [网络优化](#网络优化)
	- [nginx](#nginx)
	- [数据库](#数据库)
	- [tomcat](#tomcat)

<!-- /TOC -->

# 安装
## java

```

```
## redis
```
cnetos6: make
cetnos7: make MALLOC=libc
cd src
make install PREFIX=/usr/local/redis

vim /usr/local/redis/etc/redis.conf
将daemonize的值改为yes

/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
```


## mariadb-10.1.23
### centos7
安装基本软件包  
yum install vim wget lsof gcc gcc-c++ -y  
yum install net-tools bind-utils -y  
yum install ncurses-devel openssl* bzip2 m4 -y  

cmake -DCMAKE_INSTALL_PREFIX=/data/mysql;make && make install  

设置开机启动  
cp /data/mysql/packaging/rpm-oel/mysqld.service /lib/systemd/system  
systemctl enable mysqld.service  
vim /etc/systemd/system/mysql.service  

# 优化

## 网络优化

```
表示开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击
net.ipv4.tcp_syncookies = 1
表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接
net.ipv4.tcp_tw_reuse = 1
表示开启TCP连接中TIME-WAIT sockets的快速回收
net.ipv4.tcp_tw_recycle = 1
修改系統默认的 TIMEOUT 时间
net.ipv4.tcp_fin_timeout = 30
表示当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时，改为20分钟
net.ipv4.tcp_keepalive_time = 1200
表示用于向外连接的端口范围。缺省情况下很小：32768到61000，改为10000到65000。（注意：这里不要将最低值设的太低，否则可能会占用掉正常的端口！）
net.ipv4.ip_local_port_range = 10000 65000
表示SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数
net.ipv4.tcp_max_syn_backlog = 8192
表示系统同时保持TIME_WAIT的最大数量，如果超过这个数字，TIME_WAIT将立刻被清除并打印警告信息。默 认为180000，改为6000。对于Apache、Nginx等服务器，上几行的参数可以很好地减少TIME_WAIT套接字数量，但是对于Squid，效果却不大。此项参数可以控制TIME_WAIT的最大数量，避免Squid服务器被大量的TIME_WAIT拖死。
net.ipv4.tcp_max_tw_buckets = 5000

记录的那些尚未收到客户端确认信息的连接请求的最大值。对于有128M内存的系统而言，缺省值是1024，小内存的系统则是128
net.ipv4.tcp_max_syn_backlog = 65536
每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 32768
```

## nginx
```
events {
    use epoll;
    worker_connections  65535;
}
```


## 数据库
```
max_connections     = 1000
key_buffer_size= 1024M
max_allowed_packet = 4M
table_cache = 1024
sort_buffer_size = 8M
read_buffer_size = 8M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 32M
thread_cache_size = 4
query_cache_size = 32M
thread_concurrency = 2

```
MySQL Cluster

## tomcat
maximumPoolSize: 600


vim /home/webapp/file/AccountSys/tomcat8/bin
JAVA_OPTS="-server -Xms1024m -Xmx1024m"
