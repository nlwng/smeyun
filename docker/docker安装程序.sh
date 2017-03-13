#首先进入Container
#安装ssh
yum install openssh-server sudo #安装ssh服务器  
service sshd status # 查看ssh服务启动情况  
service sshd start # 启动ssh服务  

#配置ssh，允许root登陆
vi /etc/ssh/sshd_config  
将PermitRootLogin的值从withoutPassword改为yes 

# 重启ssh服务
service sshd restart # 重启动ssh服务  

#保存Container镜像
#另外开启Docker Quickstart Terminal，保存镜像
docker ps #查看正在运行的container  
#**找到所要保存的container的container id，假设为xxxxxx**  
docker commit xxxxxxxx tomjerry/foobar  
#（注：tomjerry/foobar为要保存的新镜像的名字，可任意写）  

#重新运行Container：注意-p 50001:22这句，意思是将docker的50001端口和container的22端口绑定，
#这样访问docker的50001等价于访问container的22端口
docker run -it -p 50005:22 tomjerry/foobar /bin/bash  
service ssh start 

#ssh连接container
#首先假设各方的ip如下
本地windows ip： 192.168.99.1  
docker ip：192.168.99.100  
container ip：172.17.0.3

#那么，你要远程container，则要访问以下地址
#这样通过访问docker的50001端口，就神奇的间接连通到container的22端口了，从而达到ssh连接container的目的，至此。
ssh 192.168.99.100:50001  

#Failed to get D-Bus connection: Operation not permitted
yum -y install openssh-clients rsync

#Dockerfile自启动ssh
---------------------------------------------------------------------------
# 选择一个已有的docker os镜像作为基础:创建一个名字为centos7.1-ssh的image 
FROM centos7.1-base    
     
# 镜像的作者    
MAINTAINER guanyy "gyy823@126.com"    
     
# 安装openssh-server和sudo软件包，并且将sshd的UsePAM参数设置成no    
RUN yum install -y openssh-server sudo    
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config    
     
# 添加测试用户admin，密码admin，并且将此用户添加到sudoers里    
RUN useradd admin    
RUN echo "admin:admin" | chpasswd    
RUN echo "admin   ALL=(ALL)       ALL" >> /etc/sudoers    
     
# 下面这两句比较特殊，在centos6上必须要有，否则创建出来的容器sshd不能登录    
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key    
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key    
     
# 启动sshd服务并且暴露22端口    
RUN mkdir /var/run/sshd    
EXPOSE 22    
CMD ["/usr/sbin/sshd", "-D"]
---------------------------------------------------------------------------

#根据Dockerfile来创建image文件
docker build -t centos7.1-ssh /root/

#启动容器
docker run -d -P --name=mytest2 8315978ceaaa






