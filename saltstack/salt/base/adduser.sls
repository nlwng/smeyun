centos:
 #删除用户
  user.absent:
    - purge: Ture
    - force: Ture
root:
  user.present:
    - password: {{ pillar['password_admin'] }}
    - uid: 0
    - gid: 0

{{ pillar['username'] }}:
  user:
    - present
    - password: {{ pillar['password'] }}
    - groups:
      - nobody

/home/{{ pillar['username'] }}/.ssh:
  file:
    - directory
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - user: {{ pillar['username'] }}

/home/{{ pillar['username'] }}/.ssh/authorized_keys:
  file:
    - managed
    - source: salt://conf/authorized_keys
    - mode: 400
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file: /home/{{ pillar['username'] }}/.ssh

{{ pillar['username_webapp'] }}:
  user:
    - present
    - password: {{ pillar['password_webapp'] }}
    - groups:
      - nobody


/etc/sudoers.d/90-cloud-init-users:
  file.managed:
    - user: root
    - group: root
    - mode: 440
    - source: salt://conf/90-cloud-init-users

/etc/sudoers:
  file.managed:
    - user: root
    - group: root
    - mode: 440
    - source: salt://conf/sudoers
