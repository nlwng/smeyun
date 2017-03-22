
#Uninstall old versions
yum remove docker docker-common container-selinux docker-selinux docker-engine

#install docker
cat /etc/redhat-release 
CentOS release 6.8 (Final)

rpm -Uvh http://ftp.riken.jp/Linux/fedora/epel/6Server/x86_64/epel-release-6-8.noarch.rpm

yum install -y docker-io

#开机自启动与启动Docker
service docker start
chkconfig docker on

#更改配置文件
vim /etc/sysconfig/docker
other-args列更改为：other_args="--exec-driver=lxc --selinux-enabled"


docker search centos

#需要改/etc/sysconfig/network-scripts/ifcfg-eth0
PEERDNS=no

