<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [aide](#aide)
	- [aide安装](#aide安装)
	- [aide的相关用法](#aide的相关用法)
	- [初始化数据库](#初始化数据库)
- [sudo](#sudo)

<!-- /TOC -->


# aide
```
aide (Advanced Intrusion Detection Environment)  
高级入侵检测环境)是个入侵检测工具，主要用途是检查文档的完整性

AIDE能够构造一个指定文档的数据库，他使用aide.conf作为其配置文档。AIDE数据库能够保存文档的各种属性，
包括：权限(permission)、索引节点序号(inode number)、所属用户(user)、所属用户组(group)、文档大小、
最后修改时间(mtime)、创建时间(ctime)、最后访问时间(atime)、增加的大小连同连接数。AIDE还能够使用下列算法：
sha1、md5、rmd160、tiger，以密文形式建立每个文档的校验码或散列号。

动态连接库、头文档连同其他总是保持不变的文档。这个数据库不应该保存那些经常变动的文档信息，
例如：日志文档、邮件、/proc文档系统、用户起始目录连同临时目录。

一旦发现系统被侵入，系统管理员可能会使用ls、ps、netstat连同who等系统工具对系统进行检查，
但是任何这些工具都可能被特洛伊木马程式代替了。能够想象被修改的ls程式将不会显示任何有关入侵的文档信息，
ps也不会显示任何入侵进程的信息。即使系统管理员已把关键的系统文档的日期、
大小等信息都打印到了纸上，恐怕也无法通过比较知道他们是否被修改过了，因为文档日期、
大小等信息是很容易改变的，一些比较好的rootkit能够很轻松地对这些信息进行假冒。

虽然文档的日期、大小等信息可能被假冒，但是假冒某个文档的一个加密校验码(例如：mk5)就很困难了，
更不要说假冒任何AIDE支持的校验码了。在系统被侵入后，系统管理员只要重新运行AIDE，
就能够很快识别出哪些关键文档被攻击者修改过了。

但是，要注意这也不是绝对的，因为AIDE可执行程式的二进制文档本身可能被修改了或数据库也被修改了。
因此，应该把AIDE的数据库放到安全的地方，而且进行检查时要使用确保没有被修改过的程式。
```
## aide安装
```
#tar zxvf aide-版本号.tar.gz
#cd aide-版本号
#./configure
#make
#make install

yum安装aide：
yum install aide -y
安装完成后我们可以来查看安装AIDE后到底安装了那些文件：
# rpm -ql aide
/etc/aide.conf       aide的主要配置文件
/usr/sbin/aide       aide主要可以执行程序
/usr/share/doc/aide-0.13.1
/usr/share/doc/aide-0.13.1/AUTHORS
/usr/share/doc/aide-0.13.1/COPYING
/usr/share/doc/aide-0.13.1/ChangeLog
/usr/share/doc/aide-0.13.1/NEWS
/usr/share/doc/aide-0.13.1/README
/usr/share/doc/aide-0.13.1/README.quickstart
/usr/share/doc/aide-0.13.1/contrib
/usr/share/doc/aide-0.13.1/contrib/bzip2.sh
/usr/share/doc/aide-0.13.1/contrib/gpg2_check.sh
/usr/share/doc/aide-0.13.1/contrib/gpg2_update.sh
/usr/share/doc/aide-0.13.1/contrib/gpg_check.sh
/usr/share/doc/aide-0.13.1/contrib/gpg_update.sh
/usr/share/doc/aide-0.13.1/contrib/sshaide.sh
/usr/share/doc/aide-0.13.1/manual.html
/usr/share/man/man1/aide.1.gz
/usr/share/man/man5/aide.conf.5.gz
/var/lib/aide              存放aide生成的数据库的目录
/var/log/aide              存放aide相关的日志文件

```

## aide的相关用法
```
-i --init 初始化数据库
 -C     检测数据文件是否发生改变
 -u     检测和更新数据库
```

## 初始化数据库
```
[root@master ~]# aide --init
初始化后我们可以再存放数据库中的目录产看生成的数据库
[root@master ~]# ls /var/lib/aide/
aide.db.new.gz

#此时我们需要根据配置文件修改数据库的名称

#The location of the database to be read.
database=file:@@{DBDIR}/aide.db.gz
#The location of the database to be written.
#database_out=sql:host:port:database:login_name:passwd:table
#database_out=file:aide.db.new
database_out=file:@@{DBDIR}/aide.db.new.gz
[root@master aide]# mv aide.db.new.gz aide.db.gz

然后我们修改aide所监控的文件测试是否可以检测出来
/etc/exports  NORMAL
/etc/fstab    NORMAL
/etc/passwd   NORMAL
/etc/group    NORMAL
/etc/gshadow  NORMAL
/etc/shadow   NORMAL

以上这些文件是aide需要监控的，NORMAL为NORMAL = R+rmd160+sha256，就是说使用这些算法来哈希该文件
我们在/etc/fstab中增加一个空行，然后：
[root@master ~]# aide -C
changed: /etc/fstab
changed: /etc/gshadow-
changed: /etc/shadow-
changed: /etc/group-
changed: /etc/passwd-
```

# sudo
```
直接sudo权限账号设置
/etc/sudoers.d
file:sme-1.0-admin
admin ALL=(ALL) ALL

特殊文件权限设置
file:sme-1.0-sib
#Copy to /etc/sudoers.d/; chmod 440 ThisFile
Cmnd_Alias SIB = /opt/SIU_sib/SIB/bin/sib-nginx.sh,/tmp/post-uninstall-as-root.sh,/opt/SIU_sib/SIB/bin/post-install-as-root.sh,/usr/bin/timedatectl
sib    ALL=(root)      NOPASSWD:SIB
```
