<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [安装图形化组件](#安装图形化组件)
- [vncserver](#vncserver)

<!-- /TOC -->


# 安装图形化组件
```
mount /dev/sr0 /mnt
df
#yum clean all             \\  清楚yum仓库缓存
#yum makecache              \\ 创建yum仓库缓存
#yum repolist                \\ 列出可用yum仓库
#yum grouplist                \\ 列出程序组

#yum -y groupinstall "Server with GUI" --skip-broken  \\ 安装图形化程序组
#startx

设置默认运行级别为图形化
#systemctl get-default          \\查看默认运行级别
#cat /etc/inittab

#systemctl set-default graphical.target \\设置默认图形化运行级别
[root@localhost Desktop]# systemctl get-default                    \\查看默认运行级别
graphical.target                \\图形化设置OK


卸载：
rpm -qa | grep yum | xargs rpm -e --nodeps
rpm -ivh yum-*
https://mirrors.aliyun.com/centos/7.3.1611/os/x86_64/Packages/yum-3.4.3-150.el7.centos.noarch.rpm
https://mirrors.aliyun.com/centos/7.3.1611/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.31-40.el7.noarch.rpm
https://mirrors.aliyun.com/centos/7.3.1611/os/x86_64/Packages/yum-updateonboot-1.1.31-40.el7.noarch.rpm
https://mirrors.aliyun.com/centos/7.3.1611/os/x86_64/Packages/yum-utils-1.1.31-40.el7.noarch.rpm
https://mirrors.aliyun.com/centos/7.3.1611/os/x86_64/Packages/yum-metadata-parser-1.1.4-10.el7.x86_64.rpm
<rpm --import public.gpg.key
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*>

```
# vncserver
```
#yum install tigervnc-server
#vncpasswd
#vncserver :1
#vncserver -kill :1



```
