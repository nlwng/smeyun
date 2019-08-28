







# 安装docker

移除docker

```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
```

安装必要工具

```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

添加软件源信息：

```
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

更新 yum 缓存：

```
sudo yum makecache fast
```

安装 Docker-ce：

```
sudo yum -y install docker-ce
```



脚本安装docker：

```
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```



centos6.5 安装docker1.7

https://github.com/dong-shuai/Install-Docker1.7.1-On-RHEL6.5





# 优化docker

镜像加速：

鉴于国内网络问题，后续拉取 Docker 镜像十分缓慢，我们可以需要配置加速器来解决，我使用的是网易的镜像地址：**http://hub-mirror.c.163.com**。

新版的 Docker 使用 /etc/docker/daemon.json（Linux） 或者 %programdata%\docker\config\daemon.json（Windows） 来配置 Daemon。

请在该配置文件中加入（没有该文件的话，请先建一个）：

```
{
  "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
```

删除docker ce

```
$ sudo yum remove docker-ce
$ sudo rm -rf /var/lib/docker
```

修改doker容器挂载路径：

https://www.cnblogs.com/kaishirenshi/p/10396446.html

# docker常用命令

docker commit 提交个性版本：

```
根据这个myubuntu容器提交镜像
[root@docker-test1 ~]# docker commit -a "wangshibo" -m "this is test" 651a8541a47d myubuntu:v1

再次查看镜像,发现镜像myubuntu:v1已经提交到本地了
[root@docker-test1 ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
myubuntu            v1                  6ce4aedd12cd        59 seconds ago      84.1 MB
docker.io/ubuntu    16.04               7aa3602ab41e        5 weeks ago         115 MB

这里需要将ubuntu:v1镜像改名，在名称前加上自己的docker hub的Docker ID，即wangshibo 
[root@docker-test1 ~]# docker tag 6ce4aedd12cd wangshibo/myubuntu:v1

[root@docker-test1 ~]# docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
myubuntu             v1                  6ce4aedd12cd        6 minutes ago       84.1 MB
wangshibo/myubuntu   v1                  6ce4aedd12cd        6 minutes ago       84.1 MB
docker.io/ubuntu     16.04               7aa3602ab41e        5 weeks ago         115 MB
```

进入docker

```
docker exec -it ubuntu bash
```

进入docker执行命令：

```
docker exec -it ubuntu bash -c su -
```

docker拷贝文件

```
docker cp ubuntu:/root/to.txt /root/
docker cp /root/to.txt ubuntu:/root/
```

查看镜像volume：

```
docker inspect ubuntu|grep MergedDir
docker inspect ubuntu|grep Id
```

docker-compose编译

```
docker-compose up -d
```





# docker使用

dockerfile编写：

```yaml
FROM centos:7

# Timezone, Asia/Shanghai by default
ENV Timezone=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$Timezone /etc/localtime && echo '$Timezone' > /etc/timezone

RUN yum install -y wget && \
    yum install -y java-1.8.0-openjdk

WORKDIR /app

ADD http://mirror.bit.edu.cn/apache/incubator/skywalking/6.0.0-GA/apache-skywalking-apm-incubating-6.0.0-GA.tar.gz .

RUN tar -xf apache-skywalking-apm-incubating-6.0.0-GA.tar.gz && \ 
    mv apache-skywalking-apm-incubating skywalking && \ 
    echo "tail -f /dev/null" >> /app/skywalking/bin/startup.sh

CMD ["/bin/sh","-c","/app/skywalking/bin/startup.sh" ]
```

bulid

docker build -t skywalking -f Dockerfile .





docke-compse编写：

```yaml
version: '2'
services:
  elasticsearch:
    image: elasticsearch:5.6
    container_name: elasticsearch
    ports:
      - 9200:9200
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
    restart: always
    environment:
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m" #specific es java memory
    volumes:
      - ./es/data:/usr/share/elasticsearch/data
      - ./es/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
    mem_limit: 1g # memory limit

  kibana:
    image: kibana:5.6
    container_name: kibana
    ports:
      - 5601:5601
    links:
      - elasticsearch:elasticsearch
    depends_on:
      - elasticsearch
    environment:
      ELASTICSEARCH_URL: http://elasticsearch:9200

  skywalking:
      image: weihanli/skywalking:5.0.0-GA
      container_name: skywalking
      ports:
        - 10800:10800
        - 11800:11800
        - 12800:12800
        - 8090:8080
      volumes:
        - ./skywalking/application.yml:/app/skywalking/config/application.yml
      links:
        - elasticsearch:elasticsearch
      depends_on:
        - elasticsearch
```

