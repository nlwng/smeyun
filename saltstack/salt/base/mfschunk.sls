mfschunk.source:
  file.managed:
    - name: /root/tools/mfs-1.6.27-5.gz
    - unless: test -e /root/tools/mfs-1.6.27-5.gz
    - user: root
    - group: root
    - makedirs: True
    - source: salt://mfschunk/files/mfs-1.6.27-5.gz
mfschunk.extract:
  cmd.run:
    - cwd: /root/tools
    - names:
      - tar xzf mfs-1.6.27-5.gz
    - unless: test -d /root/tools/mfs-1.6.27
    - require:
      - file: mfschunk.source
mfschunk.compile:
  cmd.run:
    - cwd: /root/tools/mfs-1.6.27
    - names:
      - ./configure --prefix=/data/soft/mfs-1.6.27 --sysconfdir=/data/soft/mfs-1.6.27/etc --localstatedir=/data/soft/mfs-1.6.27/var/lib --with-default-user=mfs --with-default-group=mfs --disable-mfsmaster && make && make install
    - unless: test -d /data/soft/mfs-1.6.27
    - require:
      - cmd: mfschunk.extract
mkfschunk.mfshdd:
  file.managed:
    - name: /data/soft/mfs-1.6.27/etc/mfs/mfshdd.cfg
    - source: salt://mfschunk/templates/mfshdd.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - unless: test -f /data/soft/mfs-1.6.27/etc/mfs/mfshdd.cfg
    - require:
      - cmd: mfschunk.compile
mfschunk.mfscfg:
  file.managed:
    - name: /data/soft/mfs-1.6.27/etc/mfs/mfschunkserver.cfg
    - source: salt://mfschunk/files/mfschunkserver.cfg
    - user: root
    - group: root
    - mode: 644
    - unless: test -f /data/soft/mfs-1.6.27/etc/mfs/mfschunkserver.cfg
    - require:
      - cmd: mfschunk.compile
mfschunk.init:
  file.managed:
    - name: /etc/init.d/mfschunk
    - source: salt://mfschunk/files/mfschunk
    - user: root
    - group: root
    - mode: 755
    - unless: test -f  /etc/init.d/mfschunk
    - require:
      - cmd: mfschunk.compile
