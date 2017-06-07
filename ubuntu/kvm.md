n<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [install](#install)
	- [ubuntu16.4](#ubuntu164)
	- [centos](#centos)
	- [启用桥接网络:](#启用桥接网络)
		- [ubuntu](#ubuntu)
		- [centos](#centos)
	- [安装镜像](#安装镜像)
	- [virsh使用](#virsh使用)

<!-- /TOC -->

# install
## ubuntu16.4
查看cpu支持:
```s
grep -E -o 'svm|vmx' /proc/cpuinfo
```

安装KVM及相关依赖包:
```s
sudo apt-get install qemu qemu-kvm qemu-system libvirt-bin virt-manager bridge-utils vlan
```

启动KVM虚拟系统管理器:
```s
sudo virt-manager
```


## centos
查看cpu支持:
```s
grep -E -o 'svm|vmx' /proc/cpuinfo
```

安装KVM及相关依赖包:
```s
yum -y install qemu-kvm qemu-kvm-tools libvirt
systemctl start libvirtd    
systemctl enable libvirtd     #设置开机启动
```

加载kvm.并创建物理桥:
```s
modprobe kvm
virsh iface-bridge eth0 br0
```
## 启用桥接网络:  
### ubuntu
sudo vim /etc/network/interfaces
```s
 # Enabing Bridge networking br0 interface
auto br0
iface br0 inet static
address 192.168.2.55
network 192.168.2.0
netmask 255.255.255.0
broadcast 192.168.2.255
gateway 192.168.2.1
dns-nameservers 114.114.114.114
bridge_ports enp4s0
bridge_stp off
```

### centos
编辑ifcfg-br0网卡内容
```s
DEVICE="br0"
BOOTPROTO=static
NM_CONTROLLED="yes"
IPADDR=192.168.2.55
NETWMASK=255.255.255.0
GATEWAY=192.168.2.1
ONBOOT="yes"
TYPE=Bridge
```
编辑ifcfg-em1网卡内容
```s
DEVICE="em1"
ONBOOT="yes"
BRIDGE=br0
TYPE=Ethernet
```
service network restart  

查看网卡桥接:  
brctl show  

查看路由:  
route  
把em1桥接为br0网卡了，VM就可以使用这个桥接配置  


## 安装镜像
```s
sudo virt-install \
--virt-type=kvm \
--name ubunt14 \
--ram 1024 \
--vcpus=1 \
--os-type=linux \
--hvm \
--cdrom=/home/neildev/Downloads/ubuntu-14.04.5-server-amd64.iso \
--video cirrus  \
--graphics vnc \
--disk path=/var/lib/libvirt/images/ubuntu14.qcow2,size=100,bus=ide,format=qcow2
```

```s
sudo virt-install \
--virt-type=kvm \
--name ubunt14 \
--ram 2048 \
--vcpus=2 \
--network bridge=br0,virtualport_type='openvswitch' \
--os-type=linux \
--hvm \
--cdrom=/home/neildev/Downloads/ubuntu-14.04.5-server-amd64.iso \
--video cirrus  \
--graphics vnc \
--disk path=/var/lib/libvirt/images/ubuntu14.qcow2,size=100,bus=ide,format=qcow2
```

## virsh使用
```s
关闭
virsh shutdown ubuntu14
删除
virsh destroy ubuntu14
暂停
virsh suspend ubuntu14
恢复
virsh resume ubuntu14
添加
virsh define ubuntu14
导出配置
virsh dumpxml ubuntu14 > /root/ubuntu14.xml
```
