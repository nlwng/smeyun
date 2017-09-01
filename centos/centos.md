<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [设置yum代理](#设置yum代理)
- [vnc](#vnc)
- [关闭firewall](#关闭firewall)
- [安装Virtualbox](#安装virtualbox)
- [关闭防火墙](#关闭防火墙)
- [删libreoffice](#删libreoffice)

<!-- /TOC -->

# 设置yum代理
```s
vim /etc/yum.conf
proxy=http://192.168.5.100:8086
proxy_username=代理服务器用户名
proxy_password=代理服务器密码

全局代理
vim /etc/skel/.bash_profile
http_proxy=http://192.168.5.100:8080
https_proxy=http://192.168.5.100:8080
export http_proxy https_proxy
执行source etc/skel/.bash_profile
```
# vnc
```s
yum install tigervnc-server -y
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service

vim  /etc/systemd/system/vncserver@:1.service
ExecStart=/sbin/runuser -l root -c "/usr/bin/vncserver %i"
PIDFile=/root/.vnc/%H%i.pid

systemctl daemon-reload
sudo vncpasswd
sudo systemctl enable vncserver@:1.service
vncserver :1

sudo firewall-cmd --permanent --add-service vnc-server
sudo systemctl restart firewalld.service

note:
1号端口一直启动不了:cd /tmp/.X11-unix;rm -rf *
```

# 关闭firewall
```
systemctl stop firewalld.service #停止firewall
systemctl disable firewalld.service #禁止firewall开机启动
firewall-cmd --state #查看默认防火墙状态（关闭后显示notrunning，开启后显示running）
```
# 安装Virtualbox
```
yum install kernel-devel
yum install gcc make

vim /etc/yum.repos.d/CentOS7-Base.repo
[virtualbox]
name=Oracle Linux / RHEL / CentOS-$releasever / $basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/el/$releasever/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc

yum update
sudo yum install VirtualBox-5.1
/sbin/rcvboxdrv setup
```

# 关闭防火墙
```
停止firewalld服务  
systemctl stop firewalld  
禁用firewalld服务  
systemctl mask firewalld  
```

# 删libreoffice
yum erase libreoffice\*

# rc.local 不启动
```
[Unit]
Description=/etc/rc.d/rc.local Compatibility
ConditionFileIsExecutable=/etc/rc.d/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.d/rc.local start
TimeoutSec=0
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target

#systemctl enable rc-local.service
#systemctl --system daemon-reload
#systemctl start rc-local.service
```
