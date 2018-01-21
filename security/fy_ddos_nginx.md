

#epel install
```
rpm -ivh http://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm
```

#goaccess install
```
yum install glib2 glib2-devel GeoIP-devel  ncurses-devel zlib zlib-devel
cd /home/tools
wget http://tar.goaccess.io/goaccess-1.2.tar.gz
$ tar -xzvf goaccess-1.2.tar.gz
$ cd goaccess-1.2/
$ ./configure --enable-utf8 --enable-geoip=legacy
$ make
# make install
cp /usr/local/etc/goaccess.conf /etc/

#添加时间格式到配置文件，以后启动指定配置文件则不需要再选择
cat >>/etc/goaccess.conf<<EOF
time-format %H:%M:%S
date-format %d/%b/%Y
log-format %h %^[%d:%t %^] "%r" %s %b "%R" "%u"
EOF
###############################

```
## 控制台登录
```
goaccess -a -d -f /var/log/apache2/access.log -p /etc/goaccess.conf
```
## 生成html页面展示
```
goaccess -a -d -f /var/log/apache2/access.log -p /etc/goaccess.conf >/home/app/www.goaccess.com/index.html
```


#参考
https://goaccess.io/download
