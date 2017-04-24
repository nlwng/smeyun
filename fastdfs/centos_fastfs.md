FastDFS架构:
FastDFS架构包括 Tracker server和Storage server。
客户端请求Tracker server进行文件上传、下载，通过Tracker server调度最终由Storage server完成文件上传和下载。

Tracker server作用是负载均衡和调度，通过Tracker server在文件上传时可以根据一些策略找到Storage server提供文件上传服务。
可以将tracker称为追踪服务器或调度服务器。

Storage server作用是文件存储，客户端上传的文件最终存储在Storage服务器上，
Storage server没有实现自己的文件系统而是利用操作系统的文件系统来管理文件。可以将storage称为存储服务器。

Tracker集群:
astDFS集群中的Tracker server可以有多台，Tracker server之间是相互平等关系同时提供服务，Tracker server不存在单点故障。
客户端请求Tracker server采用轮询方式，如果请求的tracker无法提供服务则换另一个tracker。

Storage集群:
Storage集群采用了分组存储方式。storage集群由一个或多个组构成，集群存储总容量为集群中所有组的存储容量之和。
一个组由一台或多台存储服务器组成，组内的Storage server之间是平等关系，不同组的Storage server之间不会相互通信，
同组内的Storage server之间会相互连接进行文件同步，从而保证同组内每个storage上的文件完全一致的。一个组的存储容量为该组内存储服务器容量最小的那个，
由此可见组内存储服务器的软硬件配置最好是一致的。采用分组存储方式的好处是灵活、可控性较强。比如上传文件时，可以由客户端直接指定上传到的组也可以由tracker进行调度选择。
一个分组的存储服务器访问压力较大时，可以在该组增加存储服务器来扩充服务能力（纵向扩容）。当系统容量不足时，可以增加组来扩充存储容量（横向扩容）。


3.1 trackerServer
3.2 storageServer
3.3 nginx和fastDFS整合

#------------
#Tracker跟踪器
#------------
#安装依赖
yum install -y gcc perl

#install libfastcommonv1.0.7
git clone https://github.com/happyfish100/libfastcommon.git
cd libfastcommon/
./make.sh
./make.sh install

#only trackerServer storageServer,
cd ~/fdfs/libfastcommon && ./make.sh && ./make.sh install
cd ~/fdfs/fastdfs && ./make.sh && ./make.sh install

ls /usr/bin/fdfs_*
#配置目录
ls /etc/fdfs

#set config
mkdir -p /data/fastdfs
cd /etc/fdfs
cp tracker.conf.sample tracker.conf
cp /root/fastdfs/FastDFS/conf/http.conf .
cp /root/fastdfs/FastDFS/conf/mime.types .
sed -i 's:base_path=.*:base_path=/data/fastdfs:g' tracker.conf
sed -i 's:http.server_port=.*:http.server_port=80:g' tracker.conf

#set start pc
bash -c 'cat > /usr/lib/systemd/system/fdfs_trackerd.service << EOF
[Unit]
Description=fastdfs tracker server
After=network.target

[Service]
Type=forking
PIDFile=/data/fastdfs/data/fdfs_trackerd.pid
ExecStart=/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
ExecReload=/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart
ExecStop=/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf stop

[Install]
WantedBy=multi-user.target
EOF'
systemctl enable fdfs_trackerd.service
systemctl start fdfs_trackerd.service

#check running
cat /data/fastdfs/logs/trackerd.log


#install nginx
yum  -y install openssl openssl-devel pcre-devel
yum install -y epel-release    # 安装 EPEL 软件仓库
yum install -y nginx
systemctl enable nginx
systemctl start nginx

#配置反向代理
打开 /etc/nginx/nginx.conf，在 http {} 中添加：
upstream fdfs {
    server   192.168.71.127:80;
    server   192.168.71.128:80;
}

在 server{} 中添加：
location /M00 {
    proxy_pass http://fdfs;
}

#-------------------------------
#Storage存储节点1
#-------------------------------
#配置文件
mkdir -p /data/fastdfs
cd /etc/fdfs
cp storage.conf.sample storage.conf
cp /root/fastdfs/fastdfs/conf/http.conf .
cp /root/fastdfs/fastdfs/conf/mime.types .
sed -i 's:base_path=.*:base_path=/data/fastdfs:g' storage.conf
sed -i 's:store_path0=.*:store_path0=/data/fastdfs:g' storage.conf
sed -i 's/tracker_server=.*/tracker_server=192.168.71.126:22122/g' storage.conf
sed -i 's:http.server_port=.*:http.server_port=80:g' storage.conf

#开机自启动
bash -c 'cat > /usr/lib/systemd/system/fdfs_storaged.service << EOF
[Unit]
Description=fastdfs storage server
After=network.target

[Service]
Type=forking
PIDFile=/data/fastdfs/data/fdfs_storaged.pid
ExecStart=/usr/bin/fdfs_storaged /etc/fdfs/storage.conf
ExecReload=/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart
ExecStop=/usr/bin/fdfs_storaged /etc/fdfs/storage.conf stop

[Install]
WantedBy=multi-user.target
EOF'
systemctl enable fdfs_storaged.service
systemctl start fdfs_storaged.service

#check
cat /data/fastdfs/logs/storaged.log

-------------------------------
#Storage存储节点2
-------------------------------
#client客户端配置
#在tracker, storage之外的一台主机上安装FastDFS，然后执行：
mkdir -p /data/fastdfs
cd /etc/fdfs
cp client.conf.sample client.conf
sed -i 's:base_path=.*:base_path=/data/fastdfs:g' client.conf
sed -i 's/tracker_server=.*/tracker_server=192.168.71.126:22122/g' client.conf


#------------------------
测试
#------------------------

上传测试:
joelhy@arminix: ~ $ fdfs_upload_file /etc/fdfs/client.conf pom.xml
group1/M00/00/00/wKhHf1S-oryAZCpgAAAE2uRlJkA126.xml
查看文件信息:

joelhy@arminix: ~ $ fdfs_file_info /etc/fdfs/client.conf
group1/M00/00/00/wKhHf1S-oryAZCpgAAAE2uRlJkA126.xml
source storage id: 0
source ip address: 192.168.71.127
file create timestamp: 2015-01-26 02:47:24
file size: 1242
file crc32: 3831834176 (0xE4652640)

下载测试:
joelhy@arminix: ~ $ fdfs_download_file /etc/fdfs/client.conf \
    group1/M00/00/00/wKhHf1S-oryAZCpgAAAE2uRlJkA126.xml downtest.xml
joelhy@arminix: ~ $ ls
downtest.xml