编译：

docker-compse up -d



# 常用镜像

## 启动msyql

```shell
docker run -p 3306:3306 --name mymysql -v $PWD/conf:/etc/mysql/conf.d -v $PWD/logs:/logs -v $PWD/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d docker.io/mysql:5.6
```



## 启动nginx

```
docker run -d -p 8082:80 --name runoob-nginx-test-web -v ~/nginx/www:/usr/share/nginx/html -v ~/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v ~/nginx/logs:/var/log/nginx nginx
```

命令说明：

- **-p 8082:80：** 将容器的 80 端口映射到主机的 8082 端口。
- **--name runoob-nginx-test-web：**将容器命名为 runoob-nginx-test-web。
- **-v ~/nginx/www:/usr/share/nginx/html：**将我们自己创建的 www 目录挂载到容器的 /usr/share/nginx/html。
- **-v ~/nginx/conf/nginx.conf:/etc/nginx/nginx.conf：**将我们自己创建的 nginx.conf 挂载到容器的 /etc/nginx/nginx.conf。
- **-v ~/nginx/logs:/var/log/nginx：**将我们自己创建的 logs 挂载到容器的 /var/log/nginx。



## 启动nginx+php

https://www.runoob.com/docker/docker-install-php.html

```shell
docker run --name runoob-php-nginx -p 8083:80 -d \
    -v ~/nginx/www:/usr/share/nginx/html:ro \
    -v ~/nginx/conf/conf.d:/etc/nginx/conf.d:ro \
    --link myphp-fpm:php \
    nginx
```

- **-p 8083:80**: 端口映射，把 **nginx** 中的 80 映射到本地的 8083 端口。
- **~/nginx/www**: 是本地 html 文件的存储目录，/usr/share/nginx/html 是容器内 html 文件的存储目录。
- **~/nginx/conf/conf.d**: 是本地 nginx 配置文件的存储目录，/etc/nginx/conf.d 是容器内 nginx 配置文件的存储目录。
- **--link myphp-fpm:php**: 把 **myphp-fpm** 的网络并入 **nginx**，并通过修改 **nginx** 的 /etc/hosts，把域名 **php** 映射成 127.0.0.1，让 nginx 通过 php:9000 访问 php-fpm。



## 启动tomcat

```
runoob@runoob:~/tomcat$ docker run --name tomcat -p 8080:8080 -v $PWD/test:/usr/local/tomcat/webapps/test -d tomcat 
```

命令说明：

**-p 8080:8080：**将容器的8080端口映射到主机的8080端口

**-v $PWD/test:/usr/local/tomcat/webapps/test：**将主机中当前目录下的test挂载到容器的/test



## 启动python

```
runoob@runoob:~/python$ docker run  -v $PWD/myapp:/usr/src/myapp  -w /usr/src/myapp python:3.5 python helloworld.py
```

命令说明：

**-v $PWD/myapp:/usr/src/myapp :**将主机中当前目录下的myapp挂载到容器的/usr/src/myapp

**-w /usr/src/myapp :**指定容器的/usr/src/myapp目录为工作目录

**python helloworld.py :**使用容器的python命令来执行工作目录中的helloworld.py文件



## 安装redis

```
runoob@runoob:~/redis$ docker run -p 6379:6379 -v $PWD/data:/data  -d redis:3.2 redis-server --appendonly yes
```

命令说明：

**-p 6379:6379 :** 将容器的6379端口映射到主机的6379端口

**-v $PWD/data:/data :** 将主机中当前目录下的data挂载到容器的/data

**redis-server --appendonly yes :** 在容器执行redis-server启动命令，并打开redis持久化配置



## 安装mongodb

