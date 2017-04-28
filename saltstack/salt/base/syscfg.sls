#创建默认的管理脚本存放目录
hosts-cfg:
  file.append:
    - name: /etc/hosts
    - text:
      - 10.30.1.184 smesalt

resolv-cfg:
  file.append:
    - name: /etc/resolv.conf
    - text:
      - nameserver 221.7.92.98
