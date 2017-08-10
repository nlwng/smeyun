<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [hcg安装概述](#hcg安装概述)
- [hcg网络概述](#hcg网络概述)
- [hcg安装流程](#hcg安装流程)
- [controller-0 install](#controller-0-install)
	- [1.OAM network](#1oam-network)
	- [2.导入key](#2导入key)
	- [3.patches](#3patches)
	- [configuration](#configuration)
		- [前提](#前提)
		- [基础配置](#基础配置)
			- [环境描述](#环境描述)
			- [controller-0配置](#controller-0配置)
			- [controller-1配置](#controller-1配置)
				- [安装方法](#安装方法)
					- [web install](#web-install)
					- [system host-update](#system-host-update)
					- [system host-add](#system-host-add)

<!-- /TOC -->


# hcg安装概述
```s
1. iso images / pxe server
```
设置BIOS
想要pxe安装系统，启动项肯定要改成pxe优先级最高。而且BIOS里有一个Network Setup
总的Onboard Ethernet Contorller给调整为enable

H3c:
H3C-5204E交换机DHCPSnooping功能（启用后默认所有端口DHCP为非信任）
需要关闭改功能：
dhcp snooping disable
```s
2. config set
3. license file
4. ca key --> 可选
5. firewall --> 可选
6. 通过controller-0安装配置其他节点
```

# hcg网络概述
```
1.内部网络
2.基础网络
3.oam网络
4.数据网络
5.pxe boot网络，上联为tagged可与管理网络共享
6.oam网络可以和存储网络合并
```

# hcg安装流程
```
1.关闭所有节点集权
2.安装controller-0
3.安装controller-1,然后编辑该接口
4.安装storage nodes
5.设置provider，计算节点上编辑数据接口
6.安装各计算节点，并编辑本地存储
note:确保每次开机能识别主机，每次安装时候重启新主机。
```

# controller-0 install
## 1.OAM network
```
sudo ip addr add 15.119.6.93/24 dev enp0s3
sudo ip link set enp0s3 up
sudo ip route add default via 15.119.6.1
```
## 2.导入key
```
up file /home/wrsroot/wrslicense.txt
cp CA key /home/wrsroot/
```
## 3.patches
```
download_seit:https://windshare.windriver.com/

install patches：
for i in `find /home/wrsroot/pacthes/ -name "TS_16.10_PATCH_*.patch"`; do  sudo sw-patch upload $i; done
sudo sw-patch apply --all
sudo sw-patch install-local
sudo sw-patch query

install theme note:
sudo scp hos_theme_v1.1.tgz /opt/branding/
sudo service horizon restart

```
## configuration
### 前提
```
1.controller-0 安装完成
2.管理接口联通正常
3.license文件和CA文件在controller-0上
4.系统补丁安装完成
5.配置信息准备完成

note:
1.patches不能在安装前必须配置完成
2.不能用ssh方式安装，必须使用ilo模式安装
3.ui必须使用英文界面
```

### 基础配置
#### 环境描述
```
OAM - 15.119.6.99
other - 10.10.0.1
内部网络 10.10.1.1
pxe - 10.10.2.1
```
#### controller-0配置
```s
sudo config_controller

Is the current date and time correct? [y/n]: y
Cinder storage backend [lvm]:
Database storage in GiB [20]: 20
Image storage in GiB [10]: 10
Image conversion space in GiB [20]: 20
Backup storage in GiB [50]: 50
Volume storage location [0]:
Volume storage in GiB [199]:
Cinder LVM type [thin]:
Enable SDN Network configuration [y/N]: N
Configure a separate PXEBoot network [y/N]: N

Management interface link aggregation [y/N]: N
Management interface [enp0s8]：
Management interface MTU [1500]:
Management interface link capacity Mbps [1000]:
Management subnet [192.168.204.0/24]:10.10.0.0/24
Use entire management subnet [Y/n]: n
Management network start address [10.10.0.2]:
Management network end address [10.10.0.254]: 10.10.0.50

Dynamic IP address allocation [Y/n]: y

Management Network Multicast subnet [239.1.1.0/28]:
Configure board management control network [y/N]:N

Configure an infrastructure interface [y/N]: y
Infrastructure interface link aggregation [y/N]: n
Infrastructure interface []: enp0s9
Configure an infrastructure VLAN [y/N]: n
Infrastructure interface MTU [1500]:
Infrastructure subnet [192.168.205.0/24]: 10.10.1.0/24
Use entire infrastructure subnet [Y/n]: n
Infrastructure network start address [10.10.1.2]:
Infrastructure network end address [10.10.1.254]: 10.10.1.50

External OAM interface link aggregation [y/N]: N
External OAM interface [enp0s3]:
Configure an external OAM VLAN [y/N]: N
External OAM interface MTU [1500]:1500
External OAM subnet [10.10.10.0/24]:15.119.6.0/24
External OAM gateway address [15.119.6.1]:
External OAM floating address [15.119.6.2]:15.119.6.98
External OAM address for first controller node [15.119.6.99]: 15.119.6.99
External OAM address for second controller node [15.119.6.100]: 15.119.6.100
External OAM Network Multicast subnet [239.1.1.0/28]:
Nameserver 1 [8.8.8.8]:
Nameserver 2 [8.8.4.4]:
Nameserver 3 []:
NTP server 1 [0.pool.ntp.org]:
NTP server 2 [1.pool.ntp.org]:
NTP server 3 [2.pool.ntp.org]:
License File [/home/wrsroot/license.lic]:
Enter wrsroot password age (in days) [45]: 0
Use secure (https) external connection [y/N]: N
Install custom firewall rules [y/N]: N
Create admin user password:password
Repeat admin user password: password
Apply the above configuration? [y/n]:y

验证：
source /etc/nova/openrc
Verify that the Titanium Server controller services are running：
nova service-list

Verify that controller-0 is in the state unlocked-enabled-available：
system host-list

验证接口：
system host-if-list -a controller-0
+--------------------------------------+--------+--------------+----------+---------+-------------+----------+-------------+------------+-------------------+
| uuid                                 | name   | network type | type     | vlan id | ports       | uses i/f | used by i/f | attributes | provider networks |
+--------------------------------------+--------+--------------+----------+---------+-------------+----------+-------------+------------+-------------------+
| a1e93ce6-2708-41b1-b591-cadd0ec747bb | enp0s8 | mgmt         | ethernet | None    | [u'enp0s8'] | []       | []          | MTU=1500   | None              |
| b1fad33d-d457-4451-b4e4-1515c175bd54 | enp0s9 | infra        | ethernet | None    | [u'enp0s9'] | []       | []          | MTU=1500   | None              |
| dec98294-0656-4764-a86b-a61a15141d87 | enp0s3 | oam          | ethernet | None    | [u'enp0s3'] | []       | []          | MTU=1500   | None              |
+--------------------------------------+--------+--------------+----------+---------+-------------+----------+-------------+------------+-------------------+

```

#### controller-1配置
```s
1. Admin > Platform > Host Inventory

note:需要修改pex网口功能enable
```
##### 安装方法
###### web install

###### system host-update

###### system host-add


#### computer-0
```s
system host-add -n compute-0 -p compute -m 08:00:27:50:EC:43
+---------------------+--------------------------------------+
| Property            | Value                                |
+---------------------+--------------------------------------+
| action              | none                                 |
| administrative      | locked                               |
| availability        | offline                              |
| bm_ip               | None                                 |
| bm_mac              | None                                 |
| bm_type             | None                                 |
| bm_username         | None                                 |
| boot_device         | sda                                  |
| capabilities        | {u'bm_region': u'External'}          |
| config_applied      | None                                 |
| config_status       | None                                 |
| config_target       | None                                 |
| console             | ttyS0,115200                         |
| created_at          | 2017-07-21T00:07:49.730223+00:00     |
| hostname            | compute-0                            |
| id                  | 7                                    |
| install_output      | text                                 |
| invprovision        | None                                 |
| location            | {}                                   |
| mgmt_ip             | 10.10.0.221                          |
| mgmt_mac            | 08:00:27:50:ec:43                    |
| operational         | disabled                             |
| personality         | compute                              |
| reserved            | False                                |
| rootfs_device       | sda                                  |
| serialid            | None                                 |
| software_load       | 16.10                                |
| task                | None                                 |
| ttys_dcd            | None                                 |
| updated_at          | 2017-07-21T00:07:51.302927+00:00     |
| uptime              | 0                                    |
| uuid                | 00e05b1c-cfb6-4bc1-9dfd-34ae89343e48 |
| vim_progress_status | None                                 |
+---------------------+--------------------------------------+
删除：
system host-delete 6
查看：
system host-list

system host-add -n hostname \
-p personality [-s subtype] \
[-l location] [-o install_output[-c console]] [-b boot_device] \
[-r rootfs_device] [-m mgmt_mac] [-i mgmt_ip] [-D ttys_dcd] \
[-T bm_type -M bm_mac -I bm_ip -U bm_username -P bm_password]


glance image-create --name "cirros" --visibility public \
--disk-format=qcow2 --container-format=bare \
--file /home/wrsroot/cirros-0.3.4-x86_64-disk.img --cache-raw
+------------------+----------------------------------------------------------------------------------+
| Property         | Value                                                                            |
+------------------+----------------------------------------------------------------------------------+
| cache_raw        | True                                                                             |
| cache_raw_size   | -                                                                                |
| cache_raw_status | Queued                                                                           |
| checksum         | 133eae9fb1c98f45894a4e60d8736619                                                 |
| container_format | bare                                                                             |
| created_at       | 2017-07-21T02:12:34Z                                                             |
| direct_url       | rbd://b11a9b57-bfe5-4c5d-9f68-21f6aa0820cf/images/a1a8eb13-73c6-4090-a07d-       |
|                  | 3f7d01082853/snap                                                                |
| disk_format      | qcow2                                                                            |
| id               | a1a8eb13-73c6-4090-a07d-3f7d01082853                                             |
| min_disk         | 0                                                                                |
| min_ram          | 0                                                                                |
| name             | cirros                                                                           |
| owner            | daedf05b4fec4e12b6397e293e2146cc                                                 |
| protected        | False                                                                            |
| size             | 13200896                                                                         |
| status           | active                                                                           |
| store            | rbd                                                                              |
| tags             | []                                                                               |
| updated_at       | 2017-07-21T02:12:37Z                                                             |
| virtual_size     | None                                                                             |
| visibility       | public                                                                           |
+------------------+----------------------------------------------------------------------------------+

glance -v image-list
+--------------------------------------+--------+-------+-------------+------------------+----------+--------+------------+-----------+----------------------------------+
| ID                                   | Name   | Store | Disk_format | Container_format | Size     | Status | Cache Size | Raw Cache | Owner                            |
+--------------------------------------+--------+-------+-------------+------------------+----------+--------+------------+-----------+----------------------------------+
| a1a8eb13-73c6-4090-a07d-3f7d01082853 | cirros | rbd   | qcow2       | bare             | 13200896 | active | 41126400   | Cached    | daedf05b4fec4e12b6397e293e2146cc |
+--------------------------------------+--------+-------+-------------+------------------+----------+--------+------------+-----------+----------------------------------+

cinder list --all-tenants

providernet create：
neutron providernet-create pronet \
--type=flat --description=description mtu=1500 \
--vlan-transparent=False

neutron providernet-create providernet-a --type=vlan

data interface add：
For example, to attach an interface named enp0s10 to a VLAN provider network named
providernet-a, using Ethernet interface enp0s10 on compute-0:

system host-if-modify -n enp0s10 \
-nt data compute-0 enp0s10 -p providernet-a
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| ifname           | enp0s10                              |
| networktype      | data                                 |
| iftype           | ethernet                             |
| ports            | [u'enp0s10']                         |
| providernetworks | providernet-a                        |
| imac             | 08:00:27:15:dc:53                    |
| imtu             | 1500                                 |
| aemode           | None                                 |
| schedpolicy      | None                                 |
| txhashpolicy     | None                                 |
| uuid             | d28176a4-7840-4368-8b29-0e7234aa2231 |
| ihost_uuid       | 00e05b1c-cfb6-4bc1-9dfd-34ae89343e48 |
| vlan_id          | None                                 |
| uses             | []                                   |
| used_by          | []                                   |
| created_at       | 2017-07-21T00:25:57.806373+00:00     |
| updated_at       | 2017-07-21T03:48:08.953172+00:00     |
| sriov_numvfs     | 0                                    |
| ipv4_mode        | disabled                             |
| ipv6_mode        | disabled                             |
| accelerated      | [u'True']                            |
+------------------+--------------------------------------+

Provisioning Storage on a Compute Host：
system host-lvg-add compute-0 nova-local
+-----------------+-------------------------------------------------------------------+
| Property        | Value                                                             |
+-----------------+-------------------------------------------------------------------+
| lvm_vg_name     | nova-local                                                        |
| vg_state        | adding                                                            |
| uuid            | e7f04ebf-f268-441c-a170-8353a37d940d                              |
| ihost_uuid      | 00e05b1c-cfb6-4bc1-9dfd-34ae89343e48                              |
| lvm_vg_access   | None                                                              |
| lvm_max_lv      | 0                                                                 |
| lvm_cur_lv      | 0                                                                 |
| lvm_max_pv      | 0                                                                 |
| lvm_cur_pv      | 0                                                                 |
| lvm_vg_size     | 0                                                                 |
| lvm_vg_total_pe | 0                                                                 |
| lvm_vg_free_pe  | 0                                                                 |
| created_at      | 2017-07-21T03:54:36.407894+00:00                                  |
| updated_at      | None                                                              |
| parameters      | {u'concurrent_disk_operations': 2, u'instance_backing': u'image'} |
+-----------------+-------------------------------------------------------------------+

system host-disk-list compute-0：
+--------------------------------------+-----------+---------+---------+----------+--------------+---------------------+
| uuid                                 | device_no | device_ | device_ | size_mib | rpm          | serial_id           |
|                                      | de        | num     | type    |          |              |                     |
+--------------------------------------+-----------+---------+---------+----------+--------------+---------------------+
| 5740b368-154d-4db0-b921-293afa7f70af | /dev/sda  | 2048    | HDD     | 614400   | Undetermined | VB2ca87894-21dae21c |
| 6fb8aaad-25a4-4c04-ac2b-604d408a61b2 | /dev/sdb  | 2064    | HDD     | 614400   | Undetermined | VBcf13ce05-efa98af3 |
+--------------------------------------+-----------+---------+---------+----------+--------------+---------------------+

system host-pv-add compute-0 nova-local 6fb8aaad-25a4-4c04-ac2b-604d408a61b2
+-------------------+--------------------------------------+
| Property          | Value                                |
+-------------------+--------------------------------------+
| uuid              | f09f6a17-f775-436b-970d-3c8a487e53f6 |
| pv_state          | adding                               |
| pv_type           | disk                                 |
| idisk_uuid        | 6fb8aaad-25a4-4c04-ac2b-604d408a61b2 |
| idisk_device_node | /dev/sdb                             |
| lvm_pv_name       | /dev/sdb                             |
| lvm_vg_name       | nova-local                           |
| lvm_pv_uuid       | None                                 |
| lvm_pv_size       | 0                                    |
| lvm_pe_total      | 0                                    |
| lvm_pe_alloced    | 0                                    |
| ihost_uuid        | 00e05b1c-cfb6-4bc1-9dfd-34ae89343e48 |
| created_at        | 2017-07-21T03:56:23.746206+00:00     |
| updated_at        | None                                 |
+-------------------+--------------------------------------+

system host-lvg-modify -s 2048 compute-0 nova-local
+-----------------+-------------------------------------------------------------------+
| Property        | Value                                                             |
+-----------------+-------------------------------------------------------------------+
| lvm_vg_name     | nova-local                                                        |
| vg_state        | adding                                                            |
| uuid            | e7f04ebf-f268-441c-a170-8353a37d940d                              |
| ihost_uuid      | 00e05b1c-cfb6-4bc1-9dfd-34ae89343e48                              |
| lvm_vg_access   | None                                                              |
| lvm_max_lv      | 0                                                                 |
| lvm_cur_lv      | 0                                                                 |
| lvm_max_pv      | 0                                                                 |
| lvm_cur_pv      | 0                                                                 |
| lvm_vg_size     | 0                                                                 |
| lvm_vg_total_pe | 0                                                                 |
| lvm_vg_free_pe  | 0                                                                 |
| created_at      | 2017-07-21T03:54:36.407894+00:00                                  |
| updated_at      | None                                                              |
| parameters      | {u'concurrent_disk_operations': 2, u'instance_backing': u'image'} |
+-----------------+-------------------------------------------------------------------+

system host-if-modify -n enp0s9 -nt infra compute-0 enp0s9
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| ifname           | enp0s9                               |
| networktype      | infra                                |
| iftype           | ethernet                             |
| ports            | [u'enp0s9']                          |
| providernetworks | None                                 |
| imac             | 08:00:27:42:7d:a7                    |
| imtu             | 1500                                 |
| aemode           | None                                 |
| schedpolicy      | None                                 |
| txhashpolicy     | None                                 |
| uuid             | c1f41846-b406-4b01-9305-90db8b7dfe31 |
| ihost_uuid       | 00e05b1c-cfb6-4bc1-9dfd-34ae89343e48 |
| vlan_id          | None                                 |
| uses             | []                                   |
| used_by          | []                                   |
| created_at       | 2017-07-21T00:25:57.679144+00:00     |
| updated_at       | 2017-07-21T04:01:11.142717+00:00     |
| sriov_numvfs     | 0                                    |
| ipv4_mode        | static                               |
| ipv6_mode        | disabled                             |
| accelerated      | [u'True']                            |
+------------------+--------------------------------------+

system host-unlock compute-0


```
### 网络设置
```s
内部网络:

网络模式：
1 Configuring PCI Passthrough Ethernet Interfaces
Select Admin > Platform > Host Inventory from the left-hand pane, click the Hosts tab, click
the name of the compute node where the PCI interface is available, click the Interfaces tab,
and finally click the Edit Interface button associated with the interface you want to configure.
Fill in the window as illustrated below:




```


### 随笔
```s

HP DL360 Gen9 8SFF CTO Server 	15.119.6.105	iLoadmin/1Qaz2wsx
CentOS 7	15.119.6.215	root/4QdLgDo6LF

15.119.6.155  administrator/KLh4bfnltK
跳转的机器: 10.43.168.32  用户密码CoeTest/Passw0rd

10.43.168.32

15.119.6.215
cubswin:)

4QdLgDo6LF

export http_proxy=http://proxy.sgp.hp.com:8080

nat 10.10.10.0
host 172.20.20.0
web-proxy.houston.hp.com:8080
web-proxy.sgp.hp.com:8080

一、用户（user）
表示拥有用户名，密码，邮箱等帐号信息的自然人
二、租户（tenant）
租户可以理解为一个项目，团队或组织
三、角色（role）
代表特定的租户中的用户用户操作权限，你可以理解租户为那些使用你云环境的客户

system host-unlock compute-0
Wrsroot123
Neil_1983

WRSROOT123
1.上传镜像命令为


system host-if-modify -n enp0s93 -nt data compute-1 enp0s3 -p pro-1

如果集群使用基础设施网络，则提供基础设施接口：
例如，要将一个名为“infra0”的VLAN接口与infrastructure network,连接在一起网络，在compute-1上使用以太网接口enp0s8:
system host-if-add compute-1 -V 22 -nt infra infra0 vlan enp0s9


scp -r dev@15.119.6.215:/home/dev/Downloads/pacthes .
sudo config_controller --config-file hcg

08:00:27:A7:88:FE

Nat列表信息删除：
iptables -t nat -D PREROUTING 1

iptables -t nat -I PREROUTING -p tcp -i vnet0 -d 15.119.6.215 --dport 122 -j DNAT --to 172.16.0.20:22

Jacky-1988315
ZXcv978,

dhcp-host=08:00:27:A2:79:ED,vmadmc0,172.16.0.20 #  adm-c0
dhcp-host=08:00:27:82:6F:FF,vmadmc1,172.16.0.21 # adm-c1
dhcp-host=08:08:27:00:00:04,vmstoc0,172.16.0.30 # adm-c1
dhcp-host=08:08:27:00:00:05,vmstoc1,172.16.0.31 # adm-c1
dhcp-host=08:08:27:00:00:06,vmcomc1,172.16.0.40 # adm-c1
dhcp-host=08:00:27:9A:25:2D,vmcomc1,172.16.0.89 # adm-c3
dhcp-host=08:00:27:32:C3:0B,vmcomc1,172.16.0.90 # adm-c3

#log
less /var/log/platform.log
less /var/log/fsmond.log
less var/log/mtcClient.log
less /var/log/hbsClient.log
less /var/log/mtclogd.log
less /var/log/kern.log

less /var/log/fsmond.log
less /var/log/daemon.log
less /var/log/bash.log
#节点配置进度
less /var/log/sm.log
less /var/log/hostwd.log
less /var/log/io-monitor.log
#ip情况
less /var/log/rmond.log

#/etc/pmon.d
less /var/log/pmond.log

less /tmp/configure_interfaces.log


tailf /var/log/daemon-ocf.log

tailf /var/log/sysinv.log
tailf /var/log/daemon.log

#安装日志
/var/log/daemon.log
/var/log/fm-event.log
/var/log/hbsAgent.log
/var/log/mtcAgent.log
/var/log/mtcAgent_api.log
/var/log/mtcAgent_event.log
/var/log/mtcalarmd.log



PXE服务器就是DHCP服务器+TFTP服务器
实现PXE网络安装必需的4个要素如下：
1. 客户机的网卡必须为PXE网卡（现在市面上的的网卡，不论是板载或是PCI网卡基本上都支持PXE，所以这个不成问题）
2. 网络中必须要有DHCP和TFTP服务器，当然这两个服务器可以是同一台物理主机
3. 所安装的操作系统必须支持网络安装，即必须提供自己的bootstrap
4. 必须要有FTP\HTTP\NFS至少一个服务器，当然也可以和DHCP和TFTP服务器同为一台物理主机

undo dhcp snooping enable

pex 192.168.101.0/24
mgmt 192.168.102.0/24 vlan102
infr 192.168.103.0/24 vlan103

data vlan104-106
192.168.104.0/24
192.168.105.0/24
192.168.106.0/24

oam 15.119.6.0/24
ZXcv978,

neutron net-list
neutron net-delete

neutron port-list
neutron port-delete

neutron subnet-list
neutron subnet-delete

neutron router-list
neutron router-delete

查看cinder
cinder list --all-tenants
导出文件
cinder export 2d454935-e1e4-4e4d-a803-1861000cec27
快照
cinder snapshot-create --force True --display-name test-vmsnapshot 2d454935-e1e4-4e4d-a803-1861000cec27
cinder snapshot-list --all-tenants

将快照导出控制器
cinder snapshot-export test-vm-snapshot
删除快照
cinder snapshot-delete test-vm-snapshot
cinder snapshot-force-delete snapshot-id [snapshot-id]

网络:
system host-port-list compute-0

```
