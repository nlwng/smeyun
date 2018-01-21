<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [tcpdump](#tcpdump)
	- [抓包](#抓包)
- [ovs-vsctl](#ovs-vsctl)
- [nmap](#nmap)
	- [扫描](#扫描)
- [arpping](#arpping)
- [libnet](#libnet)
- [arpison](#arpison)
- [wireshark](#wireshark)
- [fping](#fping)
- [arpspoof](#arpspoof)
- [ifstat](#ifstat)
- [mtr](#mtr)
- [nethogs](#nethogs)

<!-- /TOC -->

# tcpdump
check complain mode   
tcpdump: test1.log: Permission denied  
开始以为是用户权限的问题，后来换用root账户还是不行，经搜索，是AppArmor的问题  
apt-get install apparmor-utils
sudo aa-complain /usr/sbin/tcpdump  

截取gre数据包  
tcpdump |grep -i "gre"  

## 抓包
tcpdump -i eth0 -nn 'host 192.168.2.249' -w check.cap
tcpdump -i eth0 -nn 'host 192.168.2.246' -w check.cap
tcpdump  -p arp
tcpdump host 192.168.2.1 -w check.cap
抓取网口eth0上源mac地址或目的mac地址为00:21:85:6C:D9:A3的所有数据包  
tcpdump -i eth0 ether src or dst 34:97:f6:99:a1:ed -w check.cap   

sudo tcpdump -n -r arp_check222.cap|awk -F '[,]+' '{print $2}'|sort|uniq -c|sort -n  

# ovs-vsctl
查看 open vswitch 的网络状态:ovs-vsctl show  
查看网桥 br-tun 的接口状况：ovs-ofctl show br-tun  
查看网桥 br-tun 的流表：ovs-ofctl dump-flows br-tun   
添加网桥：#ovs-vsctl add-br br0  
将物理网卡挂接到网桥：#ovs-vsctl add-port br0 eth0   

列出 open vswitch 中的所有网桥：#ovs-vsctl list-br  
判断网桥是否存在：#ovs-vsctl br-exists br0  
列出网桥中的所有端口：#ovs-vsctl list-ports br0  
列出所有挂接到网卡的网桥：#ovs-vsctl port-to-br eth0  
删除网桥上已经挂接的网口：#vs-vsctl del-port br0 eth0  
删除网桥：#ovs-vsctl del-br br0  


# nmap
## 扫描
nmap -sP 192.168.2.0/24

# arpping

用法举例：比如我的ip 192.168.1.101 网关:192.168.1.1  
arping -U -I eth0 -s 192.168.2.88 192.168.2.1  
arping -U -I eth0 -s 192.168.1.229 192.168.1.1  

# libnet
wget https://nchc.dl.sourceforge.net/project/libnet-dev/libnet-1.1.6.tar.gz  
tar zxvf libnet-1.1.6.tar.gz  
cd libnet-1.1.6/  
sudo ./configure  
sudo make  
sudo make install  


# arpison
gcc arpoison.c /usr/local/lib/libnet.a -o arpoison  
sudo ln -sf arpoison /bin/arpoison  

比如我想防止arp 攻击
sudo arpoison -i eth0 -d 192.168.1.1 -s 192.168.1.101 -t ff:ff:ff:ff:ff:ff -r 00:1c:bf:03:9f:c7

比如我想攻击192.168.1.50的机器不让他上网
sudo arpoison -i eth0 -d 192.168.1.50 -s 192.168.1.1 -t ff:ff:ff:ff:ff:ff -r 00:1c:bf:03:9f:c7
sudo arpoison -i enp4s0 -d 192.168.2.249 -s 192.168.2.1 -t ff:ff:ff:ff:ff:ff -r 1c:1b:0d:2d:94:87

# wireshark  
sudo apt-add-repository ppa:wireshark-dev/stable  
sudo apt-get update  
sudo apt-get install wireshark  
sudo dpkg-reconfigure wireshark-common  

# fping
在一个局域网中，我们如果要对某个主机进行断网攻击的话，我们先要查看局域网中的ip  
fping –asg 10.10.10.0/24  

# arpspoof
进行断网攻击  
sudo arpspoof -i enp4s0 -t 192.168.2.252 192.168.2.254  
ettercap -Tq -i enp4s0  

# ifstat
流量监控;  
sudo atp-get install ifstat

#mtr
MTR 是一款强大的网络诊断工具，网络管理员使用 MTR 可以诊断和隔离网络问题，并且为上游 ISP 提供有用的网络状态报告。
```
apt-get install mtr-tiny
yum install mtr

mtr www.ubuntu.org
mtr --report www.ubuntu.org
mtr -rw example.com
```

#nethogs
按进程实时统计网络带宽利用率
```
centos:
yum install gcc-c++ libpcap-devel.x86_64 libpcap.x86_64 ncurses*

ubuntu:
apt-get install build-essential libncurses5-dev libpcap-dev

git clone https://github.com/raboof/nethogs.git
tar xf v0.8.1.tar.gz
cd ./nethogs-0.8.1/
make && sudo make install

5秒刷新一次：
nethogs -d 5
```
