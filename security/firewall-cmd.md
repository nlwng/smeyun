
# 2 firwall解析
## 2.1 区域
```
网络区域定义了网络连接的可信等级。这是一个一对多的关系，
这意味着一次连接可以仅仅是一个区域的一部分，而一个区域可以用于很多连接
```
## 2.2 预定义的服务
```
服务是端口和/或协议入口的组合。备选内容包括 netfilter 助手模块以及 IPv4、IPv6地址
```
## 2.3 端口和协议
```
定义了 tcp 或 udp 端口，端口可以是一个端口或者端口范围。
```

# 3 firwall cli
```
firewall-cmd --reload
firewall-cmd --add-service=http
显示状态：
firewall-cmd --state
查看所有打开的端口：
firewall-cmd --zone=public --list-ports
查看区域信息:  
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=80/tcp --permanent （--permanent永久生效，没有此参数重启后失效）
查看:
firewall-cmd --zone= public --query-port=80/tcp
删除:
#firewall-cmd --zone= public --remove-port=80/tcp --permanent
添加某接口至某信任等级，譬如添加 eth0 至 public，再永久生效
#firewall-cmd --zone=public --add-interface=eth0 --permanent
设置 public 为默认的信任级别
firewall-cmd --set-default-zone=public
列出 dmz 级别的被允许的进入端口
firewall-cmd --zome=dmz --list-ports
```
# 4 firewall example
```
firewall-cmd --zone=public --query-service=nginx
firewall-cmd --permanent --zone=public --add-port=8080-8081/tcp

允许某范围的 udp 端口至 public 级别，并永久生效
firewall-cmd --zome=public --add-port=5060-5059/udp --permanent

添加 smtp 服务至 work zone
firewall-cmd --zone=work --add-service=smtp
firewall-cmd --zone=work --remove-service=smtp

配置 ip 地址伪装
firewall-cmd --zone=external --query-masquerade
firewall-cmd --zone=external --add-masquerade
firewall-cmd --zone=external --remove-masquerade

端口转发
firewall-cmd --zone=external --add-masquerade
转发 22 端口数据至另一 ip 的 2055 端口上
firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toport=2055:toaddr=192.168.1.100
然后转发 tcp 22 端口至 3753
firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toport=3753
转发 22 端口数据至另一个 ip 的相同端口上
firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toaddr=192.168.1.100

永久開放 ftp 服務:
# firewall-cmd --add-service=ftp --permanent
永久關閉:
# firewall-cmd --remove-service=ftp --permanent
查看状态：
#firewall-cmd --list-all
在FirewallD 的服務名稱:
#firewall-cmd --get-service
自行加入要開放的 Port:
# firewall-cmd --add-port=3128/tcp
允许某个IP短访问3306：
#firewall-cmd --permanent --zone=public --add-rich-rule 'rule family=“ipv4” source address=“192.168.0.4/24” port port protocal=“tcp” port=“3306” accept'

firewall-cmd --permanent --add-rich-rule 'rule family=ipv4 source address=172.16.26.0/24 protocol=tcp accept'
查看当前区域：
firewall-cmd --get-default-zone

把Firewalld防火墙服务中eno16777728网卡的默认区域修改为external，重启后再生效：
[root@linuxprobe ~]# firewall-cmd --permanent --zone=external --change-interface=eno16777728
success
[root@linuxprobe ~]# firewall-cmd --get-zone-of-interface=eno16777728
public
[root@linuxprobe ~]# firewall-cmd --permanent --get-zone-of-interface=eno16777728
external

把Firewalld防火墙服务的当前默认zone区域设置为public：
[root@linuxprobe ~]# firewall-cmd --set-default-zone=public
success
[root@linuxprobe ~]# firewall-cmd --get-default-zone
public

启动/关闭Firewalld防火墙服务的应急状况模式，阻断一切网络连接
[root@linuxprobe ~]# firewall-cmd --panic-on
success
[root@linuxprobe ~]# firewall-cmd --panic-off
success

在Firewalld防火墙服务中配置一条富规则，拒绝所有来自于192.168.10.0/24网段的用户访问本机ssh服务（22端口）：
[root@linuxprobe ~]# firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" source address="192.168.10.0/24" service name="ssh" reject"
success
[root@linuxprobe ~]# firewall-cmd --reload
success

```