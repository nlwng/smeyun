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

#��֤ntp
chronyc sources

yum -qy install centos-release-openstack-mitaka
#����ϵͳ
yum -y upgrade

#RHEL��CentOSĬ������SELinux����װOpenStack SELinux������Զ�����OpenStack����ȫ���ߣ�
yum -qy install openstack-selinux

yum -qy install lvm2

systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service

pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb

����Ǹ�Ŀ¼
/etc/lvm/lvm.conf
filter = [ "a/sda/", "a/sdb/", "a/sdC/","r/.*/"]

devices {
...
filter = [ "a/sdb/", "r/.*/"] #lvm����ɨ�跢��sdb�������ķ�����reject
������Ĵ洢�ڵ��ڲ���ϵͳ������ʹ���� LVM���������������ص��豸���������С����磬��� /dev/sda �豸��������ϵͳ��
filter = [ "a/sda/", "a/sdb/", "r/.*/"]
���Ƶأ�������ļ���ڵ��ڲ���ϵͳ������ʹ���� LVM����Ҳ�����޸���Щ�ڵ��� /etc/lvm/lvm.conf �ļ��еĹ�������
������ϵͳ���̰������������С����磬���``/dev/sda`` �豸��������ϵͳ��
filter = [ "a/sda/", "r/.*/"]

ʹ�õڶ������/dev/sdb ����һ��pv
pvcreate /dev/sdb
�������pv�ϴ���һ��vg
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
#crudini --set  /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver #ʹ��lvm��˴洢
crudini --set  /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set  /etc/cinder/cinder.conf lvm volume_group cinder-volumes #vg�����ƣ��ղŴ�����
crudini --set  /etc/cinder/cinder.conf lvm iscsi_protocol iscsi #ʹ��iscsiЭ��
crudini --set  /etc/cinder/cinder.conf lvm iscsi_helper lioadm

crudini --set  /etc/cinder/cinder.conf DEFAULT enabled_backends lvm #ʹ�õĺ����lvm��Ҫ��Ӧ��ӵ�[lvm]����Ȼʹ��heheҲ��
crudini --set  /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set  /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

systemctl enable openstack-cinder-volume.service target.service
systemctl start openstack-cinder-volume.service target.service


Cinderʹ��LVM,���ش洢֧��
----------------------
Cinder LVM���ã�
1. ��cinder�����ļ��У�Ĭ�ϵ�backend lvmdriver��ͨ��LVM��ʹ�ñ��ش洢��

crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_group stack-volumes-lvmdriver-1
#crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_driver cinder.volume.drivers.lvm.LVMISCSIDriver
#crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_driver cinder.volume.drivers.lvm.LVMISCSIDriver
crudini --set  /etc/cinder/cinder.conf lvmdriver-1 volume_backend_name lvmdriver-1


volume_group ָ��Cinderʹ�õ� volume group����devstackĬ�ϰ�װʱ��������stack-volumes-lvmdriver-1����ʵ�ʲ���cinder��ʱ����Ĭ��������cinder-volumes��
volume_driver ָ��driver���ͣ�LVM��cinder.volume.drivers.lvm.LVMISCSIDriver
volume_backend_name ��backend name���ڴ���volume��ʱ���ѡ��

cinder service-list
vgdisplay

systemctl restart openstack-cinder-volume.service target.service
systemctl restart lvm2-lvmetad.service

