#include:
#  - init.install

mysql-source-install:
  file.managed:
    - name: /var/sysmgmt/mysql-5.6.27.tar.gz
    - source: salt://tools/mysql/mysql-5.6.27.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /var/sysmgmt/ && tar xf mysql-5.6.27.tar.gz && cd mysql-5.6.27 && cmake -DCMAKE_INSTALL_PREFIX=/data/mysql-5.6.27 && make && make install
    - require:
      - file: mysql-source-install
    - unless: test -d /data/mysql-5.6.27

mysql-init:
  file.managed:
    - name: /var/sysmgmt/init.sh
    - source: salt://tools/mysql/init.sh
    - user: root
    - group: root
    - mode: 755
  cmd.script:
    - name: /var/sysmgmt/init.sh
    - require:
      - cmd: mysql-source-install

mysql-config:
  file.managed:
    - name: /data/mysql-5.6.27/my.cnf
    - source: salt://tools/mysql/my.cnf
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: mysql-init

mysql-service:
  file.managed:
    - name: /etc/init.d/mysql
    - source: salt://tools/mysql/mysql
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add mysql
    - unless: chkconfig --list |grep mysql
    - require:
      - file: mysql-service
  service.running:
    - name: mysql
    - require:
      - cmd: mysql-service