```
runoob@runoob:~/mongo$ docker run -p 27017:27017 -v $PWD/db:/data/db -d mongo:3.2
```

命令说明：

**-p 27017:27017 :**将容器的27017 端口映射到主机的27017 端口

**-v $PWD/db:/data/db :**将主机中当前目录下的db挂载到容器的/data/db，作为mongo数据存储目录



## 安装apache

```
docker run -p 80:80 -v $PWD/www/:/usr/local/apache2/htdocs/ -v $PWD/conf/httpd.conf:/usr/local/apache2/conf/httpd.conf -v $PWD/logs/:/usr/local/apache2/logs/ -d httpd
```

命令说明：

**-p 80:80 :**将容器的80端口映射到主机的80端口

**-v $PWD/www/:/usr/local/apache2/htdocs/ :**将主机中当前目录下的www目录挂载到容器的/usr/local/apache2/htdocs/

**-v $PWD/conf/httpd.conf:/usr/local/apache2/conf/httpd.conf :**将主机中当前目录下的conf/httpd.conf文件挂载到容器的/usr/local/apache2/conf/httpd.conf

**-v $PWD/logs/:/usr/local/apache2/logs/ :**将主机中当前目录下的logs目录挂载到容器的/usr/local/apache2/logs/



## 启动haproxy

```cfg
#----------------
# Global settings
#----------------
global
    log         127.0.0.1 local2
    maxconn     4000
    daemon
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 500
#-------------
#Stats monitor
#-------------
frontend stats_monitor
        bind    *:30001
        stats   enable
        stats   uri     /stats
        stats   auth    admin:admin
        stats   admin   if      TRUE
        stats   refresh 5s
        stats   realm   baison-test-Haproxy
#       stats   hide-version
#--------------------
#Application frontend
#--------------------
frontend        GEOGLOBE
bind    *:8080
#ACL#
acl map_acl path_reg -i /map/
#USE_BACKEND#
use_backend map_backend if map_acl
#map_begin#    
backend map_backend
balance roundrobin
mode http
server map_101 172.15.103.195:20001 check weight 1
#map_end#
```

启动：

docker run -d -p 8080 -p 30001 --name haproxy -v /root/haproxy:/usr/local/etc/haproxy:ro haproxy:1.9.7



# 相关解决记录

## 查看日志

```
docker logs pinpoint-web

#实现tail -f
docker logs -f  pinpoint-web

#高级
docker logs -f -t --since="2017-05-31" --tail=10 pinpoint-web

--since 指定输出日志开始日期，只输出指定日期之后的日志
-f 查看实时日志
-t 查看日志产生的日期
-tail=10 查看最后10条
```



## 镜像编译打包

将目录下的文件打成一个war包

```
cd ROOT;zip -r -q -o ROOT.war .;mv ROOT.war ../;cd ../

删除老镜像：
docker rmi pinpoint-web -f;docker rmi docker.io/pinpointdocker/pinpoint-web:1.8.4.1 -f

#dockerfile build
docker build -t docker.io/pinpointdocker/pinpoint-web:1.8.4.1 .
```



## Percona Dockerfile

https://hub.docker.com/_/percona

