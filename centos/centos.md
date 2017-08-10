<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [设置yum代理](#设置yum代理)
- [vnc](#vnc)
- [关闭firewall](#关闭firewall)

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
sudo systemctl start vncserver@:1.service

sudo firewall-cmd --permanent --add-service vnc-server
sudo systemctl restart firewalld.service
```

# 关闭firewall
```
systemctl stop firewalld.service #停止firewall
systemctl disable firewalld.service #禁止firewall开机启动
firewall-cmd --state #查看默认防火墙状态（关闭后显示notrunning，开启后显示running）
```
