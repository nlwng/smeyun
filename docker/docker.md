<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [docker实践](#docker实践)
- [1 安装docker](#1-安装docker)
	- [1.1 ubuntu环境安装](#11-ubuntu环境安装)
	- [1.2 centos环境安装](#12-centos环境安装)
	- [1.3 测试docker](#13-测试docker)
	- [1.4 Upgrade Docker](#14-upgrade-docker)
	- [1.5 卸载Docker](#15-卸载docker)
	- [1.6 使用 DaoCloud 镜像站点，高速安装Docker](#16-使用-daocloud-镜像站点高速安装docker)
- [2 docker使用](#2-docker使用)
	- [2.1 基本信息查看](#21-基本信息查看)
	- [2.2 指定用户启动](#22-指定用户启动)
	- [2.3 进入正在运行的docker容器](#23-进入正在运行的docker容器)
	- [2.4 删除容器](#24-删除容器)
	- [2.5 再次启动容器](#25-再次启动容器)
	- [2.6 查看容器](#26-查看容器)
	- [2.7 使用镜像创建容器](#27-使用镜像创建容器)
	- [2.8 镜像的获取与容器的使用](#28-镜像的获取与容器的使用)
	- [2.9 容器资源限制参数](#29-容器资源限制参数)
	- [2.10 docker容器随系统自启参数](#210-docker容器随系统自启参数)
	- [2.11 查看容器状态信息](#211-查看容器状态信息)
- [3 docker实例子](#3-docker实例子)
	- [3.1 mysql in docker](#31-mysql-in-docker)
	- [3.2 nginx in docker](#32-nginx-in-docker)
	- [3.3](#33)

<!-- /TOC -->

# docker实践
# 1 安装docker
## 1.1 ubuntu环境安装
```
apt-get update
apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"

apt-get update
apt-get -y install docker-engine

apt-cache madison docker-engine
apt-get -y install docker-engine=<VERSION_STRING>
```

```
安装Docker：
Docker有deb格式的安装包，安装起来非常的容易。首先添加Docker库的密钥。
pt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

然后把Docker的库添加到apt的源列表中，更新并安装lxc-docker包。

sh -c "echo deb http://get.docker.io/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker

下载ubuntu镜像并启动一个镜像来验证安装是否正常。
docker run -i -t ubuntu /bin/bash
```
## 1.2 centos环境安装
Uninstall old versions:  
yum remove docker docker-common container-selinux docker-selinux docker-engine  
rpm -Uvh http://ftp.riken.jp/Linux/fedora/epel/6Server/x86_64/epel-release-6-8.noarch.rpm  
yum install -y docker-io   

开机自启动与启动Docker  
service docker start  
chkconfig docker on  

更改配置文件  
vim /etc/sysconfig/docker  
other-args列更改为：other_args="--exec-driver=lxc --selinux-enabled"  
docker search centos  

需要改/etc/sysconfig/network-scripts/ifcfg-eth0  
PEERDNS=no  

## 1.3 测试docker
docker run hello-world

## 1.4 Upgrade Docker
https://apt.dockerproject.org/repo/pool/main/d/docker-engine/
dpkg -i /path/to/package.deb
docker run hello-world

## 1.5 卸载Docker
apt-get purge docker-engine
rm -rf /var/lib/docker


## 1.6 使用 DaoCloud 镜像站点，高速安装Docker
修改Docker配置文件/etc/default/docker如下：
DOCKER_OPTS="--registry-mirror=http://aad0405c.m.daocloud.io"

# 2 docker使用
## 2.1 基本信息查看
```
docker version # 查看docker的版本号，包括客户端、服务端、依赖的Go等
docker info # 查看系统(docker)层面信息，包括管理的images, containers数等
docker pull centos 下载
docker images [ centos ] 查看
docker run -i -t centos /bin/bash
```

## 2.2 指定用户启动
```
docker exec -u root -it  a1b1da01d34f bash
```

## 2.3 进入正在运行的docker容器
```
docker exec -it [container_id] /bin/bash
docker run -i -t -p <host_port:contain_port> #映射 HOST 端口到容器，方便外部访问容器内服务，host_port 可以省略，
省略表示把 container_port 映射到一个动态端口。
```
## 2.4 删除容器
```
docker rm <container...> #：删除一个或多个container
docker rm `docker ps -a -q` #：删除所有的container
docker ps -a -q | xargs docker rm #：同上, 删除所有的container
```
## 2.5 再次启动容器
```
docker start/stop/restart <container> #：开启/停止/重启container
docker start [container_id] #：再次运行某个container （包括历史container）
```

## 2.6 查看容器
```
docker ps ：列出当前所有正在运行的container
docker ps -l ：列出最近一次启动的container
docker ps -a ：列出所有的container（包含历史，即运行过的container）
docker ps -q ：列出最近一次运行的container ID
```

## 2.7 使用镜像创建容器
```
docker run -i -t sauloal/ubuntu14.04
docker run -i -t sauloal/ubuntu14.04 /bin/bash # 创建一个容器，让其中运行 bash 应用，退出后容器关闭
docker run -itd --name centos_aways --restart=always centos #创建一个名称centos_aways的容器，自动重启
															#--restart参数：always始终重启；on-failure退出状态非0时重启；默认为，no不重启

```

## 2.8 镜像的获取与容器的使用
搜索镜像  
docker search <image> # 在docker index中搜索image
下载镜像  
docker pull <image>  # 从docker registry server 中下拉image  
查看镜像  
docker images:# 列出images  
docker images -a # 列出所有的images（包含历史）  
docker rmi  <image ID>:# 删除一个或多个image  

## 2.9 容器资源限制参数
-m 1024m --memory-swap=1024m  # 限制内存最大使用（bug：超过后进程被杀死）  
--cpuset-cpus="0,1"           # 限制容器使用CPU  

## 2.10 docker容器随系统自启参数
docker run --restart=always redis  
	no – 默认值，如果容器挂掉不自动重启  
	on-failure – 当容器以非 0 码退出时重启容器  
		同时可接受一个可选的最大重启次数参数 (e.g. on-failure:5).  
	always – 不管退出码是多少都要重启  

## 2.11 查看容器状态信息
docker stats
docker stats --no-stream

# 3 docker实例子
## 3.1 mysql in docker
update gcc:  
wget http://ftpmirror.gnu.org/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2  
tar -xf  gcc-5.2.0.tar.bz2  

./contrib/download_prerequisites  
 Linux没有网络连接（我主机和虚拟机是Host-only，不能联网，所以另外想办法），则用Windows上网下载这几个包

## 3.2 nginx in docker
yum install -y gcc gcc-c++  
./configure --with-http_ssl_module --with-pcre=/root/pcre-8.39 --with-zlib=/root/zlib-1.2.11 --with-openssl=/root/openssl-fips-2.0.14  

## 3.3

# 4 docker私有仓库搭建
## registry环境搭建
默认情况下，会将仓库存放于容器内的/tmp/registry目录下  
sudo docker pull registry  
sudo docker run -d -p 5000:5000 registry  
sudo docker run -d -p 5000:5000 -v /opt/data/registry:/tmp/registry registry  

设置服务器TLS认证:  
```
一般情况下，证书只支持域名访问，要使其支持IP地址访问，需要修改配置文件openssl.cnf。在ubuntu系统下：
sudo vim /etc/ssl/openssl.cnf  在[ v3_ca ]下加入：subjectAltName = IP:10.23.127.59

生成自签名的证书：
mkdir -p /data/docker/tls_certs;cd /data/docker/tls_certs
openssl req -x509 -days 3650 -nodes -newkey rsa:2048 -keyout docker_reg.key -out docker_reg.crt -subj "/C=CN/ST=BJ/L=Beijing/CN=10.23.127.59:5000"

运行docker registry
docker run -d --name docker-registry-no-proxy  --restart=always -u root -p 5000:5000 -v /data/docker/registry/:/var/lib/registry -v /data/docker/tls_certs:/certs -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/docker_reg.crt -e REGISTRY_HTTP_TLS_KEY=/certs/docker_reg.key registry:2

```

设置客户端TLS认证:  
```
1. mkdir -p /etc/docker/certs.d/10.23.127.59:5000/
2. cp docker_reg.crt /etc/docker/certs.d/10.23.127.59:5000/ca.crt
```

使用仓库:  
```
1. 从docker下载一个镜像：
docker pull hello-world
2. 给该镜像打上私有仓库的标签：
docker tag hello-world 10.23.127.59:5000/hello-world
3. 将其推送到私有仓库：
docker push 10.23.127.59:5000/hello-world
4. 从私有仓库下载镜像：
docker pull 10.23.127.59:5000/hello-world
```

## centos 客户端
vim /etc/sysconfig/docker
```  
OPTIONS='--insecure-registry 10.23.127.59:5000'    #CentOS 7系统  
other_args='--insecure-registry 10.23.127.59:5000' #CentOS 6系统  
```


# docker相关错误处理
问题1:docker: relocation error: docker: symbol dm_task_get_info_with_deferred_remove, version Base not defined in file libdevmapper.so.1.02 with link time reference
解决方案:yum upgrade device-mapper-libs
