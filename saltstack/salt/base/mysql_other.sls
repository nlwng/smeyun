mysql_user:
  user.present:
    - name: mysql
    - uid: 1024
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

mysql_pkg:
  pkg.installed:
    - pkgs:
      - gcc
      - gcc-c++
      - autoconf
      - automake
      - openssl
      - openssl-devel
      - zlib
      - zlib-devel
      - ncurses-devel
      - libtool-ltdl-devel
      - cmake

#install source mysql
mysql_source:
  file.managed:
    - name: /var/sysmgmt/mysql-5.6.27.tar.gz
    - unless: test -e /var/sysmgmt/mysql-5.6.27.tar.gz
    - source: salt://tools/mysql-5.6.27.tar.gz
#tar source mysql
extract_mysql:
  cmd.run:
    - cwd: /var/sysmgmt/
    - names:
        - tar zxf mysql-5.6.27.tar.gz
        - chown mysql:mysql /data/mysql5.6.27 -R
    - unless: test -d /data/mysql5.6.27
    - require:
        - file: mysql_source

#mysql source install
mysql_commpile:
  cmd.run:
    - cwd: /home/mysql-5.5.22
    - names:
        #- cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DDEFAULT_CHARSET=utf8  -DDEFAULT_COLLATTON=utf8_cuicode_ci   -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=1  -DENABLED_LOCAL_INFILE=1 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_DEBUG=0
        - cmake -DCMAKE_INSTALL_PREFIX=/data/mysql5.6.27;make && make install
    - require:
        - cmd.run: extract_mysql
        - pkg: mysql_pkg
    - unless: test -d /data/mysql5.6.27
