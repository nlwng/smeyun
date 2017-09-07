<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1 firwall介绍](#1-firwall介绍)
	- [1.1 静态防火墙](#11-静态防火墙)
- [2 firwall解析](#2-firwall解析)
	- [2.1 区域](#21-区域)
		- [2.1.1 预定义的服务](#211-预定义的服务)
		- [2.1.2 端口和协议](#212-端口和协议)
		- [2.1.3 ICMP 阻塞](#213-icmp-阻塞)
		- [2.1.4 伪装](#214-伪装)
		- [2.1.5 端口转发](#215-端口转发)
	- [2.2 可用区域](#22-可用区域)
		- [2.2.1 丢弃](#221-丢弃)
		- [2.2.2 阻塞](#222-阻塞)
		- [2.2.3 公开](#223-公开)
		- [2.2.4 外部](#224-外部)
		- [2.2.5 隔离区（dmz）](#225-隔离区dmz)
		- [2.2.6 工作](#226-工作)
		- [2.2.7 家庭](#227-家庭)
		- [2.2.8 内部](#228-内部)
		- [2.2.9 受信任的](#229-受信任的)
	- [2.3 区域使用](#23-区域使用)
		- [2.3.1 配置增加区域](#231-配置增加区域)
		- [2.3.2 为网络连接设置或者修改区域](#232-为网络连接设置或者修改区域)
		- [2.3.3 NetworkManager 控制的网络连接](#233-networkmanager-控制的网络连接)
		- [2.3.4 由脚本控制的网络](#234-由脚本控制的网络)
		- [2.3.5 使用firewalld](#235-使用firewalld)
			- [2.3.5.1 firewall-cmd](#2351-firewall-cmd)
				- [2.3.5.1.1 处理运行时区域](#23511-处理运行时区域)
				- [2.3.5.1.2 处理永久区域](#23512-处理永久区域)
				- [2.3.5.1.3 直接选项](#23513-直接选项)
- [firewalld 特性](#firewalld-特性)

<!-- /TOC -->
# 1 firwall介绍
## 1.1 静态防火墙
如果你想使用自己的 iptables 和 ip6tables 静态防火墙规则, 那么请安装 iptables-services  
并且禁用 firewalld ，启用 iptables 和ip6tables
```
yum install iptables-services
systemctl mask firewalld.service
systemctl enable iptables.service
systemctl enable ip6tables.service

systemctl stop firewalld.service
systemctl start iptables.service
systemctl start ip6tables.service
```

# 2 firwall解析
## 2.1 区域
网络区域定义了网络连接的可信等级。这是一个一对多的关系,  这意味着一次连接可以仅仅是
一个区域的一部分，而一个区域可以用于很多连接
### 2.1.1 预定义的服务
服务是端口和/或协议入口的组合。备选内容包括 netfilter 助手模块以及 IPv4、IPv6地址
### 2.1.2 端口和协议
定义了 tcp 或 udp 端口，端口可以是一个端口或者端口范围。
### 2.1.3 ICMP 阻塞
可以选择 Internet 控制报文协议的报文。这些报文可以是信息请求亦可是对信息请求或错误条件创建的响应
### 2.1.4 伪装
私有网络地址可以被映射到公开的IP地址。这是一次正规的地址转换
### 2.1.5 端口转发
端口可以映射到另一个端口以及/或者其他主机

## 2.2 可用区域
由firewalld 提供的区域按照从不信任到信任的顺序排序
### 2.2.1 丢弃
任何流入网络的包都被丢弃，不作出任何响应。只允许流出的网络连接
### 2.2.2 阻塞
任何进入的网络连接都被拒绝，并返回 IPv4 的 icmp-host-prohibited 报文或者 IPv6  
的 icmp6-adm-prohibited 报文。只允许由该系统初始化的网络连接
### 2.2.3 公开
用以可以公开的部分。你认为网络中其他的计算机不可信并且可能伤害你的计算机，只允许选中的连接接入
### 2.2.4 外部
用在路由器等启用伪装的外部网络。你认为网络中其他的计算机不可信并且可能伤害你的计算机。只允许选中的连接接入
### 2.2.5 隔离区（dmz）
用以允许隔离区（dmz）中的电脑有限地被外界网络访问。只接受被选中的连接
### 2.2.6 工作
用在工作网络。你信任网络中的大多数计算机不会影响你的计算机。只接受被选中的连接
### 2.2.7 家庭
用在家庭网络。你信任网络中的大多数计算机不会影响你的计算机。只接受被选中的连接
### 2.2.8 内部
用在内部网络。你信任网络中的大多数计算机不会影响你的计算机。只接受被选中的连接
### 2.2.9 受信任的
允许所有网络连接

## 2.3 区域使用
### 2.3.1 配置增加区域
firewalld 配置工具来配置或者增加区域，以及修改配置  
工具有例如 firewall-config 这样的图形界面工具，firewall-cmd 这样的命令行工具，以及D-BUS接口

### 2.3.2 为网络连接设置或者修改区域
```
区域设置以 ZONE= 选项 存储在网络连接的ifcfg文件中。如果这个选项缺失或者为空，firewalld 将使用配置的默认区域。
如果这个连接受到 NetworkManager 控制，你也可以使用 nm-connection-editor 来修改区域。
```
### 2.3.3 NetworkManager 控制的网络连接
```
当 firewalld 由 systemd 或者 init 脚本启动或者重启后，firewalld 将通知 NetworkManager 把网络连接增加到区域。
```
### 2.3.4 由脚本控制的网络
```
对于由网络脚本控制的连接有一条限制：没有守护进程通知 firewalld 将连接增加到区域。
这项工作仅在 ifcfg-post 脚本进行。因此，此后对网络连接的重命名将不能被应用到firewalld。同样，
在连接活动时重启 firewalld 将导致与其失去关联。现在有意修复此情况。最简单的是将全部未配置连接加入默认区域。
```
### 2.3.5 使用firewalld
你可以通过图形界面工具 firewall-config 或者命令行客户端 firewall-cmd 启用或者关闭防火墙特性。

#### 2.3.5.1 firewall-cmd
```
状态：firewall-cmd --state
firewall-cmd --state && echo "Running" || echo "Not running"

加载：firewall-cmd --reload
获取区域：firewall-cmd --get-zones
获取所有支持的服务：firewall-cmd --get-services
获取所有支持的ICMP类型：firewall-cmd --get-icmptypes
列出全部启用的区域的特性：firewall-cmd --list-all-zones
输出区域 <zone> 全部启用的特性：firewall-cmd [--zone=<zone>] --list-all
获取默认区域的网络设置：firewall-cmd --get-default-zone
设置默认区域：firewall-cmd --set-default-zone=<zone>
获取活动的区域：firewall-cmd --get-active-zones
将接口增加到区域：firewall-cmd [--zone=<zone>] --add-interface=<interface>
修改接口所属区域：firewall-cmd [--zone=<zone>] --change-interface=<interface>
从区域中删除一个接口：firewall-cmd [--zone=<zone>] --remove-interface=<interface>
查询区域中是否包含某接口：firewall-cmd [--zone=<zone>] --query-interface=<interface>
列举区域中启用的服务：firewall-cmd [ --zone=<zone> ] --list-services
启用应急模式阻断所有网络连接，以防出现紧急状况：firewall-cmd --panic-on
禁用应急模式：firewall-cmd --panic-off
查询应急模式：firewall-cmd --query-panic
此命令返回应急模式的状态：firewall-cmd --query-panic && echo "On" || echo "Off"
```

##### 2.3.5.1.1 处理运行时区域
```
处理运行时区域：
运行时模式下对区域进行的修改不是永久有效的。重新加载或者重启后修改将失效
启用区域中的一种服务：firewall-cmd [--zone=<zone>] --add-service=<service> [--timeout=<seconds>]
使区域中的 ipp-client 服务生效60秒:firewall-cmd --zone=home --add-service=ipp-client --timeout=60
启用默认区域中的http服务:firewall-cmd --add-service=http
禁用区域中的某种服务：firewall-cmd [--zone=<zone>] --remove-service=<service>
禁止 home 区域中的 http 服务:firewall-cmd --zone=home --remove-service=http
查询区域中是否启用了特定服务：firewall-cmd [--zone=<zone>] --query-service=<service>
启用区域端口和协议组合：
firewall-cmd [--zone=<zone>] --add-port=<port>[-<port>]/<protocol> [--timeout=<seconds>]
禁用端口和协议组合：
firewall-cmd [--zone=<zone>] --remove-port=<port>[-<port>]/<protocol>
查询区域中是否启用了端口和协议组合：
firewall-cmd [--zone=<zone>] --query-port=<port>[-<port>]/<protocol>
启用区域中的 IP 伪装功能:
firewall-cmd [--zone=<zone>] --add-masquerade
禁用区域中的 IP 伪装：
firewall-cmd [--zone=<zone>] --remove-masquerade
查询区域的伪装状态：
firewall-cmd [--zone=<zone>] --query-masquerade
启用区域的 ICMP 阻塞功能：
firewall-cmd [--zone=<zone>] --add-icmp-block=<icmptype>
禁止区域的 ICMP 阻塞功能：
firewall-cmd [--zone=<zone>] --remove-icmp-block=<icmptype>
查询区域的 ICMP 阻塞功能：
firewall-cmd [--zone=<zone>] --query-icmp-block=<icmptype>
阻塞区域的响应应答报文:
firewall-cmd --zone=public --add-icmp-block=echo-reply
在区域中启用端口转发或映射：
firewall-cmd [--zone=<zone>] --add-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> }
禁止区域的端口转发或者端口映射：
firewall-cmd [--zone=<zone>] --remove-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> }
查询区域的端口转发或者端口映射：
firewall-cmd [--zone=<zone>] --query-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> }
将区域 home 的 ssh 转发到 127.0.0.2：
firewall-cmd --zone=home --add-forward-port=port=22:proto=tcp:toaddr=127.0.0.2
```
##### 2.3.5.1.2 处理永久区域
```
处理永久区域：
获取永久选项所支持的服务
firewall-cmd --permanent --get-services
获取永久选项所支持的ICMP类型列表
firewall-cmd --permanent --get-icmptypes
获取支持的永久区域
firewall-cmd --permanent --get-zones
启用区域中的服务
firewall-cmd --permanent [--zone=<zone>] --add-service=<service>
禁用区域中的一种服务
firewall-cmd --permanent [--zone=<zone>] --remove-service=<service>
查询区域中的服务是否启用
firewall-cmd --permanent [--zone=<zone>] --query-service=<service>
永久启用 home 区域中的 ipp-client 服务
firewall-cmd --permanent --zone=home --add-service=ipp-client
永久启用区域中的一个端口-协议组合
firewall-cmd --permanent [--zone=<zone>] --add-port=<port>[-<port>]/<protocol>
永久禁用区域中的一个端口-协议组合
firewall-cmd --permanent [--zone=<zone>] --remove-port=<port>[-<port>]/<protocol>
查询区域中的端口-协议组合是否永久启用
firewall-cmd --permanent [--zone=<zone>] --query-port=<port>[-<port>]/<protocol>
永久启用 home 区域中的 https (tcp 443) 端口
firewall-cmd --permanent --zone=home --add-port=443/tcp
永久启用区域中的伪装
firewall-cmd --permanent [--zone=<zone>] --add-masquerade
永久禁用区域中的伪装
firewall-cmd --permanent [--zone=<zone>] --remove-masquerade
查询区域中的伪装的永久状态
firewall-cmd --permanent [--zone=<zone>] --query-masquerade
永久启用区域中的ICMP阻塞
firewall-cmd --permanent [--zone=<zone>] --add-icmp-block=<icmptype>
永久禁用区域中的ICMP阻塞
firewall-cmd --permanent [--zone=<zone>] --remove-icmp-block=<icmptype>
查询区域中的ICMP永久状态
firewall-cmd --permanent [--zone=<zone>] --query-icmp-block=<icmptype>
阻塞公共区域中的响应应答报文:
firewall-cmd --permanent --zone=public --add-icmp-block=echo-reply
在区域中永久启用端口转发或映射
firewall-cmd --permanent [--zone=<zone>] --add-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> }
永久禁止区域的端口转发或者端口映射
firewall-cmd --permanent [--zone=<zone>] --remove-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> }
查询区域的端口转发或者端口映射状态
firewall-cmd --permanent [--zone=<zone>] --query-forward-port=port=<port>[-<port>]:proto=<protocol> { :toport=<port>[-<port>] | :toaddr=<address> | :toport=<port>[-<port>]:toaddr=<address> }
将 home 区域的 ssh 服务转发到 127.0.0.2
firewall-cmd --permanent --zone=home --add-forward-port=port=22:proto=tcp:toaddr=127.0.0.2
```

##### 2.3.5.1.3 直接选项
```
将命令传递给防火墙:
firewall-cmd --direct --passthrough { ipv4 | ipv6 | eb } <args>
为表 <table> 增加一个新链 <chain> :
firewall-cmd --direct --add-chain { ipv4 | ipv6 | eb } <table> <chain>
从表 <table> 中删除链 <chain>:
firewall-cmd --direct --remove-chain { ipv4 | ipv6 | eb } <table> <chain>
查询 <chain> 链是否存在与表 <table>. 如果是，返回0,否则返回1:
firewall-cmd --direct --query-chain { ipv4 | ipv6 | eb } <table> <chain>
获取用空格分隔的表 <table> 中链的列表:
firewall-cmd --direct --get-chains { ipv4 | ipv6 | eb } <table>
为表 <table> 增加一条参数为 <args> 的链 <chain> ，优先级设定为 <priority>:
firewall-cmd --direct --add-rule { ipv4 | ipv6 | eb } <table> <chain> <priority> <args>
从表 <table> 中删除带参数 <args> 的链 <chain>:
firewall-cmd --direct --remove-rule { ipv4 | ipv6 | eb } <table> <chain> <args>
查询 带参数 <args> 的链 <chain> 是否存在表 <table> 中. 如果是，返回0,否则返回1:
firewall-cmd --direct --query-rule { ipv4 | ipv6 | eb } <table> <chain> <args>
获取表 <table> 中所有增加到链 <chain> 的规则，并用换行分隔:
firewall-cmd --direct --get-rules { ipv4 | ipv6 | eb } <table> <chain>

````
# firewalld 特性
