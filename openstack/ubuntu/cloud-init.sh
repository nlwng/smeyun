#install kvm
sudo apt-get install qemu-kvm libvirt-bin kvm qemu virt-manager bridge-utils

#create img
qemu-img create -f qcow2 server.img 10G

#setup img
sudo kvm -m 1024 -cdrom ubuntu-14.04.5-server-amd64.iso -drive file=server.img,if=virtio,index=0 -boot d -net nic -net user -nographic  -vnc 127.0.0.1:0

#install gvncviewer
apt-get install gvncviewer

#login
gvncviewer 192.168.88.140:0

#check img
sudo kvm -m 1024 -drive file=server.img,if=virtio,index=0 -boot c -net nic -net user -nographic -vnc 192.168.88.140:0

openstack image create "centos6" --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2 --disk-format qcow2 --container-format bare --public
openstack image create "ubunut14.04" --file /root/ubuntu14.04.5 --disk-format qcow2 --container-format bare --public


#update img
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install openssh-server cloud-init

----------------
#create img
qemu-img create -f qcow2 /home/neildev/img/trusty.qcow2 10G

#start kvm img
sudo virt-install --virt-type kvm --name trusty --ram 1024 \
  --cdrom=/home/neildev/img/ubuntu-14.04.5-server-amd64.iso \
  --disk /home/neildev/img/trusty.qcow2,format=qcow2 \
  --network network=default \
  --graphics vnc,listen=0.0.0.0 --noautoconsole \
  --os-type=linux --os-variant=ubuntutrusty


sudo virsh start trusty0310 --paused

#del cdrom
virsh dumpxml trusty0310
sudo virsh attach-disk --type cdrom --mode readonly trusty0310 "" hdb

sudo virsh resume trusty0310

#install cloud-init
apt-get install cloud-init

#cloud-init package
dpkg-reconfigure cloud-init

#mac info del
sudo virt-sysprep -d trusty

#kvm del config file
sudo virsh undefine trusty


openstack image create "ubunut" --file /home/neildev/trusty0310.qcow2 --disk-format qcow2 --container-format bare --public

glance image-create --name "ubunut" \
  --file /home/neildev/trusty0310.qcow2 \
  --disk-format qcow2 --container-format bare \
  --visibility public --progress

https://docs.openstack.org/image-guide/ubuntu-image.html

----------------------------------------------------------------------------
apt-get install libguestfs-tools -y

#查看镜像文件大小，并对其进行扩展
virt-filesystems --long --parts --blkdevs -h -a CentOS-6-x86_64-GenericCloud.qcow2
virt-df -h CentOS-6-x86_64-GenericCloud.qcow2

#扩充系统盘
qemu-img create -f qcow2 CentOS6_20G 20G
virt-resize CentOS-6-x86_64-GenericCloud.qcow2 CentOS6_20G --expand /dev/sda1

virt-df -h CentOS6_20G

#第一种方式修改证书
guestmount -a CentOS6_20G -i /mnt/guest/
touch /mnt/guest/etc/1

mkdir /mnt/guest/root/.ssh
echo << EOF >>/mnt/guest/root/.ssh/authorized_keys
xxxxxxxxxx
EOF

chmod 600 /mnt/guest/root/.ssh/authorized_keys
guestunmount /mnt/guest/


openstack image create "ubunut14.04" --file /root/ubuntu14.04.5 --disk-format qcow2 --container-format bare --public
