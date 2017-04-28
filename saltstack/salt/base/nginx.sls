/usr/local/nginx/conf/nginx.conf:
  file.managed:
    - soure: salt://tools/nginx/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - backup: minion #备份

openssl-source-install:
  file.managed:
    - name: /var/sysmgmt/openssl-1.0.1t.tar.gz
    - source: salt://tools/nginx/openssl-1.0.1t.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /var/sysmgmt/ &&  tar xf openssl-1.0.1t.tar.gz -C /usr/local/
    - require:
      - file: openssl-source-install
    - unless: test -d /usr/local/openssl-1.0.1t

nginx-source-install:
  file.managed:
    - name: /var/sysmgmt/nginx-1.8.1.tar.gz
    - source: salt://tools/nginx/nginx-1.8.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /var/sysmgmt/ && tar xf nginx-1.8.1.tar.gz && cd nginx-1.8.1 && ./configure --prefix=/usr/local/nginx  --with-openssl=/usr/local/openssl-1.0.1t --with-http_ssl_module && make && make install && mkdir -p /usr/local/nginx/vhosts/
    - require:
      - file: nginx-source-install
    - unless: test -d /usr/local/nginx
