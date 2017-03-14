FastDFS架构:
FastDFS架构包括 Tracker server和Storage server。
客户端请求Tracker server进行文件上传、下载，通过Tracker server调度最终由Storage server完成文件上传和下载。

Tracker server作用是负载均衡和调度，通过Tracker server在文件上传时可以根据一些策略找到Storage server提供文件上传服务。
可以将tracker称为追踪服务器或调度服务器。

Storage server作用是文件存储，客户端上传的文件最终存储在Storage服务器上，
Storage server没有实现自己的文件系统而是利用操作系统的文件系统来管理文件。可以将storage称为存储服务器。

Tracker集群:
astDFS集群中的Tracker server可以有多台，Tracker server之间是相互平等关系同时提供服务，Tracker server不存在单点故障。
客户端请求Tracker server采用轮询方式，如果请求的tracker无法提供服务则换另一个tracker。

Storage集群:
Storage集群采用了分组存储方式。storage集群由一个或多个组构成，集群存储总容量为集群中所有组的存储容量之和。
一个组由一台或多台存储服务器组成，组内的Storage server之间是平等关系，不同组的Storage server之间不会相互通信，
同组内的Storage server之间会相互连接进行文件同步，从而保证同组内每个storage上的文件完全一致的。一个组的存储容量为该组内存储服务器容量最小的那个，
由此可见组内存储服务器的软硬件配置最好是一致的。采用分组存储方式的好处是灵活、可控性较强。比如上传文件时，可以由客户端直接指定上传到的组也可以由tracker进行调度选择。
一个分组的存储服务器访问压力较大时，可以在该组增加存储服务器来扩充服务能力（纵向扩容）。当系统容量不足时，可以增加组来扩充存储容量（横向扩容）。


3.1 trackerServer
3.2 storageServer
3.3 nginx和fastDFS整合

#install libevent
yum -y install libevent

#install libfastcommonv1.0.7
git clone https://github.com/happyfish100/libfastcommon.git
cd libfastcommon/
./make.sh
./make.sh install

#only trackerServer storageServer,
