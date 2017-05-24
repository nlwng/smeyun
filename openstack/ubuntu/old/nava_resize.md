<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

 - [配置文件](#配置文件)

  - [配置互信](#配置互信)

<!-- /TOC -->

 # 配置文件

修改控制节点和各个控制节点的nova.conf文件

```
crudini --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host True
crudini --set /etc/nova/nova.conf DEFAULT scheduler_default_filters AllHostsFilter
```

重启服务<br>
重启控制节点服务

```
service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
```

重启计算节点服务(每个 计算节点都要执行)<br>
service nova-compute restart

# 配置互信

开启nova用户的登录权限<br>
usermod -s /bin/bash nova

生成秘钥(控制节点和所有计算节点)

```
su - nova
$ /usr/bin/ssh-keygen -t rsa
$ /usr/bin/ssh-keygen -t dsa
```

配置config

```
cat << EOF > ~/.ssh/config
Host *
StrictHostKeyChecking no  
UserKnownHostsFile=/dev/null
EOF
```

分发计算节点秘钥到控制节点<br>
compute1

```
scp ~/.ssh/id_dsa.pub controller:~/.ssh/id_dsa.pub1
scp ~/.ssh/id_rsa.pub controller:~/.ssh/id_rsa.pub1
```

computer2

```
scp ~/.ssh/id_dsa.pub controller:~/.ssh/id_dsa.pub2
scp ~/.ssh/id_rsa.pub controller:~/.ssh/id_rsa.pub2
```

控制节点导入秘钥:<br>
controller

```
cat id_dsa.pub id_dsa.pub2 id_rsa.pub id_rsa.pub2 id_rsa.pub3 id_dsa.pub3 > authorized_keys
chmod 644 authorized_keys
```

将控制节点秘钥分发到计算节点

```
scp authorized_keys computer1:~/.ssh/
scp authorized_keys computer2:~/.ssh/
```

# kvm远程访问

centos下需要开启kvm远程访问才能实现动态扩容.<br>
参考:<https://www.chenyudong.com/archives/libvirt-connect-to-libvirtd-with-tcp-qemu.html>

virsh -c qemu+tcp://example.com/system

```
修改文件vim /etc/sysconfig/libvirtd，用来启用tcp的端口
LIBVIRTD_CONFIG=/etc/libvirt/libvirtd.conf
LIBVIRTD_ARGS="--listen"
```

修改文件vim /etc/libvirt/libvirtd.conf

```
listen_tls = 0
listen_tcp = 1
tcp_port = "16509"
listen_addr = "0.0.0.0"
auth_tcp = "none"
```

service libvirtd restart

```
如果没起效果(我的就没有生效 :( )，那么使用命令行:
libvirtd --daemon --listen --config /etc/libvirt/libvirtd.conf
```

在source host连接dest host远程libvirtd查看信息:

```
virsh -c qemu+tcp://211.87.***.97/system
```
