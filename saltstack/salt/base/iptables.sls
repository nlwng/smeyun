#清空防火墙
flush all:
  iptables.flush:
    - family: ipv4

#允许环回接口的入方向流量
allow loopback:
  iptables.append:
    - family: ipv4
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: lo


allow neildev login:
  iptables.append:
    - family: ipv4
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - source: 0.0.0.0
    - dport: 22
    - proto: tcp
    - save: True

#设置默认的INPUT链的默认策略为DROP
default deny INPUT:
  iptables.set_policy:
    - family: ipv4
    - table: filter
    - chain: INPUT
    - policy: DROP

#设置默认的INPUT链的默认策略为DROP
default deny FORWARD:
  iptables.set_policy:
    - family: ipv4
    - table: filter
    - chain: FORWARD
    - policy: DROP
