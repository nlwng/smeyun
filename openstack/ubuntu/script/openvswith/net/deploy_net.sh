#------------------------------------------------------------------

#设置软件源
mv /etc/apt/sources.list /etc/apt/sources.list.bak
echo "deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb [arch=amd64] http://192.168.2.88:1888/ubuntu trusty-updates/mitaka main">/etc/apt/sources.list

apt-get update

apt-get install ubuntu-cloud-keyring crudini lrzsz -y  #此处软件园解决，安装基本依赖工具

apt-get update

#------------------------------------------------------------------

#配置NTP服务
apt-get install chrony -y

sed -i '/^server.*/d' /etc/chrony/chrony.conf
sed -in '19a server controller iburst ' /etc/chrony/chrony.conf

service chrony restart

#------------------------------------------------------------------

#OpenStack包
apt-get install software-properties-common -y
#apt-get update && apt-get dist-upgrade
apt-get install python-openstackclient -y


#------------------------------------------------------------------
