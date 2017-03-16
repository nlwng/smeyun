squid + stunnel

yum install -y httpd-tools squid

创建账号：
htpasswd -cb /etc/squid/passwd neildve urwelcome
htpasswd -b /etc/squid/passwd test urwelcome

vim /etc/squid/squid.conf

#添加以下配置使密码访问规则生效
# Auth
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 10
auth_param basic credentialsttl 24 hours
acl normal proxy_auth REQUIRED
http_access allow normal

#此外，还可通过如下配置实现高匿代理实现真实 IP 隐藏
# not display IP address
forwarded_for off

# header
request_header_access Referer deny all
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all

#启动 squid 服务，并设定开机自动启动：
systemctl start squid
systemctl enable squid

#搭建 stunnel 服务
#服务器
yum install -y stunnel

#创建 stunnel 服务端配置文件，这里使用 5000 端口作为 stunnel 的服务端口：
cat > /etc/stunnel/stunnel.conf <<EOF
client = no
[squid]
accept = 5000
connect = 127.0.0.1:3128
cert = /etc/stunnel/stunnel.pem
EOF

#创建加密证书文件：
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#打开防火墙端口：
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --reload

#创建 stunnel 服务的 systemd 配置文件：
sudo vim /usr/lib/systemd/system/stunnel.service

配置如下：
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

#启动 stunnel 服务：
systemctl enable stunnel
systemctl start stunnel

sudo apt-get install stunnel4

sudo vim /etc/systemd/system/stunnel.service



进行如下配置：


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




最后启动客户端 stunnel 服务：

systemctl enable stunnel
systemctl start stunnel