```yaml
FROM centos:7
MAINTAINER Percona Development <info@percona.com>

RUN groupdel input && groupadd -g 999 mysql
RUN useradd -u 999 -r -g 999 -s /sbin/nologin \
		-c "Default Application User" mysql

# check repository package signature in secure way
RUN export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A \
	&& gpg --export --armor 430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A > ${GNUPGHOME}/RPM-GPG-KEY-Percona \
	&& rpmkeys --import ${GNUPGHOME}/RPM-GPG-KEY-Percona /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
        && curl -L -o /tmp/percona-release.rpm https://repo.percona.com/percona/yum/percona-release-0.1-10.noarch.rpm \
	&& rpmkeys --checksig /tmp/percona-release.rpm \
	&& yum install -y /tmp/percona-release.rpm \
	&& rm -rf "$GNUPGHOME" /tmp/percona-release.rpm \
        && percona-release enable original release

# install exact version of PS for repeatability
ENV PERCONA_VERSION 5.7.26-29.1.el7

RUN yum install -y \
		Percona-Server-server-57-${PERCONA_VERSION} \
		Percona-Server-tokudb-57-${PERCONA_VERSION} \
		Percona-Server-rocksdb-57-${PERCONA_VERSION} \
		jemalloc \
		which \
		policycoreutils \
	&& yum clean all \
	&& rm -rf /var/cache/yum /var/lib/mysql

# purge and re-create /var/lib/mysql with appropriate ownership
RUN /usr/bin/install -m 0775 -o mysql -g root -d /var/lib/mysql /var/run/mysqld /docker-entrypoint-initdb.d \
# comment out a few problematic configuration values
	&& find /etc/percona-server.cnf /etc/percona-server.conf.d /etc/my.cnf.d -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log|user)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log|user)/#&/' \
# don't reverse lookup hostnames, they are usually another container
	&& printf '[mysqld]\nskip-host-cache\nskip-name-resolve\n' > /etc/my.cnf.d/docker.cnf \
# TokuDB modifications
	&& /usr/bin/install -m 0664 -o mysql -g root /dev/null /etc/sysconfig/mysql \
	&& echo "LD_PRELOAD=/usr/lib64/libjemalloc.so.1" >> /etc/sysconfig/mysql \
	&& echo "THP_SETTING=never" >> /etc/sysconfig/mysql \
# keep backward compatibility with debian images
	&& ln -s /etc/my.cnf.d /etc/mysql \
# allow to change config files
	&& chown -R mysql:root /etc/percona-server.cnf /etc/percona-server.conf.d /etc/my.cnf.d \
	&& chmod -R ug+rwX /etc/percona-server.cnf /etc/percona-server.conf.d /etc/my.cnf.d

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

COPY ps-entry.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER mysql
EXPOSE 3306
CMD ["mysqld"]
```

## mariadb Dockerfile

https://hub.docker.com/_/mariadb?tab=description&page=8

```yaml
# vim:set ft=dockerfile:
FROM ubuntu:bionic

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# https://bugs.debian.org/830696 (apt uses gpgv by default in newer releases, rather than gpg)
RUN set -ex; \
	apt-get update; \
	if ! which gpg; then \
		apt-get install -y --no-install-recommends gnupg; \
	fi; \
	if ! gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
# Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
# so, if we're not running gnupg 1.x, explicitly install dirmngr too
		apt-get install -y --no-install-recommends dirmngr; \
	fi; \
	rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps

RUN mkdir /docker-entrypoint-initdb.d

# install "pwgen" for randomizing passwords
# install "tzdata" for /usr/share/zoneinfo/
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		pwgen \
		tzdata \
	; \
	rm -rf /var/lib/apt/lists/*

ENV GPG_KEYS \
# pub   rsa4096 2016-03-30 [SC]
#         177F 4010 FE56 CA33 3630  0305 F165 6F24 C74C D1D8
# uid           [ unknown] MariaDB Signing Key <signing-key@mariadb.org>
# sub   rsa4096 2016-03-30 [E]
	177F4010FE56CA3336300305F1656F24C74CD1D8
RUN set -ex; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done; \
	gpg --batch --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mariadb.gpg; \
	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	rm -r "$GNUPGHOME"; \
	apt-key list

# bashbrew-architectures: amd64 arm64v8 ppc64le
ENV MARIADB_MAJOR 10.3
ENV MARIADB_VERSION 1:10.3.17+maria~bionic
# release-status:Stable
# (https://downloads.mariadb.org/mariadb/+releases/)

RUN set -e;\
	echo "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_MAJOR/ubuntu bionic main" > /etc/apt/sources.list.d/mariadb.list; \
	{ \
		echo 'Package: *'; \
		echo 'Pin: release o=MariaDB'; \
		echo 'Pin-Priority: 999'; \
	} > /etc/apt/preferences.d/mariadb
# add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencies
#  libmariadbclient18 : Depends: libmysqlclient18 (= 5.5.42+maria-1~wheezy) but 5.5.43-0+deb7u1 is to be installed

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN set -ex; \
	{ \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password password 'unused'; \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password_again password 'unused'; \
	} | debconf-set-selections; \
	apt-get update; \
	apt-get install -y \
		"mariadb-server=$MARIADB_VERSION" \
# mariadb-backup is installed at the same time so that `mysql-common` is only installed once from just mariadb repos
		mariadb-backup \
		socat \
	; \
	rm -rf /var/lib/apt/lists/*; \
# comment out any "user" entires in the MySQL config ("docker-entrypoint.sh" or "--user" will handle user switching)
	sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/*; \
# purge and re-create /var/lib/mysql with appropriate ownership
	rm -rf /var/lib/mysql; \
	mkdir -p /var/lib/mysql /var/run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	chmod 777 /var/run/mysqld; \
# comment out a few problematic configuration values
	find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'; \
# don't reverse lookup hostnames, they are usually another container
	echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
```

