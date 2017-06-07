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
deb [arch=amd64] http://10.0.0.1:1888/ubuntu trusty-updates/mitaka main">/etc/apt/sources.list

apt-get update

apt-get install ubuntu-cloud-keyring crudini lrzsz -y  #此处软件园解决，安装基本依赖工具

apt-get update

#------------------------------------------------------------------

#配置NTP服务
apt-get install chrony -y

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ntpdate time.windows.com

service chrony restart

chronyc sources

#------------------------------------------------------------------

#OpenStack包
apt-get install software-properties-common -y
#apt-get update && apt-get dist-upgrade
apt-get install python-openstackclient -y

#------------------------------------------------------------------

#安装sql
apt-get install mariadb-server python-pymysql -y

#配置文件
echo "[mysqld]
bind-address = $controller_ip
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8">/etc/mysql/conf.d/openstack.cnf

#重启服务
service mysql restart

#加固sql安全
mysql_secure_installation


#------------------------------------------------------------------

#安装MongoDB
apt-get install mongodb-server mongodb-clients python-pymongo -y

#配置
crudini --set /etc/mongodb.conf '' bind_ip $controller_ip
crudini --set /etc/mongodb.conf '' smallfiles true
service mongodb stop
rm /var/lib/mongodb/journal/prealloc.*
service mongodb start

#------------------------------------------------------------------

#安装消息队列
apt-get install rabbitmq-server -y

#配置
rabbitmqctl add_user openstack pass

#给openstack用户配置写和读权限：
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

#------------------------------------------------------------------

#安装Memcached
apt-get install memcached python-memcache -y

#配置文件
sed -i s/127.0.0.1/$controller_ip/g /etc/memcached.conf
sed -i s/"m 64"/"m 1024"/g /etc/memcached.conf

#重启服务
service memcached restart
