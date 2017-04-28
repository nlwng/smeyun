java-dir:
  file.directory:
    - name: /usr/local/java
    - mode: 755

#文件来源
java.source:
  file.managed:
    - name: /var/sysmgmt/jdk-8u73-linux-x64.tar.gz
    - unless: test -e /var/sysmgmt/jdk-8u73-linux-x64.tar.gz
    - user: root
    - group: root
    - makedirs: True
    - source: salt://tools/jdk-8u73-linux-x64.tar.gz
#文件提取
java.extract:
  cmd.run:
    - cwd: /var/sysmgmt/
    - names:
      - tar zxvf jdk-8u73-linux-x64.tar.gz -C /usr/local/java/
    - unless: test -d /usr/local/java/jdk1.8.0_73  #若minion端不存在 /usr/local/java/jdk1.8.0_73这个文件，才会执行这个file模块
    - makedirs: True
    - require:
      - file: java.source

java-cfg:
  file.append:
    - name: /etc/profile
    - text:
      - ulimit -S -c 0 > /dev/null 2>&1dd
      - ulimit -n 65535
      - export JAVA_HOME=/usr/local/java/jdk1.8.0_73
      - export JRE_HOME=/usr/local/java/jdk1.8.0_73/jre
      - export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH
      - export PATH=$JAVA_HOME/bin:$PATH
