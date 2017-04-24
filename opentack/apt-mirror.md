#install apt-mirror
apt-get install apt-mirror

#配置文件
vim /etc/apt/mirror.list
deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/mitaka main

#默认下载位置
/var/spool/apt-mirror

#配置nginx目录为

server {
       listen       1888;
       server_name localhost;

       location / {
           root /var/spool/apt-mirror/mirror/ubuntu-cloud.archive.canonical.com/;
           index index.html index.htm;
           autoindex on;
       }
   }

#下载客户端配置
deb [arch=amd64] http://192.168.2.88:1888/ubuntu trusty-updates/mitaka main

#第三方源认证
apt-get install ubuntu-cloud-keyring
apt-get update

#计划任务同步源
0 4 * * * apt-mirror /usr/bin/apt-mirror > /var/spool/apt-mirror/var/cron.log
