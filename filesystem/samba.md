<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [samba](#samba)
	- [安装](#安装)
	- [配置文件](#配置文件)
	- [启动进程](#启动进程)

<!-- /TOC -->

# samba
Linux操作系统提供了Samba服务
环境:centos6.8

## 安装
yum install samba

## 配置文件
配置普通目录:  
vim /etc/samba/smb.conf  
```
[global]

      workgroup = LinuxSir
      netbios name = LinuxSir05
      server string = Linux Samba Server TestServer
      security = share

[cloudfile]
      path = /date/cloudfile
      writeable = yes
      browseable = yes
      guest ok = yes
```

## 启动进程
smbd  
nmbd  
