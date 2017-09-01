<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Overview](#overview)
- [install](#install)
	- [mariadb](#mariadb)
	- [begen system](#begen-system)

<!-- /TOC -->
# Overview
```
system: centos7 x64
```

# install
```
http://archive.apache.org/dist/apr/apr-util-1.6.0.tar.gz
yum install expat-devel
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make && make install

http://archive.apache.org/dist/apr/apr-1.6.2.tar.gz
tar zxf apr-1.6.2.tar.gz
./configure --prefix=/usr/local/apr
make&&make install
http://www-eu.apache.org/dist//httpd/httpd-2.4.27.tar.gz

http://hk1.php.net/distributions/php-7.1.8.tar.gz
yum install libxml2*
./configure --with-apxs2=/usr/local/apache2/bin/apxs --with-mysql
make && make istall

yum install centos-release-scl
yum install mariadb-server mariadb
```

## mariadb
```
systemctl start mariadb
mysql_secure_installation

mysql -u root -p
CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'THISpasswordSHOULDbeCHANGED';
CREATE DATABASE wikidatabase;
GRANT ALL PRIVILEGES ON wikidatabase.* TO 'wiki'@'localhost';
FLUSH PRIVILEGES;

```
## begen system
```
systemctl enable mariadb
systemctl enable httpd
```
