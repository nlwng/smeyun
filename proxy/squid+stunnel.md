<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1 利用squid + stunnel做web代理](#1-利用squid-stunnel做web代理)
	- [1.1 安装squid](#11-安装squid)
	- [1.2 设置配置相关](#12-设置配置相关)
	- [1.3 启动 squid 服务，并设定开机自动启动](#13-启动-squid-服务并设定开机自动启动)
	- [1.4 搭建 stunnel 服务](#14-搭建-stunnel-服务)
		- [1.4.1 服务端](#141-服务端)
		- [1.4.2 客户端-ubuntu](#142-客户端-ubuntu)
		- [1.4.3 客户端-centos](#143-客户端-centos)
		- [1.4.4 客户端配置](#144-客户端配置)

<!-- /TOC -->


# 1 利用squid + stunnel做web代理
## 1.1 安装squid
yum install -y httpd-tools squid  

创建账号:  
htpasswd -cb /etc/squid/passwd account passwd  
htpasswd -b /etc/squid/passwd testaccount passwd  

## 1.2 设置配置相关

添加以下配置使密码访问规则生效   
vim /etc/squid/squid.conf  
```
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 10
auth_param basic credentialsttl 24 hours
acl normal proxy_auth REQUIRED
http_access allow normal
```
此外，还可通过如下配置实现高匿代理实现真实 IP 隐藏
```
request_header_access Referer deny all
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all
```

## 1.3 启动 squid 服务，并设定开机自动启动
systemctl start squid  
systemctl enable squid

## 1.4 搭建 stunnel 服务
### 1.4.1 服务端  
yum install -y stunnel openssl openssl-devel

创建 stunnel 服务端配置文件，这里使用 5000 端口作为 stunnel 的服务端口:   
```
cat > /etc/stunnel/stunnel.conf <<EOF
client = no
[squid]
accept = 5000
connect = 127.0.0.1:3128
cert = /etc/stunnel/stunnel.pem
EOF
```

创建加密证书文件:
```
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
```
打开防火墙端口:
```
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --reload
```

创建 stunnel 服务的 systemd 配置文件:  
sudo vim /usr/lib/systemd/system/stunnel.service

配置如下:
```
[Unit]
Description=SSL tunnel for network daemons
After=syslog.target

[Service]
ExecStart=/bin/stunnel /etc/stunnel/stunnel.conf
ExecStop=kill -9 $(pgrep stunnel)
ExecStatus=pgrep stunnel
Type=forking

[Install]
WantedBy=multi-user.target
```

启动 stunnel 服务:  
```
systemctl enable stunnel   
systemctl start stunnel  
```

### 1.4.2 客户端-ubuntu
sudo apt-get install stunnel4   
sudo vim /etc/systemd/system/stunnel.service  

进行如下配置:
```
[Unit]
Description=SSL tunnel for network daemons
After=syslog.target

[Service]
ExecStart=/usr/bin/stunnel /etc/stunnel/stunnel.conf
ExecStop=kill -9 $(pgrep stunnel)
ExecStatus=pgrep stunnel
Type=forking

[Install]
WantedBy=multi-user.target
```
最后启动客户端 stunnel 服务:
```
systemctl enable stunnel
systemctl start stunnel
```

### 1.4.3 客户端-centos
yum install stunnel

### 1.4.4 客户端配置
新增配置/etc/stunnel/stunnel.conf，添加以下内空  

复制代码代码如下:  
```
cat > /etc/stunnel/stunnel.conf <<EOF
cert = /etc/stunnel/stunnel.pem
client = yes
[squid]
accept = 5000
connect = <Server IP>:5000
EOF
```
