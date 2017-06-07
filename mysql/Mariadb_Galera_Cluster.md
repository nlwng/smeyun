<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

	- [特性](#特性)
- [sharding-jdbc](#sharding-jdbc)
- [mysql proxy](#mysql-proxy)
- [DRBD](#drbd)
- [binlog](#binlog)
- [xtrabackup](#xtrabackup)

<!-- /TOC -->

 # Mariadb Galera Cluster

## 特性

```
(1).同步复制 Synchronous replication
(2).Active-active multi-master 拓扑逻辑
(3).可对集群中任一节点进行数据读写
(4).自动成员控制，故障节点自动从集群中移除
(5).自动节点加入
(6).真正并行的复制，基于行级
(7).直接客户端连接，原生的 MySQL 接口
(8).每个节点都包含完整的数据副本
(9).多台数据库中数据同步由 wsrep 接口实现
```

# sharding-jdbc

轻量级数据库分库分表中间件

# mysql proxy

# DRBD

# binlog

开启binlog
```
show variables like 'log_bin';
show binary logs;

[mysqld]
log-bin=mysql-bin
expire_logs_days = 30
```
手动清理binglog
```
PURGE MASTER LOGS BEFORE DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY);   //删除10天前的MySQL binlog
show master logs;
PURGE MASTER LOGS TO 'MySQL-bin.010';  //清除MySQL-bin.010日志
PURGE MASTER LOGS BEFORE '2008-06-22 13:00:00';   //清除2008-06-22 13:00:00前binlog日志
PURGE MASTER LOGS BEFORE DATE_SUB( NOW( ), INTERVAL 3 DAY);  //清除3天前binlog日志BEFORE
```
# xtrabackup
