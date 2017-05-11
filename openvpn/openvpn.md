
       	      +----------------------+
              | [  OpenVPN Server  ] |
          tap0|     dlp.srv.world    |eth0
              |                      |
              +-----------+----------+
         192.168.0.30:1194|br0
                          |
               192.168.0.1|
                   +------+-----+
-------------------|   Router   |---------------------
                   +------+-----+
                          |x.x.x.x:1194
          +---------------+--------------+    Internet
          |                              |
----------+------------------------------+------------
          |     +------------------+     |
          | tap0|                  |eth0 |
          +-----+    VPN Client    +-----+
     192.168.0.x|                  |10.0.0.10


#---------------------
Configure VPN Server
#---------------------

#Install OpenVPN
#install from EPEL
yum -y install epel-release
yum -y install openssl openssl-devel lzo
yum --enablerepo=epel -y install openvpn easy-rsa net-tools bridge-utils

#Create CA certificates
cd /usr/share/easy-rsa/2.0
#vi vars

# line 64: change to your own environment
export KEY_COUNTRY="CN"
export KEY_PROVINCE="Shanghai"
export KEY_CITY="Shanghai"
export KEY_ORG="SME"
export KEY_EMAIL="3835231@qq.com"
export KEY_OU="Server_World"


source ./vars
./clean-all
./build-ca

#------------------
#Name [EasyRSA]:Server-CA
#--------------------

#Create server certificates.
cd /usr/share/easy-rsa/2.0
./build-key-server server

#-------------------------
#Name [EasyRSA]:Server-CRT# change to any name you like
#-----------------------------------------

#Generate Diffie Hellman ( DH ) parameter.
cd /usr/share/easy-rsa/2.0
./build-dh

#Create client certificates.
cd /usr/share/easy-rsa/2.0
./build-key client01

#----------
#Name [EasyRSA]:neildev# change to any name you like
#-----------------

# confirm settings and proceed with yes
Sign the certificate? [y/n]: y
# proceed with yes
1 out of 1 certificate requests certified, commit? [y/n] y

#Configure and start OpenVPN server.
[root@dlp ~]# cp -pR /usr/share/easy-rsa/2.0/keys /etc/openvpn/keys
[root@dlp ~]# cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn/
[root@dlp ~]# vi /etc/openvpn/server.conf

# line 32: change if need (listening port)
port 1194
# line 35: uncomment tcp and comment out udp
proto tcp
;proto udp
# line 52: change to tap which uses bridge mode
dev tap0
;dev tun
# line 78: change path for certificates
ca keys/ca.crt
cert keys/server.crt
key keys/server.key
# line 85: change path for certificates
dh keys/dh2048.pem
# line 101: comment out
;server 192.168.0.0 255.255.255.0
# line 120: uncomment and change ⇒ [VPN server's IP] [subnetmask] [the range of IP for client]
server-bridge 192.168.0.30 255.255.255.0 192.168.0.150 192.168.0.199
# line 231: keepalive settings
keepalive 10 120
# line 256: enable compress
comp-lzo
# line 274: enable persist options
persist-key
persist-tun
# line 289: uncomment and specify logs
log /var/log/openvpn.log
log-append /var/log/openvpn.log
# line 299: specify log level (0 - 9, 9 means debug lebel)
verb 3

[root@dlp ~]# cp /usr/share/doc/openvpn-*/sample/sample-scripts/bridge-start /etc/openvpn/openvpn-startup
[root@dlp ~]# cp /usr/share/doc/openvpn-*/sample/sample-scripts/bridge-stop /etc/openvpn/openvpn-shutdown
[root@dlp ~]# chmod 755 /etc/openvpn/openvpn-startup /etc/openvpn/openvpn-shutdown
[root@dlp ~]# vi /etc/openvpn/openvpn-startup


# line 17-20: change
eth="eth0" # change if need
eth_ip="192.168.0.30"# IP for bridge interface
eth_netmask="255.255.255.0"# subnet mask
eth_broadcast="192.168.0.255"# broadcast address
# add follows to the end: define gateway
eth_gw="192.168.0.1"
route add default gw $eth_gw

vi /etc/rc.d/init.d/openvpn
# line 133: uncomment
echo 1 > /proc/sys/net/ipv4/ip_forward

/etc/rc.d/init.d/openvpn start
chkconfig openvpn on

openvpn防火墙nat设置:  
```
#!/bin/bash
## Internet connection shating script
sysctl -w net.ipv4.ip_forward=1
sysctl -p
iptables -X
iptables -F
iptables -t nat -X
iptables -t nat -F
iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD  -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 172.168.110.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
```

#---------------------
Configure VPN Client
#---------------------
    +----------------------+
              | [  OpenVPN Server  ] |
          tap0|     dlp.srv.world    |eth0
              |                      |
              +-----------+----------+
         192.168.0.30:1194|br0
                          |
               192.168.0.1|
                   +------+-----+
-------------------|   Router   |---------------------
                   +------+-----+
                          |x.x.x.x:1194
          +---------------+--------------+    Internet
          |                              |
----------+------------------------------+------------
          |     +------------------+     |
          | tap0|                  |eth0 |
          +-----+    VPN Client    +-----+
     192.168.0.x|                  |10.0.0.10


http://openvpn.net/index.php/open-source/downloads.html

OpenVPN之前，你必须先确保Ubuntu上已经安装了C编译器(例如gcc)、OpenSSL、LZO(一种无损压缩算法)、PAM(一种可插入式的身份验证模块)。

如果你没有安装OpenSSL，则会提示：
configure: error: ssl is required but missing
解决方法是执行命令：sudo apt-get install libssl-dev
如果你没有安装lzo，则会提示：
configure: error: lzo enabled but missing
解决方法是执行命令：sudo apt-get install liblzo2-dev
如果你没有安装PAM，则会提示：
configure: error: libpam required but missing
解决方法是执行命令：sudo apt-get install libpam0g-dev
