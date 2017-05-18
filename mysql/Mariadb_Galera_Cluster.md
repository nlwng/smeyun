<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Mariadb Galera Cluster](#mariadb-galera-cluster)
	- [特性](#特性)

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
