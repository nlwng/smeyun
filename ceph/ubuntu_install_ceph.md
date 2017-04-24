#ubuntu install ceph
Ceph OSD (ceph-osd)
控制数据存储，数据复制和恢复。Ceph 集群需要至少两个 Ceph OSD 服务器。这次安装中我们将使用三个 Ubuntu 16.04 服务器。
Ceph Monitor (ceph-mon)
监控集群状态并运行 OSD 映射 和 CRUSH 映射。这里我们使用一个服务器。
Ceph Meta Data Server (ceph-mds)
如果你想把 Ceph 作为文件系统使用，就需要这个。

#xfs
sudo apt-get install xfsprogs

#install release key
wget -q -O- 'http://mirrors.163.com/ceph/keys/release.asc' | sudo apt-key add -
#添加Ceph软件包源，用Ceph稳定版（如 cuttlefish 、 dumpling 、 emperor 、 firefly 等等）替换掉 {ceph-stable-release}
echo deb http://mirrors.163.com/ceph/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

export CEPH_DEPLOY_REPO_URL=http://mirrors.163.com/ceph/debian-luminous
export CEPH_DEPLOY_GPG_URL=http://mirrors.163.com/ceph/keys/release.asc

#更新你的仓库，并安装 ceph-deploy ：
sudo apt-get update && sudo apt-get install ceph-deploy

#hosts
192.168.129.129 node1
192.168.129.130 node2
192.168.129.131 node3
#设置hostname
hostname node1;hostname > /etc/hostname
hostname node2;hostname > /etc/hostname
hostname node3;hostname > /etc/hostname

#创建账户ceph
sudo useradd -d /home/ceph -m ceph
sudo passwd ceph

#每个节点增加root权限
echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
sudo chmod 0440 /etc/sudoers.d/ceph

echo "neildev ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/neildev
sudo chmod 0440 /etc/sudoers.d/neildev

#config
Host node1
   Hostname node1
   User neildev
Host node2
   Hostname node2
   User neildev
Host node3
      Hostname node3
      User neildev

#key分发
#admin节点上
ssh-keygen
ssh-copy-id node1;ssh-copy-id node2;ssh-copy-id node3

#要创建您的Ceph的存储集群，生成一个文件系统ID（FSID），在命令行提示符下输入以下命令，生成监视器的秘钥
#ceph-deploy purgedata node1 node2 node3
#ceph-deploy forgetkeys

#在管理模式下，请使用ceph-deploy创建集群
# 注：当前目录下会生成ceph.conf ceph.mon.keyring ceph.log 配置文件，密钥环，日志文件
mkdir ceph;cd ceph
ceph-deploy new node1 node2 node3

#指定版本安装
ceph-deploy install --release luminous node1 node2 node3

#ceph-deploy uninstall node1 node2 node3    如果需要重装，可以此两条命令删除ceph
#apt-get remove --purge node1 node2 node3

#配置初始 monitor(s)、并收集所有密钥
ceph-deploy mon create-initial

一旦你收集到密钥，在本地目录下可看到如下密钥环文件：
{cluster-name}.client.admin.keyring
{cluster-name}.bootstrap-osd.keyring
{cluster-name}.bootstrap-mds.keyring
{cluster-name}.bootstrap-rgw.keyring

-------------------------------------
重要挂载步骤-目录式
-------------------------------------
#添加3个OSD
ssh node1 "sudo mkdir /var/local/osd1;exit"
ssh node2 "sudo mkdir /var/local/osd2;exit"
ssh node3 "sudo mkdir /var/local/osd3;exit"

#从管理节点执行 ceph-deploy 来准备 OSD 。
ceph-deploy osd prepare node1:/var/local/osd1 node2:/var/local/osd2 node3:/var/local/osd3
sudo chown -R ceph.ceph  /var/local/osd*

#激活 OSD
ceph-deploy osd activate node1:/var/local/osd1 node2:/var/local/osd2 node3:/var/local/osd3

#分发配置文件和秘钥到管理和ceph节点
ceph-deploy admin node1 node2 node3
ceph-deploy --overwrite-conf admin node1 node2 node3

#确保你对 ceph.client.admin.keyring 有正确的操作权限。
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