## mysql Dockerfile

https://hub.docker.com/_/mysql?tab=description&page=4

```yaml
FROM debian:stretch-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update && apt-get install -y --no-install-recommends gnupg dirmngr && rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& gpgconf --kill all \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates wget

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-get update && apt-get install -y --no-install-recommends \
# for MYSQL_RANDOM_ROOT_PASSWORD
		pwgen \
# for mysql_ssl_rsa_setup
		openssl \
# FATAL ERROR: please install the following Perl modules before executing /usr/local/mysql/scripts/mysql_install_db:
# File::Basename
# File::Copy
# Sys::Hostname
# Data::Dumper
		perl \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex; \
# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	apt-key list > /dev/null

ENV MYSQL_MAJOR 5.7
ENV MYSQL_VERSION 5.7.27-1debian9

RUN echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN { \
		echo mysql-community-server mysql-community-server/data-dir select ''; \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		echo mysql-community-server mysql-community-server/remove-test-db select false; \
	} | debconf-set-selections \
	&& apt-get update && apt-get install -y mysql-server="${MYSQL_VERSION}" && rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	&& chmod 777 /var/run/mysqld \
# comment out a few problematic configuration values
	&& find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/' \
# don't reverse lookup hostnames, they are usually another container
	&& echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306 33060
CMD ["mysqld"]
```



## 基础镜像修改时区

Ubuntu16.04基础镜像： 

```yaml
FROM ubuntu:16.04
MAINTAINER xx@example
RUN ln -sf /usr/share/zoneinfo/Asia/ShangHai /etc/localtime
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
```

 Alpine3.6基础镜像：

```yaml
FROM alpine3.6
MAINTAINER xx@example.cn
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    &&rm -rf /var/cache/apk/* /tmp/* /var/tmp/* $HOME/.cache
```

## keepalived

https://github.com/osixia/docker-keepalived



**keepalived原理**：

VRRP(Virtual Router Redundancy Protocol)协议是用于实现路由器冗余的协议，最新协议在RFC3768中定义，原来的定义RFC2338被废除，新协议相对还简化了一些功能。



**协议：**

  VRRP协议是为消除在静态缺省路由环境下的缺省路由器单点故障引起的网络失效而设计的主备模式的协议，使得在发生故障而进行设备功能切换时可以不影响内外数据通信，不需要再修改内部网络的网络参数。VRRP协议需要具有IP地址备份，优先路由选择，减少不必要的路由器间通信等功能。

VRRP协议将两台或多台路由器设备虚拟成一个设备，对外提供虚拟路由器IP(一个或多个)，而在路由器组内部，如果实际拥有这个对外IP的路由器如果工作正常的话就是MASTER，或者是通过算法选举产生，MASTER实现针对虚拟路由器IP的各种网络功能，如ARP请求，ICMP，以及数据的转发等；其他设备不拥有该IP，状态是BACKUP，除了接收MASTER的VRRP状态通告信息外，不执行对外的网络功能。当主机失效时，BACKUP将接管原先MASTER的网络功能。

配置VRRP协议时需要配置每个路由器的虚拟路由器ID(VRID)和优先权值，使用VRID将路由器进行分组，具有相同VRID值的路由器为同一个组，VRID是一个0～255的正整数；同一组中的路由器通过使用优先权值来选举MASTER，优先权大者为MASTER，优先权也是一个0～255的正整数。

