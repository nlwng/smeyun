<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [selinux介绍](#selinux介绍)
- [SElinux](#selinux)
	- [MAC](#mac)
	- [RBAC](#rbac)
	- [安全上下文](#安全上下文)
		- [安全上下文格式](#安全上下文格式)
			- [user](#user)
			- [role](#role)
			- [type](#type)
- [设置](#设置)
	- [模式设置](#模式设置)
	- [策略设置](#策略设置)
	- [cli](#cli)
- [SElinux应用](#selinux应用)

<!-- /TOC -->


# selinux介绍
```
SELinux(Security-Enhanced Linux) 是美国国家安全局（NAS）对于强制访问控 制的实现，
在这种访问控制体系的限制下，进程只能访问那些在他的任务中所需要文件。大部分使用 SELinux
的人使用的都是SELinux就绪的发行版，例如 Fedora、Red Hat Enterprise Linux (RHEL)、
Debian 或 Gentoo。它们都是在内核中启用SELinux 的，并且提供一个可定制的安全策略，
还提供很多用户层的库和工具，它们都可以使用 SELinux 的功能
```
# SElinux
## MAC
```
对访问的控制彻底化，对所有的文件、目录、端口的访问都是基于策略设定的，可由管理员时行设定
```
## RBAC
```
对于用户只赋予最小权限。用户被划分成了一些role(角色)，即使是root用户，如果不具有sysadm_r角色的话，
也不是执行相关的管理。哪里role可以执行哪些domain,也是可以修改的。
```
## 安全上下文
```
当启动selinux的时候，所有文件与对象都有安全上下文。进程的安全上下文是域，安全上下文由用户:角色:类型表示。
(1)系统根据pam子系统中的pam_selinux.so模块设定登录者运行程序的安全上下文
(2)rpm包安装会根据rpm包内记录来生成安全上下文，
(3)如果是手工他建的，会根据policy中规定来设置安全上下文，
(4)如果是cp，会重新生成安全上下文。
(5)如果是mv,安全上下文不变。
```
### 安全上下文格式
```
安全上下文由user:role:type三部分组成
```
####  user
```
user identity:类似linux系统中的UID，提供身份识别，安全上下文中的一部分

三种常见的user:
user_u-:   普通用户登录系统后预设；
system_u-：开机过程中系统进程的预设；
root-：    root登录后预设；
在targeted policy中users不是很重要；
在strict policy中比较重要，的有预设的selinuxusers都以 "_u"结尾，root除外。
```
#### role
```
文件与目录的role，通常是object_r；
程序的role，通常是system_r；
用户的role，targetedpolicy为system_r；
strict policy为sysadm_r，staff_r，user_r
用户的role，类似于系统中的GID，不同的角色具备不同的权限；用户可以具备多个role；但是同一时间内只能使用一role；
role是RBAC的基础；
```
#### type
```
type:用来将主体与客体划分为不同的组，组每个主体和系统中的客体定义了一个类型；为进程运行提供最低的权限环境。
当一个类型与执行的进程关联时，该type也称为domain，也叫安全上下文。
域或安全上下文是一个进程允许操作的列表，决字一个进程可以对哪种类型进行操作。
```

# 设置
配置文件：/etc/selinux/config

策略位置：/etc/selinux/<策略名>/policy/

## 模式设置
```
enforcing:强制模式，只要selinux不允许，就无法执行
permissive:警告模式，将该事件记录下来，依然允许执行
disabled:关闭selinux；停用，启用需要重启计算机。
```
## 策略设置
```
targeted:保护常见的网络服务，是selinux的默认值；
stric:提供RBAC的policy，具备完整的保护功能，保护网络服务，一般指令及应用程序。
策略改变后，需要重新启动计算机。
也可以通过命令来修改相关的具体的策略值，也就是修改安全上下文，来提高策略的灵活性。
```
## cli
```
查询selinux状态
sestatus

selinux激活状态<如果为-256为非激活状态>
selinuxenabled
echo $?

切换SElinux类型:<使用setenforce切换enforcing与permissive模式不需要重启计算机>
切换成警告模式
setenforce 0或setenforce permissive
sestatus
#getenforce
>>Permissive

切换成强制模式:
setenforce 1
#getenforce
>>Enforcing

检查安全上下文:
#id -Z
检查进程的安全上下文
#ps -Z
检查文件与目录的安全上下文
#ls -Z

修改文件/目录安全上下文与策略
1．chcon命令
chcon -u[user]  对象
      -r[role]
      -t[type]
      -R递归
示例：
chcon -R -tsamba_share_t /tmp/abc
注：安全上下文的简单理解说明，受到selinux保护的进程只能访问标识为自己只够访问的安全上下文的文件与目录。
例如：上面解释为使用smb进程能够访问/tmp/abc目录而设定的安全上下文。

2. getsebool命令
获取本机selinux策略值，也称为bool值。
getsebool-a  命令同sestatus -b
[root@redhatfiles]# getsebool -a
NetworkManager_disable_trans--> off
allow_cvs_read_shadow--> off
allow_daemons_dump_core--> on
allow_daemons_use_tty--> off
allow_execheap--> off
allow_execmem--> on
allow_execmod--> off
allow_execstack--> on
allow_ftpd_anon_write--> off  
allow_ftpd_full_access--> off
...
httpd_disable_trans--> off   

说明：selinux的设置一般通过两个部分完成的，一个是安全上下文，另一个是策略，策略值是对安全上下文的补充

3．setsebool命令
setsebool -Pallow_ftpd_anon_write=1
-P 是永久性设置，否则重启之后又恢复预设值。
示例：
[root@redhatfiles]# setsebool -P allow_ftpd_anon_write=1
[root@redhatfiles]# getsebool allow_ftpd_anon_write
allow_ftpd_anon_write--> on
说明：如果仅仅是安全上下文中设置了vsftpd进程对某一个目录的访问，配置文件中也允许可写，但
是selinux中策略中不允许可写，仍然不可写。所以基于selinux保护的服务中，安全性要高于很多。
```

# SElinux应用
