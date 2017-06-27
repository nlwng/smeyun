ubuntu install ceph


#安装 CEPH 部署工具
#install release key
wget -q -O- 'http://mirrors.163.com/ceph/keys/release.asc' | sudo apt-key add -

#添加Ceph软件包源，用Ceph稳定版（如 cuttlefish 、 dumpling 、 emperor 、 firefly 等等）替换掉 {ceph-stable-release}
echo deb http://mirrors.163.com/ceph/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

#更新你的仓库，并安装 ceph-deploy ：
sudo apt-get update && sudo apt-get install ceph-deploy

#CEPH 节点安装
# install ntp ssh
sudo apt-get install ntp
sudo apt-get install openssh-server

#creat ceph user
ssh user@ceph-server
sudo useradd -d /home/sme -m sme
sudo passwd sme

#确保各 Ceph 节点上新创建的用户都有 sudo 权限。
echo "sme ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sme
sudo chmod 0440 /etc/sudoers.d/sme


#把公钥拷贝到各 Ceph 节点，把下列命令中的 {username} 替换成前面创建部署 Ceph 的用户里的用户名

ssh-copy-id {username}@node1
ssh-copy-id {username}@node2
ssh-copy-id {username}@node3

（推荐做法）修改 ceph-deploy 管理节点上的 ~/.ssh/config 文件，这样 ceph-deploy 就能用你所建的用户名登录 Ceph 节点了，而无需每次执行 ceph-deploy 都要指定 --username {username} 。这样做同时也简化了 ssh 和 scp 的用法。把 {username} 替换成你创建的用户名。

Host node1
   Hostname node1
   User {username}
Host node2
   Hostname node2
   User {username}
Host node3
   Hostname node3
   User {username}

#open firewall
#若使用 iptables ，要开放 Ceph Monitors 使用的 6789 端口和 OSD 使用的 6800:7300 端口范围，命令如下

sudo iptables -A INPUT -i {iface} -p tcp -s {ip-address}/{netmask} --dport 6789 -j ACCEPT
/sbin/service iptables save