#检查集群的健康状况
ceph health
-------------------------------------
重要挂载步骤-数据盘式：http://docs.ceph.org.cn/rados/deployment/ceph-deploy-osd/
-------------------------------------






创建osd目录挂载点
注:disk是5G，这里只划出1G，剩余空间暂时留作它用。
创建磁盘分区
fdisk /dev/sdc     注：下边有输出记录

创建挂载点
mkdir -p /var/lib/ceph/osd/ceph-osd0

格式化分区：荐用xfs或btrfs文件系统，命令是mkfs
mkfs.xfs -f /dev/sdc1
mount /dev/sdc1 /var/lib/ceph/osd/ceph-osd0                 注：加-o user_xattr 报错，提示bad option
mount -o remount,user_xattr /var/lib/ceph/osd/ceph-osd0     注：文件系统上添加user_xattr选项，remount不需要完全卸载文件系统
vi /etc/fstab
/dev/sdc1 /var/lib/ceph/osd/ceph-osd0 xfs defaults 0 0    注：自已添加，官方文档没此步骤
/dev/sdc1 /var/lib/ceph/osd/ceph-osd0 xfs remount,user_xattr 0 0

(7)管理模式下添加OSD节点并激活OSD

cd /home/mengfei/my-cluster

    注：一定要到此目录下执行，因为创建集群ceph时会自动在此目录下生成ceph.conf.运行ceph-deploy时会自动分发，不在此目录下执行会提示“Cannot load config”
    有些配置是需要在my-cluster/ceph.conf修改的，比如：ceph-osd0/journal 默认可能需要很大，所以我就在my-cluter/ceph.conf做了修改：

    osd journal size = 100         journal大小100M，如果mount点够大，快速安装就无所谓了，我的空间小，就设定了100
    osd pool default size = 3      (配置存储对象副本数=对象+副本)
    osd pool default min_size = 1  (配置存储对象最小副本数)
    osd crush chooseleaf type = 1  (使用在CRUSH规则chooseleaf斗式。使用序号名称而非军衔,默认是1)

ceph-deploy osd prepare controller:/var/lib/ceph/osd/ceph-osd0
ceph-deploy osd prepare network:/var/lib/ceph/osd/ceph-osd1
ceph-deploy osd activate controller:/var/lib/ceph/osd/ceph-osd0
ceph-deploy osd activate network:/var/lib/ceph/osd/ceph-osd1
        注：有时执行时会提示--overwirte-conf

     root@compute:/home/mengfei/my-cluster# ceph-deploy osd prepare controller:/var/lib/ceph/osd/ceph-osd0

(8)复制配置文件和管理密钥到管理节点和你的Ceph节点
   注：使用ceph-deploy命令将配置文件和管理密钥复制到管理节点和你的Ceph节点。
       下次你再使用ceph命令界面时就无需指定集群监视器地址，执行命令时也无需每次都指定ceph.client.admin.keyring
ceph-deploy admin compute controller network   (注：有时提示需要--overwrite-conf,实例中需要指定)
     root@compute:/home/mengfei/my-cluster# ceph-deploy admin compute controller network

(9)验证osd
ceph osd tree   查看状态
ceph osd dump   查看osd配置信息
ceph osd rm     删除节点 remove osd(s) <id> [<id>...]
ceph osd crush rm osd.0   在集群中删除一个osd 硬盘 crush map
ceph osd crush rm node1   在集群中删除一个osd的host节点

     root@compute:/home/mengfei/my-cluster# ceph osd tree   （weight默认是0）
     # id    weight  type name       up/down reweight

# [ceph_deploy.mon][ERROR ] RuntimeError: config file /etc/ceph/ceph.conf exists with different content; use --overwrite-conf to overwrite4
#配置文件的内容不一致，加上--overwrite-conf这个参数的意思就是用这个新的配置文件内容覆盖，也就是说不管内容一不一致，你就强制就要用这个配置文件
ceph-deploy --overwrite-conf mon create-initial

#[ERROR ] admin_socket: exception getting command descriptions: [Errno 2] No such file or directory
hostname要与在集群中的名字一致，否则ceph-deploy会失败
