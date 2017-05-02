<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [cdn](#cdn)
- [1 主流cdn几种方式](#1-主流cdn几种方式)
	- [1.1 nginx+memcache](#11-nginxmemcache)
		- [1.1.1 Memcache原理:](#111-memcache原理)
		- [1.1.2 memcached_pass模块:](#112-memcachedpass模块)
		- [1.1.3 nginx支持memcached分布式访问](#113-nginx支持memcached分布式访问)
		- [1.1.4 案例1](#114-案例1)
		- [1.1.5 案例2](#115-案例2)

<!-- /TOC -->

# cdn
# 1 主流cdn几种方式
  .squid  
  .varnish  
  .Nginx+memcache  

  其中nginx需要编程,squid最简单
## 1.1 nginx+memcache

nginx依赖:  
yum gcc prce openssl prce-devel openssl-devel
memcache依赖:  
yum install gcc libevent libevent-devel


### 1.1.1 Memcache原理:  
Memcache是一个通用的内存缓存系统。 它通常用于加速缓慢的数据访问。 NGINX memcached模块提供各种指令，可以配置为直接访问Memcache提供内容，从而避免对上游服务器的请求。  
除了指令之外，模块还创建$ memcached_key变量，用于执行高速缓存查找。 在使用Memcache查找之前，必须在$memcached_key变量中设置一个值，该变量根据请求URL确定。  

### 1.1.2 memcached_pass模块:  
此指令用于指定memcached服务器的位置。 地址可以通过以下任意方式指定:  
•域名或IP地址，以及可选端口   
•使用带unix：前缀的的Unix域套接字  
•使用NGINX upstream指令创建的一组服务器  

该指令仅在NGINX配置的location和location if中使用。 如下例子:
```
location /myloc/{
   set $memached_key $uri;
   memcached_pass localhost:11211;
   }
```
memcached_connect_timeout / memcached_ send_timeout / memcached_read_timeout:  
memcached connect_timeout指令设置在NGINX和memcached服务器之间建立连接的超时。  
memcached_send_timeout指令设置将请求写入memcached服务器的超时。  
memcached_read_timeout指令设置从memcached服务器读取响应的超时。

所有指令的默认值为60秒，可在NGINX配置的http，server和location区块下使用。 如下例子:  
```
http{
   memcached_send_timeout 30s;
   memcached_connect_timeout 30s;
   memcached_read_timeout 30s;
   }
```
memcached_bind:  
此指令指定服务器的哪个IP与memcached连接，默认为关闭，即不指定，那么Nginx会自动选择服务器的一个IP用来连接  

完整示例:
```
server{
   location /python/css/ {
   alias "/code/location/css/";
   }
   location /python/ {
   set $memcached_key "$request_method$request_uri";
   charset utf-8;
   memcached_pass 127.0.0.1:11211;
   error_page 404 502 504 = @pythonfallback;
   default_type text/html;
   }
   location @pythonfallback {
   rewrite ^/python/(.*) /$1 break;

   proxy_pass http://127.0.0.1:5000;
   proxy_set_header X-Cache-Key "$request_method$request_uri";
   }
   # Rest NGINX configuration omitted for brevity
}
```
### 1.1.3 nginx支持memcached分布式访问
Nginx可以通过upstream支持访问多个Memcached服务节点:  
```
upstream memcached {
    server 127.0.0.1:11211;
    server 127.0.0.1:11212;
    server 127.0.0.1:11213;
    server 127.0.0.1:11214;
}

server {
    listen       80;
    server_name  dev.hwtrip.com;

    location ^~ /cache/ {
        set            $memcached_key $request_uri;
        memcached_pass memcached;
    }
    error_page     404 502 504 = @fallback;
}
```
### 1.1.4 案例1
应用场景：将页面的html代码内容缓存到Memcached中，通过Nginx直接连接并读取Memcached中的内容，来实现页面缓存   
优势:  
1.不再通过tomcat转发一次，速度更快（理论上应该会比以前的静态页面技术更快），资源占用更少，可实现，更少的服务器支持更多的PV  
2.缓存过期后通过转到给tomcat处理，再写入缓存，由java程序控制主要业务逻辑。配置少灵活性非常高  
3.Nginx配置简单  

具体配置:  
```
erver {
        listen   80;
        server_name  www.nginx.com;

        location / {
			proxy_pass	http://www.nginx.com/;
        }

		location ^~ /ddd/ {
			set $memcached_key	"$uri";
			memcached_pass      127.0.0.1:11211;
			memcached_connect_timeout 3s;
			memcached_read_timeout 3s;
			memcached_send_timeout 3s;			
			memcached_buffer_size 8k;
			error_page			501 404 502 = /fallback$uri;
		}

		location /fallback/ {
			internal;
			proxy_pass          http://www.nginx.com/;
		}

    }
```
问题:  
1.当增加Memcached服务器后需要修改Nginx配置文件  
2.当有多个Memcached服务器时，nginx会根据key通过轮询方式依次查找每一个服务器，不知道这样速度会不会有影响。  

### 1.1.5 案例2
```
worker_processes  1;  

events {  
    worker_connections  1024;  
}  


http {  
    include       mime.types;  
    default_type  application/octet-stream;    
    sendfile        on;    
    keepalive_timeout  65;    
    gzip  on;  

    upstream memcacheds {  
        server 127.0.0.1:11211;  
    }  

    server  {  
            listen       8080;  
            server_name  localhost;  
            index index.html index.htm index.php;  

            location /images/ {  
                    set $memcached_key $request_uri;  
                    add_header X-mem-key  $memcached_key;  
                    memcached_pass  memcacheds;  
                    default_type text/html;  
                    error_page 404 502 504 = @app;  
            }  

            location @app {  
                    proxy_pass http://127.0.0.1;  
            }  
    }
```


5.
