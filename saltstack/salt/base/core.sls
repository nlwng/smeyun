core:
#saltstack安装器
  pkg.installed:
    - pkgs:
      - lrzsz
      - nc
      - wget
      - rysnc
      - gcc
      - gcc-c++
      - gcc-g77
      - autoconf
      - automake
      - libtool-ltdl-devel*
      - make
      - cmake
      - openssl
      - pcre
      - policycoreutils-python
      - tree
      - curl
      - vim-enhanced
      - unzip
      {% if grains['os'] == 'Ubuntu' %}
      - iotop
      {% elif grains['os'] == 'CentOS' %}
      - iotop
      {% endif %}

#安装一些基础工具
sysmgmt-dir:
  file.directory:
    - name: /var/sysmgmt
    - mode: 700
    
#创建默认的管理脚本存放目录
#{% for ipaddress in grains['ipv4'] %}
#      - {{ ipaddress }} {{ grains['fqdn'] }}
#{% endfor %}
#将一些常用的域名解析和本机主机名解析追加到/etc/hosts文件。