VRRP协议使用多播数据来传输VRRP数据，VRRP数据使用特殊的虚拟源MAC地址发送数据而不是自身网卡的MAC地址，VRRP运行时只有MASTER路由器定时发送VRRP通告信息，表示MASTER工作正常以及虚拟路由器IP(组)，BACKUP只接收VRRP数据，不发送数据，如果一定时间内没有接收到MASTER的通告信息，各BACKUP将宣告自己成为MASTER，发送通告信息，重新进行MASTER选举状态。  



**MASTER选举**
如果对外的虚拟路由器IP就是路由器本身配置的IP地址的话，该路由器始终都是MASTER；
否则如果不具备虚拟IP的话，将进行MASTER选举，各路由器都宣告自己是MASTER，发送VRRP通告信息；
如果收到其他机器的发来的通告信息的优先级比自己高，将转回BACKUP状态；
如果优先级相等的话，将比较路由器的实际IP，IP值较大的优先权高；
不过如果对外的虚拟路由器IP就是路由器本身的IP的话，该路由器始终将是MASTER，这时的优先级值为255。



VRRP协议状态比较简单，就三种状态，初始化，主机，备份机。

```
                      +---------------+
           +--------->|               |<-------------+
           |          |  Initialize   |              |
           |   +------|               |----------+   |
           |   |      +---------------+          |   |
           |   |                                 |   |
           |   V                                 V   |
   +---------------+                       +---------------+
   |               |---------------------->|               |
   |    Master     |                       |    Backup     |
   |               |<----------------------|               |
   +---------------+                       +---------------+
```

**初始化：**
路由器启动时，如果路由器的优先级是255(最高优先级，路由器拥有路由器地址)，要发送VRRP通告信息，并发送广播ARP信息通告路由器IP地址对应的MAC地址为路由虚拟MAC，设置通告信息定时器准备定时发送VRRP通告信息，转为MASTER状态；
否则进入BACKUP状态，设置定时器检查定时检查是否收到MASTER的通告信息。

**主机：**
主机状态下的路由器要完成如下功能：
设置定时通告定时器；
用VRRP虚拟MAC地址响应路由器IP地址的ARP请求；
转发目的MAC是VRRP虚拟MAC的数据包；
如果是虚拟路由器IP的拥有者，将接受目的地址是虚拟路由器IP的数据包，否则丢弃；
当收到shutdown的事件时删除定时通告定时器，发送优先权级为0的通告包，转初始化状态；
如果定时通告定时器超时时，发送VRRP通告信息；
收到VRRP通告信息时，如果优先权为0，发送VRRP通告信息；否则判断数据的优先级是否高于本机，或相等而且实际IP地址大于本地实际IP，设置定时通告定时器，复位主机超时定时器，转BACKUP状态；否则的话，丢弃该通告包；

**备机：**
备机状态下的路由器要实现以下功能：
设置主机超时定时器；
不能响应针对虚拟路由器IP的ARP请求信息；
丢弃所有目的MAC地址是虚拟路由器MAC地址的数据包；
不接受目的是虚拟路由器IP的所有数据包；
当收到shutdown的事件时删除主机超时定时器，转初始化状态；
主机超时定时器超时的时候，发送VRRP通告信息，广播ARP地址信息，转MASTER状态；
收到VRRP通告信息时，如果优先权为0，表示进入MASTER选举；否则判断数据的优先级是否高于本机，如果高的话承认MASTER有效，复位主机超时定时器；否则的话，丢弃该通告包；

  **2.4 ARP查询处理**

当内部主机通过ARP查询虚拟路由器IP地址对应的MAC地址时，MASTER路由器回复的MAC地址为虚拟的VRRP的MAC地址，而不是实际网卡的MAC地址，这样在路由器切换时让内网机器觉察不到；而在路由器重新启动时，不能主动发送本机网卡的实际MAC地址。如果虚拟路由器开启的ARP代理(proxy_arp)功能，代理的ARP回应也回应VRRP虚拟MAC地址；  



**VRRP应用举例**

