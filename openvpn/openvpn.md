<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [OpenVPN搭建](#openvpn搭建)
	- [安装EPEL](#安装epel)
	- [创建证书](#创建证书)
	- [生成服务器证书](#生成服务器证书)
	- [创建客户端证书](#创建客户端证书)
	- [拷贝证书](#拷贝证书)
	- [启动openvpn服务--tap](#启动openvpn服务-tap)
		- [openvpn tap 网络结构](#openvpn-tap-网络结构)
		- [修改配置文件](#修改配置文件)
		- [修改网络转发协议](#修改网络转发协议)
		- [设置iptables](#设置iptables)
		- [启动openvpn](#启动openvpn)
		- [配置客户端](#配置客户端)
	- [启动openvpn服务--tun](#启动openvpn服务-tun)
		- [配置服务器](#配置服务器)
		- [设置防火墙Nat](#设置防火墙nat)
		- [设置iptables](#设置iptables)
		- [客户端设置](#客户端设置)
	- [配置文件解析](#配置文件解析)
		- [服务器配置](#服务器配置)
		- [客户端配置](#客户端配置)
- [安装注意事项](#安装注意事项)

<!-- /TOC -->


# OpenVPN搭建
## 安装EPEL
yum -y install epel-release
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers

yum -y install openssl openssl-devel lzo
yum --enablerepo=epel -y install openvpn easy-rsa net-tools bridge-utils

需要auth-ldap认证:  
yum install openvpn openvpn-auth-ldap

## 创建证书
cd /usr/share/easy-rsa/2.0

```
export KEY_COUNTRY="CN"
export KEY_PROVINCE="Shanghai"
export KEY_CITY="Shanghai"
export KEY_ORG="SME"
export KEY_EMAIL="3835231@qq.com"
export KEY_OU="Server_World"

source ./vars
./clean-all
./build-ca
```

## 生成服务器证书
```
Name [EasyRSA]:Server-CA
cd /usr/share/easy-rsa/2.0
./build-key-server server

Name [EasyRSA]:Server-CRT# change to any name you like
Generate Diffie Hellman ( DH ) parameter.
cd /usr/share/easy-rsa/2.0
./build-dh
```

## 创建客户端证书
```
cd /usr/share/easy-rsa/2.0
./build-key client01

Name [EasyRSA]:neildev# change to any name you like

confirm settings and proceed with yes
Sign the certificate? [y/n]: y
proceed with yes
1 out of 1 certificate requests certified, commit? [y/n] y
```

## 拷贝证书
```
cp -pR /usr/share/easy-rsa/2.0/keys /etc/openvpn/keys
cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn/
```

## 启动openvpn服务--tap
### openvpn tap 网络结构
```
       	      +----------------------+
              | [  OpenVPN Server  ] |
          tap0|                      |eth0
              #---------------------
Configure VPN Server
---------------------|                      |
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
```


### 修改配置文件
vi /etc/openvpn/server.conf
```
port 1194
proto tcp
dev tap0
ca keys/ca.crt
cert keys/server.crt
key keys/server.key
dh keys/dh2048.pem
server-bridge 192.168.0.30 255.255.255.0 192.168.0.150 192.168.0.199
keepalive 10 120
comp-lzo
persist-key
persist-tun
log /var/log/openvpn.log
log-append /var/log/openvpn.log
verb 3
```
### 修改网络转发协议
echo 1 > /proc/sys/net/ipv4/ip_forward  
sysctl -p  

### 设置iptables
openvpn防火墙nat设置:  
```
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
### 启动openvpn
/etc/rc.d/init.d/openvpn start  
chkconfig openvpn on  

### 配置客户端
Configure VPN Client
```
client
dev tun
proto tcp
remote 113.204.168.251 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/wangyunhua.crt
key /etc/openvpn/wangyunhua.key
ns-cert-type server
remote-cert-tls server
cipher AES-256-CBC
comp-lzo
verb 3
```

## 启动openvpn服务--tun
### 配置服务器
vim /etc/openvpn/server.conf  
```
port 1194
proto udp
dev tun
 #指定位置
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
tls-auth /etc/openvpn/easy-rsa/2.0/keys/ta.key 0
server 10.8.0.0255.255.255.0
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 10.8.0.1"
client-to-client
keepalive 10120
comp-lzo
persist-key
persist-tun
client-cert-not-required
username-as-common-name
 #这里是指定openvpn-auth-ldap.so这个插件
plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-ldap.so /etc/openvpn/auth/ldap.conf
 #log
 #日志存放目录
log openvpn.log
status openvpn-status.log
 #日志级别
verb 3
```
vim /etc/openvpn/auth/ldap.conf  
```
<LDAP>
        # LDAP server URL
        URL             ldap://gzdc.cn:389
  #这里也可以填IP地址，若是IP地址，下面的DNS就不用做特别限定

  # Bind DN (If your LDAP server doesn't support anonymous binds)
BindDN "cn=digiwin,cn=Users,dc=gzdc,dc=cn"

  # Bind Password
Password digiwin

  # Network timeout (in seconds)
Timeout 60

  # Enable Start TLS
TLSEnable no

  # Follow LDAP Referrals (anonymously)
  #FollowReferrals no

  # TLS CA Certificate File
  #TLSCACertFile /usr/local/etc/ssl/ca.pem

  # TLS CA Certificate Directory
  #TLSCACertDir /etc/ssl/certs

  # Client Certificate and key
  # If TLS client authentication is required
  #TLSCertFile /usr/local/etc/ssl/client-cert.pem
  #TLSKeyFile /usr/local/etc/ssl/client-key.pem

  # Cipher Suite
  # The defaults are usually fine here
  # TLSCipherSuite ALL:!ADH:@STRENGTH
</LDAP>

<Authorization>
  # Base DN
BaseDN "CN=Users,DC=gzdc,DC=cn"
  # User Search Filter
SearchFilter "(&(sAMAccountName=%u))"

  # Require Group Membership
RequireGroup false

  # Add non-group members to a PF table (disabled)
  #PFTable ips_vpn_users

  #<Group>
  # BaseDN "ou=Groups,dc=example,dc=com"
  # SearchFilter "(|(cn=developers)(cn=artists))"
  # MemberAttribute uniqueMember
  # # Add group members to a PF table (disabled)
  # #PFTable ips_vpn_eng
  #</Group>
</Authorization>
```
### 设置防火墙Nat
```
net.ipv4.ip_forward =1
net.ipv4.conf.default.rp_filter =1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid =1
net.ipv4.tcp_syncookies =1

sysctl -p
```

### 设置iptables
你的网卡接口，由于我的主机是VPS主机，所以网卡为venet0:0  
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o venet0:0 -j MASQUERADE  
设置地址转发:  
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source 你的服务器地址  

### 客户端设置
```
client
dev tun
proto udp
remote 192.168.70.30 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
tls-auth ta.key 1
ns-cert-type server
comp-lzo
verb 3
auth-user-pass
```

## 配置文件解析
### 服务器配置
允许多个客户端使用同一个证书连接服务端:  
duplicate-cn  

可以让vpn的client之间互相访问，直接通过openvpn程序转发  
client-to-client  

通过keepalive检测超时后，重新启动vpn，不重新读取keys,保留第一次使用的keys  
persist-key

通过keepalive检测超时后,重新启动vpn,一直保持tun或tap设备是linkup的，否则网络连接会先linkdown然后linkup  
persist-tun  
### 客户端配置
始终重新解析Server的IP地址，如果remote后面跟的是域名，保证Server IP地址是动#态的使用DDNS动态更新DNS后  
Client在自动重新连接时重新解析Server的IP地址，这#样无需人为重新启动，即可重新接入VPN   
resolv-retry infinite  

在本机不绑定任何端口监听进入的数据  
nobind  

# 安装注意事项
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
