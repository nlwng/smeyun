
# 虚拟化
1.半虚拟 全虚拟  
cpu支持虚拟化， 虚拟机软件（例如kvm）是全虚拟化，仅需要模拟一部分硬件指令，虚机性能更高  
cpu不支持虚拟化， 虚拟机软件（例如xen）是半全虚拟化，需要模拟全部硬件指令，虚机性能要差些  

# nova原理
2.Nova Scheduler调度算法，计算节点分配资源原理  
2.1 调度算法默认的驱动类是FilterScheduler，其算法的原理是比较简单的，就是“过滤”和“称重”的过程  
2.2  计算可用计算节点的权值  
2.3 从权值最高的scheduler_host_subset_size个计算节点中随机选择一个计算节点作为创建虚拟机的节点  
2.4 更新选择的计算节点的硬件资源信息，为虚拟机预留资源  
ps：http://blog.csdn.net/qiuhan0314/article/details/43232223  



# Neutron
DVR：
顾名思义就是 Neutron 的 router 将不单单部署在网络节点上，所有启动了 Neutron L3 Agent 的节点，都会在必要时在节点上创建 Neutron router  
对应的 namepsace，并更新与 DVR router 相关的 Openflow 规则，从而完成 DVR router 在该节点上的部署。在计算节点上部署了 DVR router 后，  
E-W 方向上的流量不再需要将数据包发送到网络节点后再转发，而是有本地的 DVR router 直接进行跨子网的转发；N-S 方向上，对于绑定了 floating IP  
的虚机，其与外网通信时的数据包也将直接通过本地的 DVR router 进行转发。从而，Neutron 网络上的一些流量被分摊开，有效地减少了网络节点上的流量；  
通信不再必须通过网络节点，也提升了 Neutron 网络的抗单点失败的能力。  


DVR模式： 数据库交互实现本地转发
             -----------
             - network -
             -----------

    ------------          ------------
    . router   .   -->    . router   .
    .   |      .          .   |      .
    . network1 .          . network2 .
    .   |      .          .   |      .
    .   vm     .          .   vm     .
    ------------          ------------

ps：https://www.ibm.com/developerworks/cn/cloud/library/1509_xuwei_dvr/  