```
           +-----------+      +-----------+
            |   Rtr1    |      |   Rtr2    |
            |(MR VRID=1)|      |(BR VRID=1)|
            |(BR VRID=2)|      |(MR VRID=2)|
    VRID=1  +-----------+      +-----------+  VRID=2
    IP A ---------->*            *<---------- IP B
                    |            |
                    |            |
  ------------------+------------+-----+--------+--------+--------+--
                                       ^        ^        ^        ^
                                       |        |        |        |
                                     (IP A)   (IP A)   (IP B)   (IP B)
                                       |        |        |        |
                                    +--+--+  +--+--+  +--+--+  +--+--+
                                    |  H1 |  |  H2 |  |  H3 |  |  H4 |
                                    +-----+  +-----+  +--+--+  +--+--+
     Legend:
              ---+---+---+--  =  Ethernet, Token Ring, or FDDI
                           H  =  Host computer
                          MR  =  Master Router
                          BR  =  Backup Router
                           *  =  IP Address
                        (IP)  =  default router for hosts
```



这是通常VRRP使用拓扑，两台路由器运行VRRP互为备份，路由器1作为VRID组1的MASTER，IP地址A，VRID组2的BACKUP，路由器2作为VRID组2的MASTER，IP地址B，VRID组1的BACKUP，内部网络中一部分机器的缺省网关地址是IP地址A，一部分是IP地址B，正常情况下以A为网关的数据将走路由器1，以B为网关的数据将走路由器2，如果一台路由器发生故障，所有数据将走另一台路由器。

**协议定义：**

**以太头：**

  源MAC地址必须为虚拟MAC地址：00-00-5E-00-01-{**VRID**}，VRID为虚拟路由器ID值，16进制格式，所以同一网段中最多有255个VRRP路由器；目的MAC为多播类型的MAC。

这里可以看出VRID非常重要  



**IP头参数**

VRRP包的源地址是本机地址，目的地址必须为224.0.0.18，为一多播地址；IP协议号为112；IP包的TTL值必须为255。



 **VRRP协议数据格式**

```
   0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |Version| Type  | Virtual Rtr ID|   Priority    | Count IP Addrs|
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |   Auth Type   |   Adver Int   |          Checksum             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                         IP Address (1)                        |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                            .                                  |
   |                            .                                  |
   |                            .                                  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                         IP Address (n)                        |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                     Authentication Data (1)                   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                     Authentication Data (2)                   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

其中：
version：版本，4位，在RFC3768中定义为2；
Type：类型，4位，目前只定义一种类类型：通告数据，取值为1；
Virtual Rtr ID：虚拟路由器ID，8位
Priority：优先级，8位，具备冗余IP地址的设备的优先级为255；
Count IP Addrs：VRRP包中的IP地址数量，8位；
Auth Type：认证类型，8位，RFC3768中认证功能已经取消，此字段值定义0(不认证)，为1，2只作为对老版本的兼容；
Adver Int：通告包的发送间隔时间，8位，单位是秒，缺省是1秒；
Checksum：校验和，16位，校验数据范围只是VRRP数据，即从VRRP的版本字段开始的数据，不包括IP头；
IP Address(es)：和虚拟路由器相关的IP地址，数量由Count IP Addrs决定
Authentication Data：RFC3768中定义该字段只是为了和老版本兼容，必须置0。



**接收数据时的必须检查**

收到VRRP数据包时要进行以下验证，不满足的数据包将被丢弃：
   -  TTL必须为255；
   -  VRRP版本号必须为2；
   -  一个包中数据字段必须完整；
   -  校验和必须正确；
   -  必须验证在接收的网卡上配置了VRID值，而且本地路由器不是路由IP地址的拥有者
   -  必须验证VVRP认证类型和配置的一致；

**结论**

VRRP实现了对路由器IP地址的冗余功能，防止了单点故障造成的网络失效，VRRP本身是热备形式的，但可以通过互相热备实现路由器的均衡处理，新版的VRRP较老版简化了认证处理，实际不再进行数据的认证，这是因为在实际应用中经常出现认证成为造成多个MASTER同时使用的异常情况。



**Keepalived原理与实战精讲**

https://blog.csdn.net/u010391029/article/details/48311699