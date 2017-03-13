systemctl stop firewalld.service
systemctl disable firewalld.service
#sys set lan yum
#wget -O /etc/yum.repos.d/CentOS-Base.repo  http://192.168.2.88:911/centos7/CentOS-Base.repo
cp -rvf /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum clean all
yum makecache
#yum repolist

#install crudini
yum -y install epel-release
yum -qy install crudini

#ntp
yum -qy install chrony
echo  "server controller iburst" >> /etc/chrony.conf 
systemctl enable chronyd.service
systemctl start chronyd.service

#验证ntp
chronyc sources

yum -qy install centos-release-openstack-mitaka
#更新系统
yum -y upgrade

#RHEL和CentOS默认启用SELinux。安装OpenStack SELinux软件包自动管理OpenStack服务安全政策：
yum -qy install openstack-selinux

yum -qy install lvm2

systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service

pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb

如果是根目录
/etc/lvm/lvm.conf
filter = [ "a/sda/", "a/sdb/", "a/sdC/","r/.*/"]

devices {
...
filter = [ "a/sdb/", "r/.*/"] #lvm可以扫描发现sdb，其他的分区都reject
如果您的存储节点在操作系统磁盘上使用了 LVM，您还必需添加相关的设备到过滤器中。例如，如果 /dev/sda 设备包含操作系统：
filter = [ "a/sda/", "a/sdb/", "r/.*/"]
类似地，如果您的计算节点在操作系统磁盘上使用了 LVM，您也必需修改这些节点上 /etc/lvm/lvm.conf 文件中的过滤器，
将操作系统磁盘包含到过滤器中。例如，如果``/dev/sda`` 设备包含操作系统：
filter = [ "a/sda/", "r/.*/"]

使用第二块磁盘/dev/sdb 穿件一个pv
pvcreate /dev/sdb
在上面的pv上创建一个vg
vgcreate cinder-volumes /dev/sdb

#Install and configure components
yum install openstack-cinder targetcli python-keystone

crudini --set  /etc/cinder/cinder.conf database connection  mysql+pymysql://cinder:pass@controller/cinder
crudini --set  /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set  /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password pass

crudini --set  /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set  /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set  /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set  /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set  /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set  /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set  /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set  /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set  /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set  /etc/cinder/cinder.conf keystone_authtoken password pass

crudini --set  /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.130
#crudini --set  /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver #使用lvm后端存储
crudini --set  /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set  /etc/cinder/cinder.conf lvm volume_group cinder-volumes #vg的名称：刚才创建的
crudini --set  /etc/cinder/cinder.conf lvm iscsi_protocol iscsi #使用iscsi协议
crudini --set  /etc/cinder/cinder.conf lvm iscsi_helper lioadm

crudini --set  /etc/cinder/cinder.conf DEFAULT enabled_backends lvm #使用的后端是lvm，要对应添加的[lvm]，当然使用hehe也可
crudini --set  /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set  /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

systemctl enable openstack-cinder-volume.service target.service
systemctl start openstack-cinder-volume.service target.service


Cinder使用LVM,本地存储支持
----------------------
Cinder LVM配置：
1. 在cinder配置文件中，默认的backend lvmdriver是通过LVM来使用本地存储：

crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_group stack-volumes-lvmdriver-1
#crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_driver cinder.volume.drivers.lvm.LVMISCSIDriver
#crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_driver cinder.volume.drivers.lvm.LVMISCSIDriver
crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_backend_name lvmdriver-1


volume_group 指定Cinder使用的 volume group。在devstack默认安装时其名称是stack-volumes-lvmdriver-1；在实际部署cinder的时候其默认名称是cinder-volumes。
volume_driver 指定driver类型，LVM是cinder.volume.drivers.lvm.LVMISCSIDriver
volume_backend_name 是backend name，在创建volume的时候可选择。

cinder service-list
vgdisplay

systemctl restart openstack-cinder-volume.service target.service
systemctl restart lvm2-lvmetad.service

