<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1 环境部署](#1-环境部署)
	- [1.1 安装模块](#11-安装模块)
	- [1.2 设置config](#12-设置config)
	- [1.3 测试联通](#13-测试联通)
	- [1.4 安装软件](#14-安装软件)
		- [1.4.1 基于Salt管理iptables防火墙规则](#141-基于salt管理iptables防火墙规则)
- [2 Salt-api 搭建](#2-salt-api-搭建)
	- [2.1 安装](#21-安装)
	- [2.2 配置api:](#22-配置api)
	- [2.3 生成自签名证书](#23-生成自签名证书)
	- [2.4 获取token](#24-获取token)
- [3 sls编写](#3-sls编写)
	- [3.1 调用多状态](#31-调用多状态)
	- [3.2 模板SLS的模块](#32-模板sls的模块)
	- [3.3 使用GRAINS模板](#33-使用grains模板)
		- [3.3.1 在SLS模块中使用环境变量](#331-在sls模块中使用环境变量)
		- [3.3.2 在模板中调用模块](#332-在模板中调用模块)
		- [3.3.3 更高级的SLS模块语法](#333-更高级的sls模块语法)
- [参考资料](#参考资料)

<!-- /TOC -->


# 1 环境部署
```
yum -y install https://repo.saltstack.com/yum/redhat/salt-repo-2016.11-1.el6.noarch.rpm
yum -y install https://repo.saltstack.com/yum/redhat/salt-repo-2016.11-1.el7.noarch.rpm
yum clean expire-cache
```

## 1.1 安装模块
```
master安装salt
yum -y install salt-master

client安装
yum -y install salt-minion
```
## 1.2 设置config

```
修改client配置文件 （这里保持默认配置）
[root@salt-client-01 /]# vim /etc/salt/minion
16 #master: salt            #默认为salt 可改为master的IP
78 #id:    #默认为主机名 可根据自身环境修改  唯一的不能冲出

修改/etc/hosts
[root@salt-client-01 /]# echo "192.168.119.132   salt" >> /etc/hosts
[root@salt-client-02 /]# echo "192.168.119.132   salt" >> /etc/hosts
```

## 1.3 测试联通
```
salt-key -L
salt '*' state.highstate -t 60
salt-minion -l debug &  
hostname > /etc/salt/minion_id
sed -i 's/#master: salt/master: smesalt/g' /etc/salt/minion;echo "10.30.1.184 smesalt" >> /etc/hosts
```


## 1.4 安装软件
salt '*' pkg.install lrzsz

### 1.4.1 基于Salt管理iptables防火墙规则
```
上述配置文件定义了两个根目录的路径。如有需要也可以修改定义。在/srv/salt目录下除了必备的top.sls。设置如下几个目录：

ls /srv/salt/
base  conf  other  package  resource  service  top.sls
以上各个目录的含义为：

Base目录， Linux系统的基础性配置，例如设置CentOS软件仓库。
Conf目录，通用服务状态描述文件中涉及到的特定服务的配置文件。
Other目录，一些复杂不具有通用性的特殊系统。
Package目录，一些基础软件安装，例如CentOS的development tools软件组。
Service目录，通用服务的状态描述文件。

更新所有的minion的状态
salt 'sme-y-001-s-02.novalocal' state.highstate
salt 'sme-y-001-s-02.novalocal' state.sls base.iptables test=True
```

# 2 Salt-api 搭建
## 2.1 安装
```
yum -y install salt-api pyOpenSSL
useradd -M -s /sbin/nologin neildev    
echo 'neil1983' | passwd neildev --stdin   
```

## 2.2 配置api:
```
cat /etc/salt/master.d/api.conf   
rest_cherrypy:    
  port: 8000    
  ssl_crt: /etc/pki/tls/certs/localhost.crt    
  ssl_key: /etc/pki/tls/certs/localhost.key  
external_auth:    
  pam:    
    neildev:              
      - .*  
      - '@wheel'  
      - '@runner'
```
## 2.3 生成自签名证书
```
salt-call tls.create_self_signed_cert
生成私有key
make testcert
openssl rsa -in localhost.key -out localhost_nopass.key

配置修改
ssl_crt: /etc/pki/tls/certs/localhost.crt
ssl_key: /etc/pki/tls/private/localhost_nopass.key
```
## 2.4 获取token
```
curl -k https://10.10.0.52:8000/login -H "Accept: application/x-yaml" -d username='*' -d password='*' -d eauth='pam'
curl -k https://10.10.0.52:8000 -H "Accept: application/x-yaml" -H "X-Auth-Token: 3***" -d client='local' -d tgt='*' -d fun='test.ping'
```

#3 sls编写
##3.1 调用多状态
```yaml
apache:
  pkg.installed: []
  service.running:
    - require:
      - pkg: apache

/var/www/index.html:                        # ID declaration
  file:                                     # state declaration
    - managed                               # function
    - source: salt://webserver/index.html   # function arg
    - require:                              # requisite declaration
      - pkg: apache                         # requisite reference
```

如果你想使用**Salt**创建一个虚拟主机配置文件并希望当文件发生改变时重启apache web服务 ，你可以我们之前的apache 配置
```yaml
/etc/httpd/extra/httpd-vhosts.conf:
  file.managed:
    - source: salt://webserver/httpd-vhosts.conf

apache:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/httpd/extra/httpd-vhosts.conf
    - require:
      - pkg: apache
```
##3.2 模板SLS的模块
SLS模板块可能需要编程的逻辑或则嵌套的执行。这是通过模块的模板，默认的模块模板系统使用的是`Jinja2`， 我们可以通过更改主配置的:conf_master:`renderer`值来改变这个
```yaml
{% for usr in 'moe','larry','curly' %}
{{ usr }}:
  group:
    - present
  user:
    - present
    - gid_from_name: True
    - require:
      - group: {{ usr }}
{% endfor %}
```
##3.3 使用GRAINS模板
很多时候一个state 在不同的系统上行为要不一样， Salt grains 在模板文本中将可以被应用，grains可以被使用在模板内。
```yaml
apache:
  pkg.installed:
    {% if grains['os'] == 'RedHat' %}
    - name: httpd
    {% elif grains['os'] == 'Ubuntu' %}
    - name: apache2
    {% endif %}
```
### 3.3.1 在SLS模块中使用环境变量
```yaml
salt['environ.get']('VARNAME')
MYENVVAR="world" salt-call state.template test.sls

file.managed:
  - name: /tmp/hello
  - contents: {{ salt['environ.get']('MYENVVAR') }}

{% set myenvvar = salt['environ.get']('MYENVVAR') %}
{% if myenvvar %}

Create a file with contents from an environment variable:
  file.managed:
    - name: /tmp/hello
    - contents: {{ salt['environ.get']('MYENVVAR') }}

{% else %}
Fail - no environment passed in:
  test:
    A. fail_without_changes
{% endif %}
```
### 3.3.2 在模板中调用模块
salt:一个可用的模块函数在salt模板中,就像下面这样。
运行简单shell命令在SLS模块中:salt['network.hw_addr']('eth0')
```yaml
moe:
  user.present:
    - gid: {{ salt['file.group_to_gid']('some_group_that_exists') }}
```
### 3.3.3 更高级的SLS模块语法

python/python-libs.sls:
```yaml
python-dateutil:
  pkg.installed
```
python/django.sls:
```yaml
include:
  - python.python-libs

django:
  pkg.installed:
    - require:
      - pkg: python-dateutil
```
EXTEND DECLARATION:
apache/apache.sls:
```yaml
apache:
  pkg.installed
```

apache/mywebsite.sls:
```yaml
include:
  - apache.apache

extend:
  apache:
    service:
      - running
      - watch:
        - file: /etc/httpd/extra/httpd-vhosts.conf

/etc/httpd/extra/httpd-vhosts.conf:
  file.managed:
    - source: salt://apache/httpd-vhosts.conf
```
apache/mywebsite.sls:
```yaml
include:
  - apache.apache

extend:
  apache:
    service:
      - running
      - watch:
        - file: mywebsite

mywebsite:
  file.managed:
    - name: /etc/httpd/extra/httpd-vhosts.conf
    - source: salt://apache/httpd-vhosts.conf

```
```yaml
stooges:
  user.present:
    - names:
      - moe
      - larry
      - curly
```









#参考资料
https://yq.aliyun.com/articles/44377
