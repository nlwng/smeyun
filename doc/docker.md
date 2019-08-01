







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