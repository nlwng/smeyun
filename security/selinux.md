<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1 selinux介绍](#1-selinux介绍)
- [2 SElinux](#2-selinux)
	- [2.1 MAC](#21-mac)
	- [2.2 RBAC](#22-rbac)
	- [2.3 安全上下文](#23-安全上下文)
		- [2.3.1 安全上下文格式](#231-安全上下文格式)
- [3 设置](#3-设置)
	- [3.1 模式设置](#31-模式设置)
	- [3.2 策略设置](#32-策略设置)
	- [3.3 selinux cli](#33-selinux-cli)
- [4 SElinux应用](#4-selinux应用)
	- [4.1 SElinux与samba](#41-selinux与samba)
	- [4.2 SElinux与nfs](#42-selinux与nfs)
	- [4.3 SElinux与ftp](#43-selinux与ftp)
	- [4.4 SElinux与http](#44-selinux与http)
	- [4.5 SElinux与公共目录共享](#45-selinux与公共目录共享)
	- [4.6 SELinux对Apache的保护](#46-selinux对apache的保护)

<!-- /TOC -->


# 1 selinux介绍
```
SELinux(Security-Enhanced Linux) 是美国国家安全局（NAS）对于强制访问控 制的实现，
在这种访问控制体系的限制下，进程只能访问那些在他的任务中所需要文件。大部分使用 SELinux
的人使用的都是SELinux就绪的发行版，例如 Fedora、Red Hat Enterprise Linux (RHEL)、
Debian 或 Gentoo。它们都是在内核中启用SELinux 的，并且提供一个可定制的安全策略，
还提供很多用户层的库和工具，它们都可以使用 SELinux 的功能

SELinux 全称 Security Enhanced Linux (安全强化 Linux)，是 MAC (Mandatory Access Control，  
强制访问控制系统)的一个实现，目的在于明确的指明某个进程可以访问哪些资源(文件、网络端口等)。
```
# 2 SElinux
## 2.1 MAC
```
对访问的控制彻底化，对所有的文件、目录、端口的访问都是基于策略设定的，可由管理员时行设定
```
## 2.2 RBAC
```
对于用户只赋予最小权限。用户被划分成了一些role(角色)，即使是root用户，如果不具有sysadm_r角色的话，
也不是执行相关的管理。哪里role可以执行哪些domain,也是可以修改的。
```
## 2.3 安全上下文
```
当启动selinux的时候，所有文件与对象都有安全上下文。进程的安全上下文是域，安全上下文由用户:角色:类型表示。
(1)系统根据pam子系统中的pam_selinux.so模块设定登录者运行程序的安全上下文
(2)rpm包安装会根据rpm包内记录来生成安全上下文，
(3)如果是手工他建的，会根据policy中规定来设置安全上下文，
(4)如果是cp，会重新生成安全上下文。
(5)如果是mv,安全上下文不变。
```
### 2.3.1 安全上下文格式
```
安全上下文由user:role:type三部分组成

1. user identity:类似linux系统中的UID，提供身份识别，安全上下文中的一部分
三种常见的user:
user_u-:   普通用户登录系统后预设；
system_u-：开机过程中系统进程的预设；
root-：    root登录后预设；
在targeted policy中users不是很重要；
在strict policy中比较重要，的有预设的selinuxusers都以 "_u"结尾，root除外。

2. 文件与目录的role，通常是object_r；
程序的role，通常是system_r；
用户的role，targetedpolicy为system_r；
strict policy为sysadm_r，staff_r，user_r
用户的role，类似于系统中的GID，不同的角色具备不同的权限；用户可以具备多个role；但是同一时间内只能使用一role；
role是RBAC的基础；

3. type:用来将主体与客体划分为不同的组，组每个主体和系统中的客体定义了一个类型；为进程运行提供最低的权限环境。
当一个类型与执行的进程关联时，该type也称为domain，也叫安全上下文。
域或安全上下文是一个进程允许操作的列表，决字一个进程可以对哪种类型进行操作。
```
## 3.3
```
（1）chcon 命令
作用：chcon 命令用来改变 SELinux 文件属性即修改文件的安全上下文
用法：chcon [ 选项 ] CONTEXT 文件
主要选项 :
-R：递归改变文件和目录的上下文。
--reference：从源文件向目标文件复制安全上下文
-h, --no-dereference：影响目标链接。
-v, --verbose：输出对每个检查文件的诊断。
-u, --user=USER：设置在目标用户的安全上下文。
-r,--role=ROLE：设置目标安全领域的作用。
-t, --type=TYPE：在目标设定的安全上下文类型。
-l, --range=RANGE：设置 set role ROLE in the target security context 目标安全领域的范围。
-f：显示少量错误信息。

（2）restorecon 命令
作用：恢复 SELinux 文件属性文件属性即恢复文件的安全上下文
用法：restorecon [-iFnrRv] [-e excludedir ] [-o filename ] [-f filename | pathname...]
主要选项 :
-i：忽略不存在的文件。
-f：infilename 文件 infilename 中记录要处理的文件。
-e：directory 排除目录。
-R – r：递归处理目录。
-n：不改变文件标签。
-o outfilename：保存文件列表到 outfilename，在文件不正确情况下。
– v：将过程显示到屏幕上。
-F：强制恢复文件安全语境。
说明；restorecon 命令和 chcon 命令类似，但它基于当前策略默认文件上下文文件设置与文件有关
的客体的安全上下文，因此，用户没有指定一个安全上下文，相反，restorecon 使用文件上下文文件
的条目匹配文件名，然后应用特定的安全上下文，在某些情况下，它是在还原正确的安全上下文。

（3）semanage fcontext 命令
作用：管理文件安全上下文
用法：
semanage fcontext [-S store] -{a|d|m|l|n|D} [-frst] file_spec
semanage fcontext [-S store] -{a|d|m|l|n|D} -e replacement target
主要选项 :
-a：添加
-d：删除
-m：修改
-l：列举
-n：不打印说明头
-D：全部删除
-f：文件
-s：用户
-t：类型
r：角色
```

# 3 设置
配置文件：/etc/selinux/config  
策略位置：/etc/selinux/<策略名>/policy/  

## 3.1 模式设置
```
enforcing:强制模式，只要selinux不允许，就无法执行
permissive:警告模式，将该事件记录下来，依然允许执行
disabled:关闭selinux；停用，启用需要重启计算机。
```
## 3.2 策略设置
```
targeted:保护常见的网络服务，是selinux的默认值；
stric:提供RBAC的policy，具备完整的保护功能，保护网络服务，一般指令及应用程序。
策略改变后，需要重新启动计算机。
也可以通过命令来修改相关的具体的策略值，也就是修改安全上下文，来提高策略的灵活性。
```
## 3.3 selinux cli
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

# 4 SElinux应用
## 4.1 SElinux与samba
```
1．samba共享的文件必须用正确的selinux安全上下文标记。
chcon -R -t samba_share_t /tmp/abc
如果共享/home/abc，需要设置整个主目录的安全上下文。
chcon -R -r samba_share_t /home
2．修改策略(只对主目录的策略的修改)
setsebool -P samba_enable_home_dirs=1
setsebool -P allow_smbd_anon_write=1
getsebool 查看
samba_enable_home_dirs -->on
allow_smbd_anon_write --> on
```
## 4.2 SElinux与nfs
```
selinux对nfs的限制好像不是很严格，默认状态下，不对nfs的安全上下文进行标记，
而且在默认状态的策略下，nfs的目标策略允许nfs_export_all_ro
nfs_export_all_ro
nfs_export_all_rw值为0
所以说默认是允许访问的。
但是如果共享的是/home/abc的话，需要打开相关策略对home的访问。
setsebool -Puse_nfs_home_dirs boolean 1
getsebooluse_nfs_home_dirs
```

## 4.3 SElinux与ftp
```
1．如果ftp为匿名用户共享目录的话，应修改安全上下文。
chcon -R -t public_content_t /var/ftp
chcon -R -t public_content_rw_t /var/ftp/incoming
2．策略的设置
setsebool -P allow_ftpd_anon_write =1
getsebool allow_ftpd_anon_write
allow_ftpd_anon_write--> on
```
## 4.4 SElinux与http
```
apache的主目录如果修改为其它位置，selinux就会限制客户的访问。
1．修改安全上下文：
chcon -R -t httpd_sys_content_t /home/html
由于网页都需要进行匿名访问，所以要允许匿名访问。
2．修改策略：
setsebool -P allow_ftpd_anon_write = 1
setsebool -P allow_httpd_anon_write = 1
setsebool -P allow_<协议名>_anon_write =1
关闭selinux对httpd的保护
httpd_disable_trans=0
```

## 4.5 SElinux与公共目录共享
```
如果ftp,samba,web都访问共享目录的话，该文件的安全上下文应为：
public_content_t
public_content_rw_t
其它各服务的策略的bool值，应根据具体情况做相应的修改。
```

## 4.6 SELinux对Apache的保护
```
新安装的wordpress位于/vogins/share/wordpress下，按照系统的默认策略，
/vogins,/vogins/share的SELinux属性为file_t，而这是不允许httpd进程直接访问的：

1) 改变/vogins,/vogins/share的SELinux属性
Shell>chcon –t var_t /vogins
Shell>chcon –t var_t /vogins/share
2) 改变wrodpress目录的SELinux属性
Shell>chcon –R –t httpd_sys_content_t wordpress
3) 允许apache进程访问mysql
setsebool -Phttpd_can_network_connect=1
4) 关于Apache里虚拟主机的配制就里就不多说，重新启动apache，就可以正常访问wordpress
Shell>/etc/init.d/httpd start
注意：如果出现不能访问的情况，请查看/var/log/messages里的日志。按照提示就可以解决了。
```

## 4.7 让 Apache 可以访问位于非默认目录下的网站文件
```
获知默认 /var/www 目录的 SELinux 上下文:
semanage fcontext -l | grep '/var/www'

假设希望 Apache 使用 /srv/www 作为网站文件目录，那么就需要给这个目录下的文件增加 httpdsyscontent_t 标签，分两步实现
1.为 /srv/www 这个目录下的文件添加默认标签类型：semanage fcontext -a -t httpd_sys_content_t '/srv/www(/.*)?'
然后用新的标签类型标注已有文件：restorecon -Rv /srv/www 之后 Apache 就可以使用该目录下的文件构建网站了。

2.让 Apache 侦听非标准端口,Apache只侦听80和443两个端口,若是直接指定其侦听888端口的话
semanage port -a -t http_port_t -p tcp 888

3.允许 Apache 访问创建私人网站
若是希望用户可以通过在 ~/public_html/ 放置文件的方式创建自己的个人网站的话，那么需要在 Apache 策略中允许该操作执行
setsebool -P httpd_enable_homedirs 1

semanage port -l | grep -w http_port_t
```

## 4.8 SELinux 环境下的 MySQL 配置
```
SELinux 针对 MySQL 定义的的文件类型:
mysqld_db_t 这种文件类型用于标记 MySQL 数据库的位置。在红帽企业 Linux 中数据库的默认位置
是 /var/lib/mysql。如果 MySQL 数据库的位置发生了变化，新的位置必须使用这种类型。
mysqld_etc_t 这种文件类型用于标记 MySQL 的主配置文件中的 /etc/my.cnf 文件和 /etc/mysql 目录中的文件。
mysqld_exec_t 这种文件类型用于标记 /usr/libexec/mysqld 程序文件。
mysqld_initrc_exec_t 这种文件类型用于标记 MySQL 的初始化文件 /etc/rc.d/init.d/mysqld。
mysqld_log_t 这种文件类型用于标记日志文件。
mysqld_var_run_t 这种文件类型用于标记 /var/run/mysqld 目录中文件，尤其是 /var/run/mysqld/mysqld.pid
和 /var/run/mysqld/mysqld.sock。

MySQL 的布尔变量:
allow_user_mysql_connect 当开放这个布尔变量时允许用户连接数据库。
exim_can_connect_db 当开放这个布尔变量时允许 exim 邮件程序访问数据库服务器。
ftpd_connect_db 当开放这个布尔变量时允许 ftpd 进程访问数据库服务器。
httpd_can_network_connect_db 当开放这个布尔变量时允许 httpd 进程访问数据库服务器。

配置实例,修改 MySQL 的存储数据库位置:
# ls -lZ /var/lib/mysql
drwx------. mysql mysql unconfined_u:object_r:mysqld_db_t:s0 mysql

记录下 MySQL 的存储数据库位置（/var/lib/mysql）的 SElinux 属性，然后停止 MySQL，
然后建立一个新的目录，把原来的数据库文件复制到新目录，并且设置 SElinux 属性
#service mysqld stop
#mkdir -p /opt/mysql
#cp -R /var/lib/mysql/* /opt/mysql/
#chmod 755 /opt/mysql
#chown -R mysql:mysql /opt/mysql
#semanage fcontext -a -t mysqld_db_t "/opt/mysql(/.*)?":
#restorecon -R -v /opt/mysql

修改配置文件 /etc/my.cnf 重启 MySQL:
#vi /etc/my.cnf
[mysqld]
datadir=/opt/mysql
# service mysqld start
```

## 4.9 SELinux 环境下的 DNS 配置
