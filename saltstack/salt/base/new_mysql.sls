mysql:
  pkg.installed: []
  service.running:
    - wathc:
      - pkg: mysql
      - file: /data/mysql/my.cnf
      - user: mysql
  user.present:
    - uid: 87
    - gid: 87
    - home: /data/mysql
    - shell: /bin/nologin
    #声明将保证是在创建用户组后再创建用户
    - require:
      - group: mysql
  group.present:
    - gid: 87
    #声明将保证是在组建立基础上安装mysql
    - require:
      - pkg: mysql

/data/mysql/my.cnf:
  file.managed:
    - source: salt://conf/mysql/my.cnf
    - user: mysql
    - group: mysql
    - mode: 644
