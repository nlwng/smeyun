



## 1. ansible 相关模块

### 1.1 file 模块

| **名称**      | **必选** | **默认值** | **可选值**                            | **备注**                                                     |
| :------------ | -------- | ---------- | ------------------------------------- | ------------------------------------------------------------ |
| follow        | no       | no         | yes/no                                | 是否遵循目的机器中的文件系统链接                             |
| force         | no       | yes        | yes/no                                | 强制执行                                                     |
| group         | no       |            |                                       | 设置文件/目录的所属组                                        |
| mode          | no       |            |                                       | 设置文件权限，模式实际上是八进制数字（如0644），少了前面的零可能会有意想不到的结果。从版本1.8开始，可以将模式指定为符号模式（例如u+rwx或u=rw,g=r,o=r） |
| owner         | no       |            |                                       | 设置文件/目录的所属用户                                      |
| path          | yes      |            |                                       | 目标文件/目录，也可以用dest,name代替                         |
| recurse       | no       | no         | yes/no                                | 是否递归设置属性（仅适用于state=directory）                  |
| src           | no       |            |                                       | 要链接到的文件路径（仅适用于state=link）                     |
| state         | no       | file       | file/link/directory/hard/touch/absent | 若果是directory，所有的子目录将被创建（如果它们不存在）；若是file，文件将不会被创建（如果文件不存在）；link表示符号链接；若是absent，目录或文件会被递归删除；touch代表生成一个空文件；hard代表硬链接； |
| unsafe_writes | no       |            | yes/no                                | 是否以不安全的方式进行，可能导致数据损坏                     |



模块选项

force：需要在两种情况下强制创建软链接，一种是源文件不存在但之后会建立的情况下；另一种是目标软链接已存在,需要先取消之前的软链，然后创建新的软链，有两个选项：yes|no

   group：定义文件/目录的属组

   mode：定义文件/目录的权限

   owner：定义文件/目录的属主

​    path：必选项，定义文件/目录的路径

​    recurse：递归的设置文件的属性，只对目录有效

   src：要被链接的源文件的路径，只应用于state=link的情况

   dest：被链接到的路径，只应用于state=link的情况

   state：

​           directory：如果目录不存在，创建目录

​           file：即使文件不存在，也不会被创建

​           link：创建软链接

​           hard：创建硬链接

​           touch：如果文件不存在，则会创建一个新的文件，如果文件或目录已存在，则更新其最后修改时间

​           absent：删除目录、文件或者取消链接文件

设置文件权限：- owner\group\mode

```yaml
[root@centos7 ~]# ansible test -m file -a "path=/root/test.sh owner=liuhao group=liuhao mode=0777"
```



删除文件或者目录 - state=absent

```yaml
[root@centos7 ~]# ansible test -m file -a "path=/tmp/liuhao state=absent"
[root@centos7 ~]# ansible test -m file -a "path=/tmp/liuhao_testfile state=absent"
```

```yaml
- name: Change file ownership, group and permissions
  file:
    path: /etc/foo.conf
    owner: foo
    group: foo
    mode: '0644'

- name: Create an insecure file
  file:
    path: /work
    owner: root
    group: root
    mode: '1777'

- name: Create a symbolic link
  file:
    src: /file/to/link/to
    dest: /path/to/symlink
    owner: foo
    group: foo
    state: link

- name: Create two hard links
  file:
    src: '/tmp/{{ item.src }}'
    dest: '{{ item.dest }}'
    state: link
  with_items:
    - { src: x, dest: y }
    - { src: z, dest: k }

- name: Touch a file, using symbolic modes to set the permissions (equivalent to 0644)
  file:
    path: /etc/foo.conf
    state: touch
    mode: u=rw,g=r,o=r

- name: Touch the same file, but add/remove some permissions
  file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx

- name: Touch again the same file, but dont change times this makes the task idempotent
  file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx
    modification_time: preserve
    access_time: preserve

- name: Create a directory if it does not exist
  file:
    path: /etc/some_directory
    state: directory
    mode: '0755'

- name: Update modification and access time of given file
  file:
    path: /etc/some_file
    state: file
    modification_time: now
    access_time: now

- name: Set access time based on seconds from epoch value
  file:
    path: /etc/another_file
    state: file
    access_time: '{{ "%Y%m%d%H%M.%S" | strftime(stat_var.stat.atime) }}'

- name: Recursively change ownership of a directory
  file:
    path: /etc/foo
    state: directory
    recurse: yes
    owner: foo
    group: foo
```



### 1.2 wait_for模块

当你利用service 启动tomcat，或数据库后，他们真的启来了么？这个你是否想确认下？

wait_for模块就是干这个的。*等待一**个事情发生，然后继续*。它可以等待某个端口被占用，然后再做下面的事情，也可以在一定时间超时后做另外的事。

![1558926135846](D:\smeyun\doc\ansible\1558926135846.png)



```yaml
ansible-doc -s wait_for
- name: Waits for a condition before continuing.
action: wait_for
delay # 在检查操作进⾏之前等待的秒数
host # 等待这个主机处于启动状态，默认为127.0.0.1
port # 等待这个端⼝已经开放
path # 这个⽂件是否已经存在
search_regex # 在⽂件中进⾏正则匹配
state # present/started/stopped/absent/drained.默认started

当检查的是⼀个端⼝时：
started:保证端⼝是开放的
stopped:保证端⼝是关闭的
当检查的是⼀个⽂件时：
present/started:在检查到⽂件存在才会继续
absent:检查到⽂件被移除后才会继续
sleep # 两次检查之间sleep的秒数，默认1秒
timeout # 检查的等待超时时间(秒数，默认300)
# 连接上主机后10秒后才检查8000端⼝是否处于开放状态，300秒(默认值)内未开放则超时。
- wait_for:
port: 8000
delay: 10
# 直到/tmp/foo⽂件存在才会继续
- wait_for:
path: /tmp/foo
# 直到/tmp/foo⽂件中能匹配"completed"字符串才继续
- wait_for:
path: /tmp/foo
search_regex: completed
# 直到/var/lock/file.lock这个锁⽂件被移除了才继续
- wait_for:
path: /var/lock/file.lock
state: absent
# 直到/proc/3466/status⽂件被移除才继续，可⽤来判断进程是启动还是停⽌，pid⽂件是存在还是被移除等
- wait_for:
path: /proc/3466/status
state: absent
```

等待一个端口变得可用或者等待一个文件变得可用

```yaml
- name: Wait for container ssh
  wait_for:
    port: "22"
    delay: "{{ ssh_delay }}"
    search_regex: "OpenSSH"
    host: "{{ ansible_host }}"
  delegate_to: "{{ physical_host }}"
  register: ssh_wait_check
  until: ssh_wait_check | success
  retries: 3
  when:
    - (_mc is defined and _mc | changed) or (_ec is defined and _ec | changed)
    - not is_metal | bool
  tags:
    - common-lxc



### pip_wheel_install为链表变量
- name: Install wheel packages
  shell: cd /tmp/wheels && pip install {{ item }}*
  with_items:
    - "{{ pip_wheel_install | default([]) }}"
  when: pip_wheel_install > 0
```



### 1.3 copy 模块

用copy模块复制多个文件:

正确写法是下面这个 (这个是roles/tasks/main.yml的一部分)

中文文档的循环部分的章节：<http://www.ansible.com.cn/docs/playbooks_loops.html#standard-loops>

```yaml
- name: copy mysql files
  copy:
    src: '{{ item.src }}'
    dest: '{{ item.dest }}'
  with_items:
    - { src: 'mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz', dest: '/usr/local/src/MySQL5.7.tar.gz' }
    - { src: 'install.sh', dest: '/usr/local/src/install.sh' }
    - { src: 'my.cnf', dest: '/etc/my.cnf' }
    - { src: 'mysql.sh', dest: '/etc/profile.d/mysql.sh' }
```

```yaml
ansible test -m copy -a "src=test.sh dest=/root/liuhao/test"
```



```yaml
#获取tomcat
- name: synchronize apache-tomcat-client
  synchronize: src=apache-tomcat-client/ dest=/opt/apache-tomcat-client/
  become: true
 
#配置tomcat的日志切割脚本，及定时任务
- name: copy content to cut_tomcat_log.sh
  copy:
    content: |
      #!/bin/bash
 
      log_path=/opt/apache-tomcat-client
      log_dir_name=`date +%Y\-%m`
      log_time=`date +%F -d -1day`
      yesterday_dir=`date +%Y\-%m -d -1day`
 
      cp $log_path/logs/catalina.out $log_path/logs/catalina.out-$log_time
      echo > $log_path/logs/catalina.out
 
      tar_log(){
          tar zcvf $log_time.tar.gz *$yesterday_dir-*  --remove-files
          mv $log_time.tar.gz $yesterday_dir
      }
 
      cd $log_path/logs
 
      if [ -d $log_dir_name ]
          then
          tar_log
      else
          mkdir $log_dir_name
          tar_log
      fi
    dest: /root/cut_tomcat_log.sh
    mode: 644
  become: true
- name: add cut_tomcat_log.sh to crontab
  cron: name='add cut_tomcat_log.sh for tomcat' minute=1 hour=0 job="sh /root/cut_tomcat_log.sh"
  become: true
 
#配置tomcat日志清除脚本，及定时任务
- name: copy content to clear_tomcat_log.sh
  copy:
    content: |
      #!/bin/bash
 
      LOG_PATH="/opt/apache-tomcat-client/logs/"
      LOG_PATH_VAR="/var/log/httpd/"
      SPACE=`df -h|grep -w / |awk -F '[ %]'+ '{print $5}'`
      if [ $SPACE -ge 75 ];then
          if [ -d $LOG_PATH ];then
                cd /opt/apache-tomcat-client/logs/
                if [ $? -eq 0 ];then
                        find  . -type d -mtime +30 -exec  sudo rm -rf {} \;
                        find  . -type f -mtime +30 -exec  sudo rm -rf {} \;
                fi
          fi
          if [ -d $LOG_PATH_VAR ];then
                cd /var/log/httpd/
                if [ $? -eq 0 ];then
                        find . -type f -mtime +30 -exec  sudo rm -rf {} \;
                fi
          fi
      fi
    dest: /root/clear_tomcat_log.sh
    mode: 644
  become: true
- name: add clear_tomcat_log.sh to crontab
  cron: name='add clear_tomcat_log.sh for tomcat' minute=30 hour=0 job="sh /root/clear_tomcat_log.sh"
  become: true
 
```

上面是一个获取tomcat，然后配置tomcat日志定时切割和删除的任务。中控机本地并没有cut_tomcat_log.sh和clear_tomcat_log.sh这两个脚本，通过content选项指定内容后，直接在远程目标机上生成出来。这里注意一下，content选项后面有个“|”竖线用来换行，不然生成的文件内容格式可能有问题。

```yaml
# You can use shell to run other executables to perform actions inline
- name: Run expect to wait for a successful PXE boot via out-of-band CIMC
  shell: |
    set timeout 300
    spawn ssh admin@{{ cimc_host }}
 
    expect "password:"
    send "{{ cimc_password }}\n"
 
    expect "\n{{ cimc_name }}"
    send "connect host\n"
 
    expect "pxeboot.n12"
    send "\n"
 
    exit 0
  args:
    executable: /usr/bin/expect
  delegate_to: localhost
```



### 1.4 delegate_to模块

如果你想参考其它主机来在一个主机上执行一个任务,我们就可以使用’delegate_to’关键词在你要执行的任务上. 这个对于把节点放在一个负载均衡池里面活着从里面移除非常理想. 这个选项也对处理窗口中断非常有用. 使用’serial’关键词来控制一定数量的主机也是一个好想法:

```yaml
---

- hosts: webservers
  serial: 5

  tasks:

  - name: take out of load balancer pool
    command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
    delegate_to: 127.0.0.1

  - name: actual steps would go here
    yum: name=acme-web-stack state=latest

  - name: add back to load balancer pool
    command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
    delegate_to: 127.0.0.1
```



这些命令可以在127.0.0.1上面运行,这个运行Ansible的主机.这个也是一个简写的语法用在每一个任务基础（per-task basis）: ‘local_action’.以上就是这样一个playbook.但是使用的是简化后的语法在172.0.0.1上面做代理::

```yaml
---# ...
  tasks:

  - name: recursively copy files from management server to target
    local_action: command rsync -a /path/to/files {{ inventory_hostname }}:/path/to/target/
```

这样可以添加在”delegat_to”选项对中来定义要执行的主机:

```yaml
- command: /opt/application/upgrade_db.py
  run_once: true
  delegate_to: web01.example.org
```



### 1.5 debug输出task执行的register:

```yaml
- name: check extract session
#  script: /app/ansiblecfg/XXX/roles/test/tasks/psgrep.sh > /home/shdxspark/psgrep.log
  script: /app/ansiblecfg/XXX/roles/test/tasks/psgrep.sh
  register: psgrep_output

#通过debug方式打印psgrep.sh脚本的返回结果psgrep_output
- debug: var=psgrep_output.stdout_lines
```

![1558927298700](D:\smeyun\doc\ansible\1558927298700.png)

### 1.6 run_once执行一次

有时候你有这样的需求,在一个主机上面只执行一次一个任务.这样的配置可以配置”run_once”来实现:

```yaml
---# ...

  tasks:

    # ...

    - command: /opt/application/upgrade_db.py
      run_once: true

    # ...
```

当”run_once” 没有喝”delegate_to”一起使用,这个任务将会被清单指定的第一个主机. 在一组被play制定主机.例如 webservers[0], 如果play指定为 “hosts: webservers”.

这个方法也很类似,虽然比使用条件更加简单粗暴,如下事例:

```yam
- command: /opt/application/upgrade_db.py
  when: inventory_hostname == webservers[0]
```



### 1.7 register模块

register模块，ansible注册变量

```yaml
- hosts: web_servers
  tasks:
     - shell: /usr/bin/foo
       register: foo_result
       ignore_errors: True

     - shell: /usr/bin/bar
       when: foo_result.rc == 5
```

### 1.8 with_first_found

通过with_first_found实现文件匹配，第一个文件匹配不到，才会去匹配第二个文件，依此类推

```yaml
- name: template a file
   template: src={{ item }} dest=/etc/myapp/foo.conf
   with_first_found:
     - files:
         - {{ ansible_distribution }}.conf
         - default.conf
       paths:
         - search_location_one/somedir/
         - /opt/other_location/somedir/
```

###  1.9 rsync

<https://stackoverflow.com/questions/3299951/how-to-pass-password-automatically-for-rsync-ssh-command>

<https://stackoverflow.com/questions/24504430/ansible-prompts-password-when-using-synchronize>

```
/usr/bin/rsync -ratlz --rsh="/usr/bin/sshpass -p urwelcome ssh -o StrictHostKeyChecking=no -l root" /tmp/rsync  /tmp/rsync


sshpass -p "urwelcome" rsync -ae "ssh -p remote_port_ssh" /local_dir  remote_user@remote_host:/remote_dir

rsync -Pav -e "ssh -o StrictHostKeyChecking=no -i /tmp/tokenkey" root@172.168.1.145:/tmp/11111.txt . 
```



```yaml
- name: Synchronization of src on the control machine to dest on the remote hosts
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path

- name: Synchronization using rsync protocol (push)
  synchronize:
    src: some/relative/path/
    dest: rsync://somehost.com/path/

- name: Synchronization using rsync protocol (pull)
  synchronize:
    mode: pull
    src: rsync://somehost.com/path/
    dest: /some/absolute/path/

- name:  Synchronization using rsync protocol on delegate host (push)
  synchronize:
    src: /some/absolute/path/
    dest: rsync://somehost.com/path/
  delegate_to: delegate.host

- name: Synchronization using rsync protocol on delegate host (pull)
  synchronize:
    mode: pull
    src: rsync://somehost.com/path/
    dest: /some/absolute/path/
  delegate_to: delegate.host

- name: Synchronization without any --archive options enabled
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
    archive: no

- name: Synchronization with --archive options enabled except for --recursive
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
    recursive: no

- name: Synchronization with --archive options enabled except for --times, with --checksum option enabled
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
    checksum: yes
    times: no

- name: Synchronization without --archive options enabled except use --links
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
    archive: no
    links: yes

- name: Synchronization of two paths both on the control machine
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
  delegate_to: localhost

- name: Synchronization of src on the inventory host to the dest on the localhost in pull mode
  synchronize:
    mode: pull
    src: some/relative/path
    dest: /some/absolute/path

- name: Synchronization of src on delegate host to dest on the current inventory host.
  synchronize:
    src: /first/absolute/path
    dest: /second/absolute/path
  delegate_to: delegate.host

- name: Synchronize two directories on one remote host.
  synchronize:
    src: /first/absolute/path
    dest: /second/absolute/path
  delegate_to: "{{ inventory_hostname }}"

- name: Synchronize and delete files in dest on the remote host that are not found in src of localhost.
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
    delete: yes
    recursive: yes

# This specific command is granted su privileges on the destination
- name: Synchronize using an alternate rsync command
  synchronize:
    src: some/relative/path
    dest: /some/absolute/path
    rsync_path: su -c rsync

# Example .rsync-filter file in the source directory
# - var       # exclude any path whose last part is 'var'
# - /var      # exclude any path starting with 'var' starting at the source directory
# + /var/conf # include /var/conf even though it was previously excluded

- name: Synchronize passing in extra rsync options
  synchronize:
    src: /tmp/helloworld
    dest: /var/www/helloworld
    rsync_opts:
      - "--no-motd"
      - "--exclude=.git"

# Hardlink files if they didn't change
- name: Use hardlinks when synchronizing filesystems
  synchronize:
    src: /tmp/path_a/foo.txt
    dest: /tmp/path_b/foo.txt
    link_dest: /tmp/path_a/

# Specify the rsync binary to use on remote host and on local host
- hosts: groupofhosts
  vars:
        ansible_rsync_path: /usr/gnu/bin/rsync

  tasks:
    - name: copy /tmp/localpath/ to remote location /tmp/remotepath
      synchronize:
        src: /tmp/localpath/
        dest: /tmp/remotepath
        rsync_path: /usr/gnu/bin/rsync
```

https://docs.ansible.com/ansible/latest/modules/synchronize_module.html

### 1.10 fetch远端拉回

- flat： yes 指定实际目录

```yaml
- name: fetch copy
  fetch:        
    src: /tmp/auto-rsync.sh
    dest: /tmp/auto-rsync.sh                                                                                 
    flat: yes
```

### 1.11 lineinfile 修改文件内容



```yaml
   - name: seline modify enforcing
      lineinfile:
         dest: /etc/selinux/config
         regexp: '^SELINUX='
         line: 'SELINUX=enforcing'
         
         
 insertbefore匹配内容在前面添加：
  
     - name: httpd.conf modify 8080
      lineinfile:
         dest: /opt/playbook/test/http.conf
         regexp: '^Listen'
         insertbefore: '^#Port'   
         line: 'Listen 8080'
      tags:
       - http8080 
 insertafter匹配内容在后面添加：
 
 - name: httpd.conf modify 8080
      lineinfile:
         dest: /opt/playbook/test/http.conf
         regexp: '^Listen'
         insertafter: '^#Port'   
         line: 'Listen 8080'
      tags:
       - http8080
       
 修改host：      
    - name: modify hosts
      lineinfile:
         dest: /opt/playbook/test/hosts
         regexp: '^127\.0\.0\.1'
         line: '127.0.0.1 localhosts'
         owner: root
         group: root
         mode: 0644
      tags:
       - hosts   

删除文件某行：
- name: delete 192.168.1.1
      lineinfile:
         dest:  /opt/playbook/test/hosts
         state: absent
         regexp: '^192\.'
      tags:
       - delete192       
 
 文件存在就添加一行：
 
    - name: add a line
      lineinfile:
         dest:  /opt/playbook/test/hosts
         line: '192.168.1.2 foo.lab.net foo'
      tags:
       - add_a_line 
       
       
# NOTE: Before 2.3, option 'dest', 'destfile' or 'name' was used instead of 'path'
- name: Ensure SELinux is set to enforcing mode
  lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: SELINUX=enforcing

- name: Make sure group wheel is not in the sudoers configuration
  lineinfile:
    path: /etc/sudoers
    state: absent
    regexp: '^%wheel'

- name: Replace a localhost entry with our own
  lineinfile:
    path: /etc/hosts
    regexp: '^127\.0\.0\.1'
    line: 127.0.0.1 localhost
    owner: root
    group: root
    mode: '0644'

- name: Ensure the default Apache port is 8080
  lineinfile:
    path: /etc/httpd/conf/httpd.conf
    regexp: '^Listen '
    insertafter: '^#Listen '
    line: Listen 8080

- name: Ensure we have our own comment added to /etc/services
  lineinfile:
    path: /etc/services
    regexp: '^# port for http'
    insertbefore: '^www.*80/tcp'
    line: '# port for http by default'

- name: Add a line to a file if the file does not exist, without passing regexp
  lineinfile:
    path: /tmp/testfile
    line: 192.168.1.99 foo.lab.net foo
    create: yes

# NOTE: Yaml requires escaping backslashes in double quotes but not in single quotes
- name: Ensure the JBoss memory settings are exactly as needed
  lineinfile:
    path: /opt/jboss-as/bin/standalone.conf
    regexp: '^(.*)Xms(\\d+)m(.*)$'
    line: '\1Xms${xms}m\3'
    backrefs: yes

# NOTE: Fully quoted because of the ': ' on the line. See the Gotchas in the YAML docs.
- name: Validate the sudoers file before saving
  lineinfile:
    path: /etc/sudoers
    state: present
    regexp: '^%ADMIN ALL='
    line: '%ADMIN ALL=(ALL) NOPASSWD: ALL'
    validate: /usr/sbin/visudo -cf %s
 
```

### 1.12 template



```yaml
- name: copy key file
  template:
    src: tokenkey.j2
    dest: /tmp/tokenkey
    mode: 0600
  #ignore_errors: yes
  tags:
   - copy_key
```

### 1.13 uri 模块

```yaml
- name: Check that you can connect (GET) to a page and it returns a status 200
  uri:
    url: http://www.example.com

- name: Check that a page returns a status 200 and fail if the word AWESOME is not in the page contents
  uri:
    url: http://www.example.com
    return_content: yes
  register: this
  failed_when: "'AWESOME' not in this.content"

- name: Create a JIRA issue
  uri:
    url: https://your.jira.example.com/rest/api/2/issue/
    user: your_username
    password: your_pass
    method: POST
    body: "{{ lookup('file','issue.json') }}"
    force_basic_auth: yes
    status_code: 201
    body_format: json

- name: Login to a form based webpage, then use the returned cookie to access the app in later tasks
  uri:
    url: https://your.form.based.auth.example.com/index.php
    method: POST
    body_format: form-urlencoded
    body:
      name: your_username
      password: your_password
      enter: Sign in
    status_code: 302
  register: login

- name: Login to a form based webpage using a list of tuples
  uri:
    url: https://your.form.based.auth.example.com/index.php
    method: POST
    body_format: form-urlencoded
    body:
    - [ name, your_username ]
    - [ password, your_password ]
    - [ enter, Sign in ]
    status_code: 302
  register: login

- name: Connect to website using a previously stored cookie
  uri:
    url: https://your.form.based.auth.example.com/dashboard.php
    method: GET
    return_content: yes
    headers:
      Cookie: "{{ login.set_cookie }}"

- name: Queue build of a project in Jenkins
  uri:
    url: http://{{ jenkins.host }}/job/{{ jenkins.job }}/build?token={{ jenkins.token }}
    user: "{{ jenkins.user }}"
    password: "{{ jenkins.password }}"
    method: GET
    force_basic_auth: yes
    status_code: 201

- name: POST from contents of local file
  uri:
    url: https://httpbin.org/post
    method: POST
    src: file.json

- name: POST from contents of remote file
  uri:
    url: https://httpbin.org/post
    method: POST
    src: /path/to/my/file.json
    remote_src: yes
```

网上案列

我试图调用一些REST API并对Ansible服务执行一些POST请求。由于正文（JSON）发生变化，我正在尝试对某些文件执行循环。这里是剧本：[Ansible：循环文件做POST请求](https://jsproxy.ga/-----http://cn.voidcc.com/question/p-zphonmwv-bky.html)

```
- hosts: 127.0.0.1 
    any_errors_fatal: true 

    tasks: 
    - name: do post requests            
     uri: 
     url: "https://XXXX.com" 
     method: POST 
     return_content: yes 
     body_format: json 
     headers: 
      Content-Type: "application/json" 
      X-Auth-Token: "XXXXXX" 
     body: "{{ lookup('file', "{{ item }}") }}" 
     with_file: 
      - server1.json 
      - server2.json 
      - proxy.json 

但是当我运行的剧本，我得到这个错误：

the field 'args' has an invalid value, which appears to include a variable that is undefined. The error was: 'item' is undefined

问题出在哪里？
```

- 主要问题是`with_`指令应该属于一个任务字典（一个缩进级别）。

- 的第二个问题是，你应该用文件查找请使用`with_items`，或者干脆`"{{ item }}"`与`with_files`：

- 此外，`{{ ... }}`结构不是必需的方式来引用每个变量 - 它是一个构造，打开一个Jinja2表达式，在其中使用va riables。对于一个变量它确实变成了：`{{ variable }}`，但一旦你打开它，你不需要再做了,完美写法为：

  **body: "{{ lookup('file', item) }}" **

  

```yaml
- name: do post requests            
    uri: 
    url: "https://XXXX.com" 
    method: POST 
    return_content: yes 
    body_format: json 
    headers: 
     Content-Type: "application/json" 
     X-Auth-Token: "XXXXXX" 
    body: "{{ item }}" 
    with_files: 
    - server1.json 
    - server2.json 
    - proxy.json 
    
或
- name: do post requests            
    uri: 
    url: "https://XXXX.com" 
    method: POST 
    return_content: yes 
    body_format: json 
    headers: 
     Content-Type: "application/json" 
     X-Auth-Token: "XXXXXX" 
    body: "{{ lookup('file', item) }}" 
    with_items: 
    - server1.json 
    - server2.json 
    - proxy.json 
    
此外，{{ ... }}结构不是必需的方式来引用每个变量 - 它是一个构造，打开一个Jinja2表达式，在其中使用va riables。对于一个变量它确实变成了：{{ variable }}，但一旦你打开它，你不需要再做了，所以它
```



### 1.14 with_dict 循环字典

1. 假设您有以下变量

```yaml
---
users:
  alice:
    name: Alice Appleworth
    telephone: 123-456-7890
  bob:
    name: Bob Bananarama
    telephone: 987-654-3210
```

并且您想要打印每个用户的姓名和电话号码。您可以像这样使用with_dict循环遍历哈希的元素

```yaml
tasks:
  - name: Print phone records
    debug:
      msg: "User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }})"
    with_dict: "{{ users }}"
```



2.假设字典为：

```
{
  "queue": {
    "first": {
      "car": "bmw",
      "year": "1990",
      "model": "x3",
      "color": "blue"
    },
    "second": {
      "car": "bmw",
      "year": "2000",
      "model": "318",
      "color": "red"
    }
  }
}
```

我正在尝试打印颜色的值，仅将其与其他变量进行比较。我用了 `with_dict` 迭代json对象（存储在名为jsonVar的变量中），如下所示：

```yaml
您可以使用名为的查找插件读取json文件 file 并把它传递给 from_json jinja2过滤器。你也有错误 with_dict 循环，因为你必须循环 jsonVar['queue']， 不只是 jsonVar。这是一个完整的代码，

---
- hosts: your_host
  vars:
    jsonVar: "{{ lookup('file', 'var.json') | from_json }}"
  tasks:
    - name: test loop
      with_dict: "{{ jsonVar['queue'] }}"
      shell: |
        if echo "blue" | grep -q "{{ item.value.color }}" ; then
            echo "success"
        fi
        
```

你可以使用| json_query过滤器：

[http://docs.ansible.com/ansible/playbooks_filters.html#json-query-filter](https://jsproxy.ga/-----http://docs.ansible.com/ansible/playbooks_filters.html#json-query-filter)

但要确保您输入的文件也是适当的格式，否则您可以使用两个过滤器，第一个转换为适当的过滤器，第二个过滤器执行json查询

例如： - `{{ variable_name | from_json | json_query('')}}`

```yaml
tasks: print the color
set_fact:
  color1 : "{{ jsonVar | from_json | json_query('queue.[0].['color']')}}"
  color2 : "{{ jsonVar | from_json | json_query('queue.[1].['color']')}}"
```



### 1.15 `with_fileglob` 

匹配单个目录中的所有文件，非递归，匹配模式。它调用Python的glob库，可以像这样使用：

```yaml
---
- hosts: all

  tasks:

    # first ensure our target directory exists
    - name: Ensure target directory exists
      file:
        dest: "/etc/fooapp"
        state: directory

    # copy each file over that matches the given pattern
    - name: Copy each file over that matches the given pattern
      copy:
        src: "{{ item }}"
        dest: "/etc/fooapp/"
        owner: "root"
        mode: 0600
      with_fileglob:
        - "/playbooks/files/fooapp/*"
```

### 1.16 `with_filetree` 

递归匹配目录树中的所有文件，使您能够在保留权限和所有权的同时模拟目标系统上的完整文件树

以下是我们如何在角色中使用with_filetree的示例：

```yaml
---
- name: Create directories
  file:
    path: /web/{{ item.path }}
    state: directory
    mode: '{{ item.mode }}'
  with_filetree: web/
  when: item.state == 'directory'

- name: Template files
  template:
    src: '{{ item.src }}'
    dest: /web/{{ item.path }}
    mode: '{{ item.mode }}'
  with_filetree: web/
  when: item.state == 'file'

- name: Recreate symlinks
  file:
    src: '{{ item.src }}'
    dest: /web/{{ item.path }}
    state: link
    force: yes
    mode: '{{ item.mode }}'
  with_filetree: web/
  when: item.state == 'link'
```

### 1.17 遍历列表

列表：

```yaml
---
alpha: [ 'a', 'b', 'c', 'd' ]
numbers:  [ 1, 2, 3, 4 ]
```

你想要'（a，1）'和'（b，2）'的集合。使用'with_together'来获取此信息：

```yaml
tasks:
    - debug:
        msg: "{{ item.0 }} and {{ item.1 }}"
      with_together:
        - "{{ alpha }}"
        - "{{ numbers }}"
```

### 1.18 重试任务，Do-Until Loops

有时您会想要重试任务，直到满足某个条件。这是一个例子：

```yaml
- shell: /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```

上面的示例递归地运行shell模块，直到模块的结果在其stdout中“所有系统都进入”或者任务已经被重试了5次，延迟为10秒。 “重试”的默认值为3，“延迟”为5。



### 1.19 简单的loops

为了节省一些打字，重复的任务可以用简写的方式编写，如下所示：

```yaml
- name: add several users
  user:
    name: "{{ item }}"
    state: present
    groups: "wheel"
  with_items:
     - testuser1
     - testuser2
     
如果您已在变量文件或“vars”部分中定义了YAML列表，则还可以执行以下操作：
with_items: "{{ somelist }}"

请注意，使用'with_items'迭代的项目类型不必是简单的字符串列表。如果您有哈希列表，则可以使用以下内容引用子键：

- name: add several users
  user:
    name: "{{ item.name }}"
    state: present
    groups: "{{ item.groups }}"
  with_items:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
    

循环也可以嵌套：
- name: give users access to multiple databases
  mysql_user:
    name: "{{ item[0] }}"
    priv: "{{ item[1] }}.*:ALL"
    append_privs: yes
    password: "foo"
  with_nested:
    - [ 'alice', 'bob' ]
    - [ 'clientdb', 'employeedb', 'providerdb' ]
    
    
    
    
```

<https://jsproxy.ga/-----https://docs.ansible.com/ansible/2.4/playbooks_loops.html>

循环



### 1.20 有条件执行 conditional execution

*register*, *when*, _changed_when_, _failed_when_ 例子：

```yaml
- name: install jdk rpm (suse)
  shell: zypper -n in {{ java_rpm }}
  when: os_family == "suse"
  register: install_java
  changed_when: install_java.rc == 0 and "already installed" not in install_java.stdout

- name: validate java home
  shell: . /etc/profile && echo $JAVA_HOME
  register: java_home_result
  failed_when: java_home_result.stdout is not defined or java_home_result.stdout
```

有些配置只需要做一次，例如数据库初始化，虽然 Ansible 提供了『[run_once](http://docs.ansible.com/ansible/playbooks_delegation.html#run-once)』，但感觉不好用，还是直接用变量做开关来控制。

```yaml
---
# ...

  tasks:

    # ...

    - command: /opt/application/upgrade_db.py
      run_once: true

    # ...
```



## 2. ansible 相关逻辑



### 2.1 循环

**1.Lookup**

```yaml
---
- hosts: all
  vars:
     contents: "{{ lookup('file', '/etc/foo.txt') }}"

  tasks:
     - debug: msg="the value of foo.txt is {{ contents }}"

Note:  切记读取的是本地文件
```

**2对并行数据集使用循环**

```yaml
假设你通过某种方式加载了以下变量数据:
---
alpha: [ 'a', 'b', 'c', 'd' ]
numbers:  [ 1, 2, 3, 4 ]

如果你想得到’(a, 1)’和’(b, 2)’之类的集合.可以使用’with_together’:
tasks:
    - debug: msg="{{ item.0 }} and {{ item.1 }}"
      with_together:
        - "{{alpha}}"
        - "{{numbers}}"
```



**3.模式1.标准循环**

```yaml

- name: add several users
  user: name={{ item }} state=present groups=wheel
  with_items:
     - testuser1
     - testuser2
  or
  with_items: "{{ somelist }}"
```

**4.模式2. 字典循环**

```yaml


- name: add several users
  user: name={{ item.name }} state=present groups={{ item.groups }}
  with_items:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
```

```java
---
- name: test
  hosts: masters
  tasks:
    - name: give users access to multiple databases
      command: "echo name={{ item[0] }} priv={{ item[1] }} test={{ item[2] }}"
      with_nested:
        - [ 'alice', 'bob' ]
        - [ 'clientdb', 'employeedb', 'providerdb' ]
        - [ '1', '2', ]
result:
changed: [localhost] => (item=[u'alice', u'clientdb', u'1'])
changed: [localhost] => (item=[u'alice', u'clientdb', u'2'])
changed: [localhost] => (item=[u'alice', u'employeedb', u'1'])
changed: [localhost] => (item=[u'alice', u'employeedb', u'2'])
changed: [localhost] => (item=[u'alice', u'providerdb', u'1'])
changed: [localhost] => (item=[u'alice', u'providerdb', u'2'])
changed: [localhost] => (item=[u'bob', u'clientdb', u'1'])
changed: [localhost] => (item=[u'bob', u'clientdb', u'2'])
changed: [localhost] => (item=[u'bob', u'employeedb', u'1'])
changed: [localhost] => (item=[u'bob', u'employeedb', u'2'])
changed: [localhost] => (item=[u'bob', u'providerdb', u'1'])
changed: [localhost] => (item=[u'bob', u'providerdb', u'2'])
```



假设字典如下:

```yaml
---
users:
  alice:
    name: Alice Appleworth
    telephone: 123-456-7890
  bob:
    name: Bob Bananarama
    telephone: 987-654-3210

可以访问的变量
tasks:
  - name: Print phone records
    debug: msg="User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }})"
    with_dict: "{{ users }}"
```

**5. 文件循环(with_file, with_fileglob)**

​       with_file 是将每个文件的文件内容作为item的值**

　　with_fileglob 是将每个文件的全路径作为item的值, 在文件目录下是非递归的, 如果是在role里面应用改循环, 默认路径是roles/role_name/files_directory**

```yaml
例如:
- copy: src={{ item }} dest=/etc/fooapp/ owner=root mode=600
      with_fileglob:
        - /playbooks/files/fooapp/*
```

**6. with_together**

```yaml
tasks:
    - command: echo "msg={{ item.0 }} and {{ item.1 }}"
      with_together:
        - [ 1, 2, 3 ]
        - [ 4, 5 ]

result:
changed: [localhost] => (item=[1, 4])
changed: [localhost] => (item=[2, 5])
changed: [localhost] => (item=[3, None])
```

**7. 子元素循环(with_subelements)**

　　**with_subelements 有点类似与嵌套循环, 只不过第一个参数是个dict, 第二个参数是dict下的一个子项.**

**8. 整数序列(with_sequence)**

　　**with_sequence 产生一个递增的整数序列,**

```yaml
---
- hosts: all

  tasks:

    # create groups
    - group: name=evens state=present
    - group: name=odds state=present

    # create some test users
    - user: name={{ item }} state=present groups=evens
      with_sequence: start=0 end=32 format=testuser%02x

    # create a series of directories with even numbers for some reason
    - file: dest=/var/stuff/{{ item }} state=directory
      with_sequence: start=4 end=16 stride=2

    # a simpler way to use the sequence plugin
    # create 4 groups
    - group: name=group{{ item }} state=present
      with_sequence: count=4
```

**9. 随机选择(****with_random_choice****)**

　　**with_random_choice****:在提供的list中随机选择一个值**

**10. Do-util**

```yaml
- action: shell /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```

有时你想重试一个任务直到达到某个条件.比如下面这个例子:

```yaml
- action: shell /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```

上面的例子递归运行shell模块,直到模块结果中的stdout输出中包含”all systems go”字符串,或者该任务按照10秒的延迟重试超过5次.”retries”和”delay”的默认值分别是3和5.

该任务返回最后一个任务返回的结果.单次重试的结果可以使用-vv选项来查看. 被注册的变量会有一个新的属性’attempts’,值为该任务重试的次数.



**11.第一个文件匹配(****with_first_found****)**

```yaml
- name: some configuration template
  template: src={{ item }} dest=/etc/file.cfg mode=0444 owner=root group=root
  with_first_found:
    - files:
       - "{{ inventory_hostname }}/etc/file.cfg"
      paths:
       - ../../../templates.overwrites
       - ../../../templates
    - files:
        - etc/file.cfg
      paths:
        - templates
```

**12.循环一个执行结果(with_lines)**

```yaml
---
- name: test
  hosts: all
  tasks:
    - name: Example of looping over a command result
      shell: touch /$HOME/{{ item }}
      with_lines: /usr/bin/cat  /home/fg/test

with_lines 中的命令永远都是在controller的host上运行, 只有shell命令才会在inventory中指定的机器上运行
```

**13.带序列号的list循环(****with_indexed_items****)**

**14.ini 文件循环(****with_ini****)**

```yaml
[section1]
value1=section1/value1
value2=section1/value2

[section2]
value1=section2/value1
value2=section2/value2
Here is an example of using with_ini:

- debug: msg="{{ item }}"
  with_ini: value[1-2] section=section1 file=lookup.ini re=true
```

**15.flatten循环(****with_flattened****)**

```yaml
---
- name: test
  hosts: all
  tasks:
    - name: Example of looping over a command result
      shell:  echo {{ item }}
      with_flattened:
        - [1, 2, 3]
        - [[3,4 ]]
        - [ ['red-package'], ['blue-package']]

:result

changed: [localhost] => (item=1)
changed: [localhost] => (item=2)
changed: [localhost] => (item=3)
changed: [localhost] => (item=3)
changed: [localhost] => (item=4)
changed: [localhost] => (item=red-package)
changed: [localhost] => (item=blue-package)
```

**16.register循环**

```yaml
- shell: echo "{{ item }}"
  with_items:
    - one
    - two
  register: echo

变量echo是一个字典, 字典中result是一个list, list中包含了每一个item的执行结果
```

**17.inventory循环(****with_inventory_hostnames****)**

```yam
# show all the hosts in the inventory
- debug: msg={{ item }}
  with_inventory_hostnames: all

# show all the hosts matching the pattern, ie all but the group www
- debug: msg={{ item }}
  with_inventory_hostnames: all:!www
```



### 2.2 判断

**条件判断**

　　**ansible的条件判断非常简单关键字是when, 有两种方式**

　　　　**1. python语法支持的原生态格式 conditions> 1 or conditions == "ss",   in, not 等等**

​              **2. ;ansible Jinja2 “filters”**

```yaml
tasks:
  - command: /bin/false
    register: result
    ignore_errors: True
  - command: /bin/something
    when: result|failed
  - command: /bin/something_else
    when: result|succeeded
  - command: /bin/still/something_else
    when: result|skipped

tasks:
    - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
      when: foo is defined

    - fail: msg="Bailing out. this play requires 'bar'"
      when: bar is undefined
```

**条件判断可以个loop role 和include一起混用**

```yaml
#when 和 循环
tasks:
    - command: echo {{ item }}
      with_items: [ 0, 2, 4, 6, 8, 10 ]
      when: item > 5

#when和include
- include: tasks/sometasks.yml
  when: "'reticulating splines' in output"

#when 和角色
- hosts: webservers
  roles:
     - { role: debian_stock_config, when: ansible_os_family == 'Debian' }
```

**根据条件判断是否执行**

```yaml
- name: "查看python3是否安装，忽略提示"
  shell: python3  #执行一条命令，将结果赋值给register定义的result
  register: result
  ignore_errors: True  #忽略错误提示

#拷贝Python-3.6.5
- name: "copy Python3-6.5 to dest"
  copy: src=Python-3.6.5.tgz  dest=/usr/local/src/Python-3.6.5.tgz
  when: result is failed  #当result返回的是个错误的时候，执行此tasks

#编译安装python3.6.5
- name: "compile install"
  shell: pip install --upgrade supervisor requests;cd /usr/local/src/;tar zxf Python-3.6.5.tgz; cd Python-3.6.5;./configure --prefix=/usr/local/python3 --with-ssl;make;make install
  when: result is failed

#软连接python3
- name: "ln -s python3"
  file: src=/usr/local/python3/bin/python3  dest=/usr/bin/python3 state=link
  when: result is failed
```



### 2.3 忽略错误

通常情况下, 当出现失败时 Ansible 会停止在宿主机上执行.有时候,你会想要继续执行下去.为此 你需要像这样编写任务:

```yaml
- name: this will not be counted as a failure
 command: /bin/false
 ignore_errors: yes
```

控制对失败的定义

假设一条命令的错误码毫无意义只有它的输出结果能告诉你什么出了问题,比如说字符串 “FAILED” 出 现在输出结果中.

在 Ansible 1.4及之后的版本中提供了如下的方式来指定这样的特殊行为

```yaml
- name: this command prints FAILED when it fails
 command: /usr/bin/example-command -x -y -z
 register: command_result
 failed_when: "'FAILED' in command_result.stderr"
```

在 Ansible 1.4 之前的版本能通过如下方式完成:

```yaml
- name: this command prints FAILED when it fails
  command: /usr/bin/example-command -x -y -z
  register: command_result
  ignore_errors: True

- name: fail the play if the previous command did not succeed
  fail: msg="the command failed"
  when: "'FAILED' in command_result.stderr"
```

### 2.4 tag 标签

```yaml
tasks:

   - yum: name={{ item }} state=installed
     with_items:
        - httpd
        - memcached
     tags:
        - packages

   - template: src=templates/src.j2 dest=/etc/foo.conf
     tags:
        - configuration
```

如果你只想运行一个非常大的 playbook 中的 “configuration” 和 “packages”,你可以这样做:

```yaml
ansible-playbook example.yml --tags "configuration,packages"
```

你同样也可以对 **roles** 应用 tags:

```yaml
roles:
 - { role: webserver, port: 5000, tags: [ 'web', 'foo' ] }
```

你同样也可以对基本的 **include** 语句使用 tag:

```yaml
- include: foo.yml tags=web,foo
```

### 2.5 Role 角色

```yaml
#理解
changed_when
failed_when
become
become_user
ansible_become
ansible_become_user
static


#检查group_vars中某组是否存在主机
- name: ensure only one monitoring host exists
  fail: msg="One, or no monitoring host may be specified."
  when: "groups.get('monitoring_servers', [])|length > 1"

#如果不定义值，那么使用默认值
- name: set deploy dir if not presented
  set_fact: deploy_dir="/home/{{deploy_user}}/deploy"
  when: deploy_dir is not defined

#禁掉swap
- name: disable swap
  shell: "([ $(swapon -s | wc -l) -ge 1 ] && (swapoff -a && echo disable)) || echo already"
  ignore_errors: yes
  register: swapoff_result
  changed_when: "swapoff_result.stdout.strip() == 'disable'"

#当set_timezone定义，设置相应时区
- name: set timezone to {{timezone}}
  timezone: name={{ timezone }}
  when: set_timezone

#设置hostname
- name: set hostname by ip
  hostname: name=ip-{{ ansible_default_ipv4.address | replace(".","-") }}
  register: hostname_set
  when:
    - set_hostname
    - "ansible_default_ipv4.address | replace('.','-') not in ansible_hostname"

#设置/etc/hosts
- name: inject hostname to hosts file
  lineinfile: dest=/etc/hosts line='127.0.0.1  ip-{{ ansible_default_ipv4.address | replace(\".\",\"-\") }}'
  when: set_hostname

'#修改文件中匹配到的某行
- name：modify centos irqbalance configuration file
  lineinfile:
    dest=/etc/default/irqbalance
    regexp='(?<!_)ONESHOT='
    line='ONESHOT=yes'
  when:
    - tuning_irqbalance_value
    - centos_irq_config_file.stat.exists

#检查umask
- name: get umask
  shell: umask
  register: umask
  changed_when: False

- name: does the system have a standard umask
  fail: 'The umask of the system ({{ umask.stdout.strip() }}) prevents successful installation. We suggest a standard umask such as 0022.'
  when: umask.stdout.strip()[-2:] not in ('00', '02', '20', '22')

#根据facts值，检查系统版本
- name: check system version
  fail:
    msg: "Red Hat Enterprise Linux/CentOS 6 is deprecated"
  when: "ansible_os_family == 'RedHat' and ansible_distribution_major_version == '6"

#检查文件挂载点
- name: detemine which mountpoint depoly dir exists on
  shell: "df {{ deploy_dir }} | tail -n1 | awk '{print $NF}'"
  register: deploy_partition
  changed_when: False

#抓取log
- name: fetch pd log file
  fetch:
    src: "{{ log_dir }}/{{ inventory_hostname }}-pd.tar.gz"
    dest: "{{ fetch_tmp_dir }}/{{ inventory_hostname }}/"
    flat: yes
    validate_checksum: no
  when: "'pd_servers' in group_names"

#下载tidb二进制
- name: download tidb binary
  get_url:
    url: "{{ item.url }}"
    dest: "{{ doenloads_dir }}/{{ item.name }}-{{ item.version }}.tar.gz"
    checksum: "{{ item.checksum | default(omit) }}"
    force: yes
    validate_certs: no
  register: get_url_result
  until: "'OK' in get_url_result.msg or 'file already exists' in get_url_result.msg"
  retries: 4
  delay: "{{ retry_stagger | random + 3 }}"
  with_items: "{{ tidb_packages }}"
  when: has_outband_network

#debug
- debug:
    msg: "run command on server: {{ disk_randread_iops.cmd }}"
```

### 2.6 变量

**1. 变量来源**

```yaml
* inventoryfile中定义
* playbook中定义
* include文件和角色中定义变量
* 系统facts  ansible hostname -m setup
* local facts
```

**2. 变量的使用**

```yaml
{{ ansible_eth0["ipv4"]["address"] }}  或者 {{ ansible_eth0.ipv4.address }}.  复杂变量可以像字典或者熟悉一样访问. 效果一样
```

**3. 本地变量**

ansible hostname -m setup 可以获取固定的系统facts,  在playbook中设置gather_fact:yes, playbook会自动获取远程机器的facts.  但是ansible也支持用户自定义facts

　　如果目标机器上有/etc/ansible/facts.d/目录, 在该目录下有.fact结尾的json ini 或者可执行并返回json过的脚本, 都可以作为本地便变量

　　例如

```yaml
/etc/ansible/facts.d/preferences.fact:

[general]
asdf=1
bar=2

使用变量  {{ ansible_local.preferences.general.asdf }}
```

**4. 魔法变量**

```yaml
* hostvars 可以让你调用其他host的变量和facts,  即使你没有在这个机器上执行过playbook, 你仍然可以访问变量, 但是不能访问facts. 例如: {{ hostvars['test.example.com']['ansible_distribution'] }}
* group_names 当前host所在的group的组名列表.   包括其父组
* groups 所有组包括组中的hosts
* inventory_hostname 配置在inventory文件中当前机器的hostname
* play_hosts 执行当前playbook的所有机器的列表
* inventory_dir inventory文件的路径
* inventory_file inventory文件的路径和文件名
* role_path 当前role的路径
```

**5.变量作用域**

```yaml
* 全局作用域:  设置在config, 环境变量, 和命令行中的变量
* play:  作用于play和包含的structure, 变量, role中的default和vars
* host:  inventory, facts和register产生的变量, 只作用于某个host
　　Note 1:  子组的变量会覆盖父组的变量,  host的变量会覆盖其组的变量
　　Note 2:  变量优先级
      roles/x/defaults/main.yml -> inventory file  ->  roles/x/vars/main.yml -> 调用role时的参数 ->  role play 中的变量 -> 执行命令-e 传入的变量.
```

**6. fact缓存**

```yaml
如果想在一个host上访问另一个host的fact 必须设置gathering setting to smart, 否则,如果你想访问另一个机器的fact, 那你必须在另外一台机器上执行过gather_fact.
　　inventory 里面声明的变量是否和上面有同样的要求, 待验证-???
```

### 2.7 Ansible使用YAML解析JSON

我正在尝试分配一个变量来匹配我正在向在线服务提供商发出的API调用中显示的IP地址.

```yaml
这是我收到的JSON数据：
TASK [manager : debug] *********************************************************
ok: [localhost] => {
    "msg": [
        {
            "address": "10.0.3.224",
            "family": "inet",
            "netmask": "24",
            "scope": "global"
        },
        {
            "address": "fe80::216:3eff:feb2:7330",
            "family": "inet6",
            "netmask": "64",
            "scope": "link"
        }
    ]
}

如何解析第一个地址输出并将其值赋给YAML中的变量
这是我试过的
- debug: msg={{ output.stdout|from_json }}

获取ip地址：
msg = {{(output.stdout | from_json | first).address}}
```

导入json

```

```



### 2.8 json字符串解析

```yaml
# replace future json.stdout variables with json_example
json_example: |
  {
      "example_simple": {
	  "name": "simple",
	  "foo": "value",
	  "item": "this"
      },
      "example_list": [
	  {
	      "name": "first",
	      "foo": "bar",
	      "item": "thud"
	  },
	  {
	      "name": "second",
	      "foo": "grunt",
	      "item": "baz"
	  }
      ]
  }
  
  在这个特定的片段中，我们希望从example_simple字典中获取名称值：
- name: Get simple value.
      set_fact:
        simple_value: "{{ (json.stdout | from_json).example_simple.name }}"
        
        
from_json过滤器允许Ansible把它当作一个变量，提取name变量的值。
一个稍微复杂一点的例子是提取字典列表中的值example_list，在本例中，获取foo值:
- name: Get foo value.
      set_fact:
        foo_value: "{{ (json.stdout | from_json).example_list | map(attribute='foo') | list }}"
        
这将返回Ansible列表。下一个调试语句也稍微复杂一些，因为它以逗号分隔的格式打印出列表：
- name: Jinja list debug, printing out the list as comma seperated.
      debug:
        msg: "{% for each in foo_value %}{{ each }}{% if not loop.last %},{% endif %}{% endfor %}"

```



## 3.ansible相关案列-Linux

### 3.1 ansible sudo自动输密码

```yaml
ansible_sudo_pass=foobar
```

### 3.2 ansible指定host文件执行临时命令

```shell
#ansible -i hosts yun -m shell -a 'ps -ef | grep httpd'
```

prometheusne.yml 

```yaml
- import_playbook: ../common/preHost.yml

- hosts: "{{ host }}"
  vars:
    ansible_ssh_private_key_file: "{{ lookup('file', '{{projectsshkeydir}}/{{host}}.keyfile', errors='ignore') }}"
    ansible_ssh_pass: "{{ lookup('file', '{{projectsshkeydir}}/{{host}}.pwd', errors='ignore') }}"
    ansible_sudo_pass: "{{ lookup('file', '{{projectsshkeydir}}/{{host}}.pwd', errors='ignore') }}"
  become: true
  gather_facts: true
  roles:
   - { role: prometheusne, tags: "prometheusne" }

- import_playbook: ../common/afterHost.yml
```

preHost.yml 处理awx处理接口传来的密钥类型，在工程目录生成

```yaml
- hosts: '127.0.0.1'
  gather_facts: False
  become: true
  vars:
    ansible_connection: local
  tasks:
  - name: check the key base dir
    file:
      path: "{{projectsshkeydir}}"
      state: directory
      mode: 01777

  - name: create ssh pem file
    file:
      path: "{{projectsshkeydir}}/{{host}}.pem"
      state: touch
      mode: 01600
#      owner: awx
#      group: awx

  - name: save ssh key
    shell: "echo -e '{{ privateKey }}' > {{projectsshkeydir}}/{{host}}.pem"
    when: (authMode is defined ) and (authMode == 'private_key') and (privateKey is defined) and (privateKey | length > 1024)

  - name: decode the key
    shell: ssh-keygen -p -P "{{privateKeyPassword}}" -N "" -f "{{projectsshkeydir}}/{{host}}.pem"
    when: (authMode is defined ) and (authMode == 'private_key') and (privateKeyPassword is defined) and (privateKeyPassword | length > 0)

  - name: check if known_hosts file exists
    stat:
      path: /root/.ssh/known_hosts
    register: known_hostsfile

  - name: remove the ssh host
    shell: ssh-keygen -R "{{ host }}"
    when: known_hostsfile.stat.exists == True

  - name: set fact for following
    set_fact:
      ansible_ssh_pass: ''
      ansible_ssh_private_key_file: "{{projectsshkeydir}}/{{host}}.pem"
    when: (authMode is defined ) and (authMode == 'private_key')

  - name: set fact for following
    set_fact:
      ansible_ssh_pass: '{{ password }}'
      ansible_ssh_private_key_file: ''
    when: (authMode is defined ) and (authMode == 'password')

  - name: export security code
    shell: "echo {{ansible_ssh_private_key_file}} > {{projectsshkeydir}}/{{host}}.keyfile && echo {{ansible_ssh_pass}} > {{projectsshkeydir}}/{{host}}.pwd"

  - name: chmod the key file
    file:
      path: "{{projectsshkeydir}}/{{host}}.keyfile"
      mode: 01777
#      owner: awx
#      group: awx

  - name: chmod the passcode file
    file:
      path: "{{projectsshkeydir}}/{{host}}.pwd"
      mode: 01777
#      owner: awx
#      group: awx
```



### 3.3 本地操作功能 --local_action

**Ansible 默认只会对控制机器执行操作，但如果在这个过程中需要在 Ansible 本机执行操作呢？细心的读者可能已经想到了，可以使用 delegate_to( 任务委派 ) 功能呀。****没错，是可以使用任务委派功能实现。不过除了任务委派之外，还可以使用另外一外功能实现，这就是 local_action 关键字。**

```yaml
- name: add host record to center server
local_action: shell 'echo "192.168.1.100 test.xyz.com " >> /etc/hosts'
```

当然您也可以使用 connection:local 方法，如下：

```yaml
- name: add host record to center server
  shell: 'echo "192.168.1.100 test.xyz.com " >> /etc/hosts'
  connection: local
```

### 3.4 覆写更改结果

有时你可以通过返回码或是输出结果来知道它们其实并没有做出任何更改.你希望覆写结果的

“changed” 状态使它不会出现在输出的报告或不会触发其他处理程序:

```yaml
tasks:

  - shell: /usr/bin/billybass --mode="take me to the river"
    register: bass_result
    changed_when: "bass_result.rc != 2"

  # this will never report 'changed' status
  - shell: wall 'beep'
    changed_when: False
```

### 3.5 根据条件判断是否执行

```yaml
- name: "查看python3是否安装，忽略提示"
  shell: python3  #执行一条命令，将结果赋值给register定义的result
  register: result
  ignore_errors: True  #忽略错误提示

#拷贝Python-3.6.5
- name: "copy Python3-6.5 to dest"
  copy: src=Python-3.6.5.tgz  dest=/usr/local/src/Python-3.6.5.tgz
  when: result is failed  #当result返回的是个错误的时候，执行此tasks

#编译安装python3.6.5
- name: "compile install"
  shell: pip install --upgrade supervisor requests;cd /usr/local/src/;tar zxf Python-3.6.5.tgz; cd Python-3.6.5;./configure --prefix=/usr/local/python3 --with-ssl;make;make install
  when: result is failed

#软连接python3
- name: "ln -s python3"
  file: src=/usr/local/python3/bin/python3  dest=/usr/bin/python3 state=link
  when: result is failed
```

### 3.6 通过代理配置环境

你完全有可能遇到一些更新包需要通过proxy才能正常获取,或者甚至一部分包需要通过proxy升级而另外一部分包则不需要通过proxy.或者可能你的某个脚本需要调用某个环境变量才能正常运行.

Ansible 使用 ‘environment’ 关键字对于环境部署的配置非常简单容易,下面是一个使用案例:

```yaml
- hosts: all
 remote_user: root

 tasks:

   - apt: name=cobbler state=installed
     environment:
       http_proxy: http://proxy.example.com:8080
       
```

environment 也可以被存储在变量中,像如下方式访问:

```yaml
- hosts: all
 remote_user: root

 # here we make a variable named "proxy_env" that is a dictionary
 vars:
   proxy_env:
     http_proxy: http://proxy.example.com:8080

 tasks:

   - apt: name=cobbler state=installed
     environment: proxy_env
```

虽然上面只展示了 proxy 设置,但其实可以同时其实支持多个设置. 大部分合合乎逻辑的地方来定义一个环境变量都可以成为 group_vars 文件,示例如下:

```yaml
---# file: group_vars/boston

ntp_server: ntp.bos.example.combackup: bak.bos.example.comproxy_env:
  http_proxy: http://proxy.bos.example.com:8080
  https_proxy: http://proxy.bos.example.com:8080
```

### 3.7 本地playbooks

或者,一个本地连接也可以作为一个单独的playbook play应用在playbook中, 即便playbook中其他的plays使用默认远程 连接如下:

```yaml
- hosts: 127.0.0.1
  connection: local
```

### 3.8 ssh配置导致Ansible并发失败

Ansible并发失败原因,  fork=100. 执行playbook时候没有并发

```yaml
vim /usr/lib/python2.7/site-packages/ansible/runner/connection_plugins/ssh.py
    ┊   if C.HOST_KEY_CHECKING and not_in_host_file:
    ┊   ┊   # lock around the initial SSH connectivity so the user prompt about whether to add
    ┊   ┊   # the host to known hosts is not intermingled with multiprocess output.
    ┊   ┊   fcntl.lockf(self.runner.process_lockfile, fcntl.LOCK_EX)
    ┊   ┊   fcntl.lockf(self.runner.output_lockfile, fcntl.LOCK_EX)
         
    ┊   # create process
    ┊   (p, stdin) = self._run(ssh_cmd, in_data)
```

以上代码可以看出, 如果ansible配置HOST_KEY_CHECKING=true. 并且要链接的机器没有在~/.ssh/known_hosts里面, 一个进程就会锁死~/.ssh/known_hosts文件. 这样ansible就不能并发.

检查自己的ssh conf. 发现"    UserKnownHostsFile /dev/null"

这样就不会有机器在~/.ssh/known_hosts中, 所以每个task都不能并发.

最终解决方案：

```yaml
host_key_checking = False 在ansible.cfg中.
```

### 3.9 Ansible playbook忽略错误继续执行

通常情况下, 当出现失败时 Ansible 会停止在宿主机上执行.有时候,你会想要继续执行下去.为此 你需要像这样编写任务:

```yaml
- name: this will not be counted as a failure
  command: /bin/false
  ignore_errors: yes


tasks:
  - command: /bin/false
    register: result
    ignore_errors: True

  - command: /bin/something
    when: result|failed

  - command: /bin/something_else
    when: result|succeeded

  - command: /bin/still/something_else
    when: result|skipped

原文：https://blog.csdn.net/Jas0n_Liu/article/details/77717649
```



```yaml
failed_when：

满足条件时，使任务失败
tasks:
  - command: echo faild.
    register: command_result
    failed_when: "'faild' in command_result.stdout"
  - debug: msg="echo test"

还可以写成这样：

  tasks:
    - command: echo faild.
      register: command_result
      ignore_errors: True
    - name: fail the echo
      fail: msg="the command failed"
      when: "'faild' in command_result.stdout"
    - debug: msg="echo test"


changed_when：
更改任务的状态
- name: Install dependencies via Composer.
  command: "/usr/local/bin/composer global require phpunit/phpunit --prefer-dist"
  register: composer
  changed_when: "'Nothing to install or update' not in composer.stdout"
```

### 3.10 Ansible Roles 安装 redis

roles目录结构

![1558935700929](D:\smeyun\doc\ansible\1558935700929.png)

redis.conf配置文件

```shell
#修改过的部分: 
1. 开启后台运行 [root@squid redis-install]# grep ^daemon redis/templates/redis.conf.j2 daemonize yes 
2. 监听端口 [root@squid redis-install]# grep ^port redis/templates/redis.conf.j2 port {{redis_port}} 
3. 修改bind绑定地址 [root@squid redis-install]# grep ^bind redis/templates/redis.conf.j2 bind {{ansible_default_ipv4.address}}
```

tasks任务文件

```yaml
[root@squid redis-install]# cat redis/tasks/main.yml
---
- name: install rpm
  yum: name={{item}} state=present
  with_items:
  - gcc
  - tcl

- name: copy redis to remote
  unarchive: src=files/{{redis_soft_name}} dest={{redis_soft_dir}} copy=yes  mode=755
- name: run script to install redis
  template: src=install.redis.sh.j2 dest={{redis_soft_dir}}/install.redis.sh  mode=755
- shell: "{{redis_soft_dir}}/install.redis.sh"
  ignore_errors: True
- name: copy redis config file to remote hosts
  template: src=redis.conf.j2 dest={{redis_install_dir}}/conf/redis.conf
- name: copy redis restart script to remote hosts
  template: src=restart_redis.sh.j2 dest={{redis_install_dir}}/restart_redis.sh mode=755
- name: start redis
  shell: "{{redis_install_dir}}/restart_redis.sh"
- name: Check Redis Running Status
  shell: "netstat -nplt|grep -E '{{redis_port}}'"
  register: runStatus
- name: display Redis Running port
  debug: msg={{runStatus.stdout_lines}}
```



### 3.11 Ansible 利用copy模块复制多个文件

今天写了一个Ansible自动化安装mysql的脚本，用copy模块复制多个文件的时候格式总是出错。错误的内容是格式不对，语法有问题。。最后通过查看文档解决了。



中文文档的循环部分的章节：<http://www.ansible.com.cn/docs/playbooks_loops.html#standard-loops>

正确写法是下面这个 (这个是roles/tasks/main.yml的一部分)

```yaml
- name: copy mysql files
  copy:
    src: '{{ item.src }}'
    dest: '{{ item.dest }}'
  with_items:
    - { src: 'mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz', dest: '/usr/local/src/MySQL5.7.tar.gz' }
    - { src: 'install.sh', dest: '/usr/local/src/install.sh' }
    - { src: 'my.cnf', dest: '/etc/my.cnf' }
    - { src: 'mysql.sh', dest: '/etc/profile.d/mysql.sh' }
```

```yaml
ansible test -m copy -a "src=test.sh dest=/root/liuhao/test"
```

### 3.12 Ansible 删除多个文件或目录

删除一个文件：

```yaml
- name: Ansible delete file example 
  file: 
    path: /etc/delete.conf 
    state: absent
```

删除多个文件：

```yaml
- name: Ansible delete multiple file example
  file:
    path: "{{ item }}"
    state: absent
  with_items:
    - hello1.txt
    - hello2.txt
    - hello3.txt
```

删除一个目录或文件夹

```yaml
- name: Ansible delete directory example
  file:
    path: removed_files
    state: absent
```

使用shell删除多个文件

```yaml
- name: Ansible delete file wildcard example
  shell: rm -rf hello*.txt
```

使用find和file模块结合linux shell模糊搜索删除文件

```yaml
- hosts: all
  tasks:
  - name: Ansible delete file glob
    find:
      paths: /etc/Ansible
      patterns: *.txt
    register: files_to_delete

  - name: Ansible remove file glob
    file:
      path: "{{ item.path }}"
      state: absent
    with_items: "{{ files_to_delete.files }}"
```

使用find和file模块结合python的正则表达式删除文件

```yaml
- hosts: all
  tasks:
  - name: Ansible delete file wildcard
    find:
      paths: /etc/wild_card/example
      patterns: "^he.*.txt"
      use:regex: true
    register: wildcard_files_to_delete

  - name: Ansible remove file wildcard
    file:
      path: "{{ item.path }}"
      state: absent
    with_items: "{{ wildcard_files_to_delete.files }}"
```

移除晚于某个日期的文件

```yaml
- hosts: all
  tasks:
  - name: Ansible delete files older than 5 days example
    find:
      paths: /Users/dnpmacpro/Documents/Ansible
      age: 5d
    register: files_to_delete

  - name: Ansible remove files older than a date example
    file:
      path: "{{ item.path }}"
      state: absent
    with_items: "{{ files_to_delete.files }}"
```

### 3.13 ansible 批量安装 Centos7&Centos6 zabbix-agent客户端

![1558936240611](D:\smeyun\doc\ansible\1558936240611.png)

```yaml
tasks:
  - name: "shutdownCentOS6andDebian7systems"
    command: /sbin/shutdown -t now
    when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
          (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")

```

### 3.14 批量创建用户

实例11：批量创建用户

首先通过以下方式生成sha-512算法密码，例如密码为xuad123456

python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"

然后创建playbook作业，生成的加密串贴到password=””里

```yaml
- hosts: web_server
  remote_user: root
  tasks:
    - name: 创建用户
      user: name={{ item }} password="$6$rounds=656000$O//XUuLIX35/oB2V$yuLC/9TUUvCBb/aCtN0N.xhjBA1ui3t0kPcK2PWP0Hp0eLuThZzx904v3ZoOhAxj/pS6GIHM4RudAzNfnGbxq0"
      with_items:
        - xiaozh
        - wangbs
        - yangdl
```

### 3.15 ansible playbook安装启动httpd服务

![1558936339507](D:\smeyun\doc\ansible\1558936339507.png)

Playbook的主要组成元素

​    Hosts: 运行指定任务的目标主机，可以是主机，也可以是主机组，支持正则表达式。 

​    Tasks: 任务列表，一个playbook配置文件中只能有一个tasks,一个tasks下可以编排多个任务。 

​    Varniables： 变量 

   Templates: 模板，使用templates可以针对不同的主机定制不同参数。 

   Handlers: 由特定条件触发的任务，监控资源改变时才会触发，需要配合notify使用。 

   Roles: Playbook的按固定目录结构组成

### 3.16 copy两个文件到远程主机的/tmp下

![1558936503545](D:\smeyun\doc\ansible\1558936503545.png)

```yaml

- name: copy file
  hosts: web_server
  remote_user: root
  tasks:
     - name: cp file
       copy: src=/etc/ansible/{{ item }} dest=/tmp
       with_items:
         - ansible.cfg
         - hosts
         
同时引用两个变量，可以按如下方式定义
 
- name: add several users
  user: name={{ item.name }} state=present groups={{ item.groups }}
  with_items:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
 
使用with_nested实现循环嵌套，按如下方式定义
注：item[0]循环alice和bob两个变量，item[1]循环clientdb、employeedb和providerdb三个变量，以下例子是实现在三个数据库上创建两个用户。
 
- name: give users access to multiple databases
  mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
  with_nested:
    - [ 'alice', 'bob' ]
    - [ 'clientdb', 'employeedb', 'providerdb' ]
 
使用with_dict实现对哈希表循环，按如下方式定义
users:
  alice:
    name: Alice Appleworth
    telephone: 123-456-7890
  bob:
    name: Bob Bananarama
    telephone: 987-654-3210
tasks:
  - name: Print phone records
    debug: msg="User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }})"
    with_dict: "{{users}}"
 
 
copy一个目录下的所有文件到远程主机上
- hosts: web_server
  remote_user: root
  tasks:
    - name: 创建目录
      file: dest=/tmp/ansible state=directory
    - name: 拷贝目录下的所有文件
      copy: src={{ item }} dest=/tmp/ansible/ owner=root mode=600
      with_fileglob:
        - /etc/ansible/*
 
使用with_together实现并行循环，一次获取多个变量
 
vars:
  alpha: [ 'a', 'b', 'c', 'd' ]
  numbers: [ 1, 2, 3, 4 ]
tasks:
  - debug: msg="{{ item.0 }} and {{ item.1 }}"
    with_together:
      - "{{alpha}}"
      - "{{numbers}}"
 
使用with_subelements实现对子元素使用循环，假设我们有一份按以下方式定义的文件
 
users:
  - name: alice
    authorized:
      - /tmp/alice/onekey.pub
      - /tmp/alice/twokey.pub
    mysql:
        password: mysql-password
        hosts:
          - "%"
          - "127.0.0.1"
          - "::1"
          - "localhost"
        privs:
          - "*.*:SELECT"
          - "DB1.*:ALL"
  - name: bob
    authorized:
      - /tmp/bob/id_rsa.pub
    mysql:
        password: other-mysql-password
        hosts:
          - "db1"
        privs:
          - "*.*:SELECT"
          - "DB2.*:ALL"
 
要获取以上文件里定义的数据，可以按以下方式引用变量
 
- user: name={{ item.name }} state=present generate_ssh_key=yes
  with_items: "{{users}}"
 
- authorized_key: "user={{ item.0.name }} key='{{ lookup('file', item.1) }}'"
  with_subelements:
     - users
     - authorized
 
以嵌套的方式获取变量，如下
 
- name: Setup MySQL users
  mysql_user: name={{ item.0.user }} password={{ item.0.mysql.password }} host={{ item.1 }} priv={{ item.0.mysql.privs | join('/') }}
  with_subelements:
    - users
- mysql.hosts
 
使用with_sequence对整数序列使用循环，如下
 
- hosts: all
 
  tasks:
 
    # create groups
    - group: name=evens state=present
    - group: name=odds state=present
 
    # create some test users
    - user: name={{ item }} state=present groups=evens
      with_sequence: start=0 end=32 format=testuser%02x
 
    # create a series of directories with even numbers for some reason
    - file: dest=/var/stuff/{{ item }} state=directory
      with_sequence: start=4 end=16 stride=2
 
    # a simpler way to use the sequence plugin
    # create 4 groups
    - group: name=group{{ item }} state=present
      with_sequence: count=4
 
 
使用with_random_choice实现随机选择一个变量
 
- debug: msg={{ item }}
  with_random_choice:
     - "go through the door"
     - "drink from the goblet"
     - "press the red button"
     - "do nothing"
 
使用Do-Until循环，实现循环执行某个任务直到指定的条件成立后停止
 
- action: shell /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
 
          
```

3.17 centos优化系列

```yaml
- name: centos6.x优化-copy base.repo
  copy: src={{ item.src }} dest={{ item.dest }} force=yes owner=root group=root mode=644
  with_items:
     - {src: "/etc/yum.repos.d/epel.repo",dest: "/etc/yum.repos.d/epel.repo"}
     - {src: "/etc/yum.repos.d/CentOS-Base.repo",dest: "/etc/yum.repos.d/CentOS-Base.repo"}
- name: 安装基础软件
  yum: name={{ item }} state=present
  with_items:
     - gcc
     - gcc-c++
     - wget
     - lrzsz
     - curl
     - nmap
     - telnet
     - iotop
     - vim
     - ntsysv
     - unzip
     - sysstat
     - ntp
- name: 关闭不需要的服务  
  shell: chkconfig --list|grep '3:on'|egrep -v 'crond|network|sshd|rsyslog'|awk '{print "chkconfig "$1 " off"}'| bash
- name: 关闭不需要的TTY
  shell: sed -i '/ACTIVE_CONSOLES/s/1-6/1-2/g' /etc/init/start-ttys.conf
- name: ntp同步
  cron: name="ntpdate" minute="10" job="/usr/sbin/ntpdate 1.cn.pool.ntp.org"
- name: 编辑时间配置文件确保时区为CST
  copy: src="/etc/sysconfig/clock" dest="/etc/sysconfig/clock"
- name: 连接时区文件
  file: src="/usr/share/zoneinfo/Asia/Shanghai" dest="/etc/localtime" state=link force=yes
- name: 修改limits.conf1
  shell: grep "* soft nofile 65535" /etc/security/limits.conf || echo '* soft nofile 65535' >>/etc/security/limits.conf
- name: 修改limits.conf2
  shell: grep "* hard nofile 65535" /etc/security/limits.conf || echo '* hard nofile 65535' >>/etc/security/limits.conf
- name: 修改文件最大句柄数
  shell: ulimit -SHn 65535
- name: 追加到启动文件
  shell: grep "ulimit -SHn 65535" /etc/rc.local || echo "ulimit -SHn 65535" >> /etc/rc.local
- name: disabled selinux
  shell: sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
- name: getenforce
  command: setenforce 0
  ignore_errors: yes
- name: disabled iptables
  command: chkconfig iptables off
- name: no service iptables
  service: name=iptables state=stopped
- name: 修改hosts
  copy: src="/etc/hosts" dest="/etc/hosts"
- name: 修改主机名
  shell: hostname=`ip addr |grep "global eth0"|awk -F '[/ ]+' '{print $3}' |xargs -i grep {} /etc/hosts |awk '{print $2}'`;grep $hostname /etc/sysconfig/network || sed -i 's/^HOSTNAME=.*/HOSTNAME='$hostname'/' /etc/sysconfig/network
- name: 优化内核参数
  copy: src="sysctl.config" dest="/tmp/sysctl.config"
- name: 同步sysctl.conf
  shell: grep -vE "#|^$" /etc/sysctl.conf > /tmp/sysctl.log;diff -w /tmp/sysctl.log /tmp/sysctl.config |sed -n '/---/,+100p'|sed '1d' |awk '{print $2" "$3" "$4" "$5}'|xargs -i echo {} >> /etc/sysctl.conf;rm -rf /tmp/sysctl.config
- name: 创建devel账号 (可以使用:openssl passwd -salt -1 "password" 生产密码 添加password选项)
  user: name=devel home=/home/devel uid=888 shell=/bin/bash
- name: 修改密码
  shell: echo "xddd@2018" | passwd --stdin devel
- name: 创建拥有root权限的账号
  user: name=sysadmin uid=999 home=/home/sysadmin shell=/bin/bash
- name: 修改sysadmin 密码
  shell: echo "xddd@2018" | passwd --stdin sysadmin

原文：https://blog.csdn.net/m0_37751813/article/details/78935488
```

### 3.17 ansible设置sysctl

```yaml
# Set vm.swappiness to 5 in /etc/sysctl.conf- sysctl:
    name: vm.swappiness
    value: 5
    state: present

# Remove kernel.panic entry from /etc/sysctl.conf- sysctl:
    name: kernel.panic
    state: absent
    sysctl_file: /etc/sysctl.conf

# Set kernel.panic to 3 in /tmp/test_sysctl.conf- sysctl:
    name: kernel.panic
    value: 3
    sysctl_file: /tmp/test_sysctl.conf
    reload: no

# Set ip forwarding on in /proc and do not reload the sysctl file- sysctl:
    name: net.ipv4.ip_forward
    value: 1
    sysctl_set: yes

# Set ip forwarding on in /proc and in the sysctl file and reload if necessary- sysctl:
    name: net.ipv4.ip_forward
    value: 1
    sysctl_set: yes
    state: present
    reload: yes
```

### 3.18 ansible判定文件或者文件夹是否存在

ansible 的常用模块中没有判定当文件存在或者不存在时，执行某个执行 使用下面方法能简单判定某个文件是否存在

```yaml
---

- name: judge a file or dir is exits
  shell: ls /home/sfy
  ignore_errors: True
  register: result

- shell: echo "file exit"
  when: result|succeeded

- shell: echo "file not exit"
  when: result|failed
```

另外一种

```yaml
#当/root/.ssh/id_rsa文件存在时，则修改该文件权限 
- command: chmod 600 /root/.ssh/id_rsa removes=/root/.ssh/id_rsa
```

### 3.19 ansible进行iptables管理-防火墙管理

简单防火墙管理：

![1558936766479](D:\smeyun\doc\ansible\1558936766479.png)

```yaml
- name: start firewalld
  service:
    name: firewalld
    state: started

- name: set firewalld rule
  firewalld:
    port: "{{item}}/tcp"
    zone: public
    permanent: yes
    state: enabled
    immediate: yes
  with_item:
    - 80
    - 443
    - 8080
- name: reload firewalld
  service:
    name: firewalld
    state: reloaded


- firewalld:
    service: https
    permanent: true
    state: enabled

- firewalld:
    port: 8081/tcp
    permanent: true
    state: disabled

- firewalld:
    port: 161-162/udp
    permanent: true
    state: enabled

- firewalld:
    zone: dmz
    service: http
    permanent: true
    state: enabled

- firewalld:
    rich_rule: 'rule service name="ftp" audit limit value="1/m" accept'
    permanent: true
    state: enabled

- firewalld:
    source: 192.0.2.0/24
    zone: internal
    state: enabled

- firewalld:
    zone: trusted
    interface: eth2
    permanent: true
    state: enabled

- firewalld:
    masquerade: yes
    state: enabled
    permanent: true
    zone: dmz
```

普通iptables

```yaml
- name: Check if port 80 is allowed
  shell: iptables -L | grep -q "Allow http" && echo -n yes || echo -n no
  register: check_allow_http
  changed_when: no
  always_run: yes

- name: Allow port 80
  command: >
    iptables -A INPUT -p tcp -m tcp --dport 80
    -m comment --comment "Allow http" -j ACCEPT
  when: check_allow_http.stdout == "no"
  notify:
  - Save iptables
```

### 3.20 修改ssh端口和limits参数控制

ansible-playbook之修改ssh端口和limits参数控制：

```yaml
---
    - hosts: "{{ host }}"
      remote_user: "{{ user }}"
      gather_facts: false
      tasks:
          - name: Modify ssh port 69410
            lineinfile:
                dest: /etc/ssh/{{ item }}
                regexp: '^Port 69410'
                insertafter: '#Port 22'
                line: 'Port 69410'
            with_items:
                - sshd_config
                - ssh_config
            tags:
                - sshport
          - name: Set sysctl file limiits
#            pam_limits: domain='*' limit_type=`item`.`limit_type` limit_item=`item`.`limit_item` value=`item`.`value`
            pam_limits:
                dest: "{{ item.dest }}"
                domain: '*'
                limit_type: "{{ item.limit_type }}"
                limit_item: "{{ item.limit_item }}"
                value: "{{ item.value }}"
            with_items:
                - { dest: '/etc/security/limits.conf',limit_type: 'soft',limit_item: 'nofile', value: '655350' }
                - { dest: '/etc/security/limits.conf',limit_type: 'hard',limit_item: 'nofile', value: '655350'}
                - { dest: '/etc/security/limits.conf',limit_type: 'soft',limit_item: 'nproc', value: '102400' }
                - { dest: '/etc/security/limits.conf',limit_type: 'hard',limit_item: 'nproc', value: '102400' }
                - { dest: '/etc/security/limits.conf',limit_type: 'soft',limit_item: 'sigpending', value: '255377' }
                - { dest: '/etc/security/limits.conf',limit_type: 'hard',limit_item: 'sigpending', value: '255377' }
                - { dest: '/etc/security/limits.d/90-nproc.conf', limit_type: 'soft',limit_item: 'nproc', value: '262144' }
                - { dest: '/etc/security/limits.d/90-nproc.conf', limit_type: 'hard',limit_item: 'nproc', value: '262144' }
            tags:
                - setlimits
```

### 3.21 通过传值传入模版

```yaml
- name: get api config file
  copy: dest={{ item.dest }} content={{ item.content }}
  with_items:
  	- { dest:"{{ ops_agent_file }}"},content: "{{ filecontent }}"
  when:
  	- filecontent is defined
```

### 3.22 利用callback返回脚本执行实际返回结果

1.首先修改ansible



1.1.1  下面是AWX中的环境配置 RESOURCES --> Inventories --> VARIABLES 中设置固定参数

```cfg
deprecation_warning: False
bin_ansible_callbacks: true
callback_plugins: human_log 
stdout_callback: human_log
```

1. 1.2 ADMINSTRATION--> Settings --> ANSIBLE CALLBACK PLUGINS

```YAML
/var/lib/awx/projects/runcommand/callback_plugins
```

1.2.1 修改ansible.cfg文件

```cfg
callback_whitelist = human_log 
callback_plugins   = /etc/ansible/callback_plugins
bin_ansible_callbacks = True
deprecation_warnings=False
```

2. callback脚本,ansible 2.0版本

```python
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Inspired from: https://github.com/redhat-openstack/khaleesi/blob/master/plugins/callbacks/human_log.py
# Further improved support Ansible up to 2.6

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

try:
    import simplejson as json
except ImportError:
    import json

# Fields to reformat output for
# FIELDS = ['cmd', 'command', 'start', 'end', 'delta', 'msg', 'stdout', 'stderr', 'results']

FIELDS = ['command', 'msg', 'stdout', 'stderr', 'results']

class CallbackModule(object):

    """
    Ansible callback plugin for human-readable result logging
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'human_log'
    CALLBACK_NEEDS_WHITELIST = False

    def human_log(self, data):
        #print(data.__dict__)

        adata = data._result
        if type(adata) == dict:
            
            for field in FIELDS:
                no_log = adata.get('_ansible_no_log')
                if field in adata.keys() and adata[field] and no_log != True:
                    output = self._format_output(adata[field])
                    #print("{1}".format(field, output.replace("\\n","\n")),"\n")
        
            hos = {'host':str(data._host)}
            resput = {'log': output} 
            datas = dict(hos,**resput)
        datas=json.dumps(datas)
        print(datas)

    def _format_output(self, output):
        # Strip unicode
        if type(output) == unicode:
            output = output.encode(sys.getdefaultencoding(), 'replace')

        # If output is a dict
        if type(output) == dict:
            return json.dumps(output, indent=2)

        # If output is a list of dicts
        if type(output) == list and type(output[0]) == dict:
            # This gets a little complicated because it potentially means
            # nested results, usually because of with_items.
            real_output = list()
            for index, item in enumerate(output):
                copy = item
                if type(item) == dict:
                    for field in FIELDS:
                        if field in item.keys():
                            copy[field] = self._format_output(item[field])
                real_output.append(copy)
            return json.dumps(output, indent=2)

        # If output is a list of strings
        if type(output) == list and type(output[0]) != dict:
            # Strip newline characters
            real_output = list()
            for item in output:
                if "\n" in item:
                    for string in item.split("\n"):
                        real_output.append(string)
                else:
                    real_output.append(item)

            # Reformat lists with line breaks only if the total length is
            # >75 chars
            if len("".join(real_output)) > 75:
                return "\n" + "\n".join(real_output)
            else:
                return " ".join(real_output)

        # Otherwise it's a string, (or an int, float, etc.) just return it
        return str(output)


    ####### V2 METHODS ######
    def v2_on_any(self, *args, **kwargs):
        pass

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self.human_log(result)

    def v2_runner_on_ok(self, result):

        self.human_log(result)

    def v2_runner_on_skipped(self, result):
        pass

    def v2_runner_on_unreachable(self, result):
        self.human_log(result)

    def v2_runner_on_no_hosts(self, task):
        pass

    def v2_runner_on_async_poll(self, result):
        self.human_log(result)

    def v2_runner_on_async_ok(self, host, result):
        self.human_log(result)

    def v2_runner_on_async_failed(self, result):
        self.human_log(result)

    def v2_playbook_on_start(self, playbook):
        pass

    def v2_playbook_on_notify(self, result, handler):
        pass

    def v2_playbook_on_no_hosts_matched(self):
        pass

    def v2_playbook_on_no_hosts_remaining(self):
        pass

    def v2_playbook_on_task_start(self, task, is_conditional):
        pass

    def v2_playbook_on_vars_prompt(self, varname, private=True, prompt=None,
                                   encrypt=None, confirm=False, salt_size=None,
                                   salt=None, default=None):
        pass

    def v2_playbook_on_setup(self):
        pass

    def v2_playbook_on_import_for_host(self, result, imported_file):
        pass

    def v2_playbook_on_not_import_for_host(self, result, missing_file):
        pass

    def v2_playbook_on_play_start(self, play):
        pass

    def v2_playbook_on_stats(self, stats):
        pass

    def v2_on_file_diff(self, result):
        pass

    def v2_playbook_on_item_ok(self, result):
        pass

    def v2_playbook_on_item_failed(self, result):
        pass

    def v2_playbook_on_item_skipped(self, result):
        pass

    def v2_playbook_on_include(self, included_file):
        pass

    def v2_playbook_item_on_ok(self, result):
        pass

    def v2_playbook_item_on_failed(self, result):
        pass

    def v2_playbook_item_on_skipped(self, result):
        pass

```

test.yaml 

```yaml
---
- hosts: mydev 

  tasks:
   - debug: msg="hello"
  
   - name: check ls 
     shell: sh /tmp/test.sh
```

上文返回结果为：

```shell
#ansible-playbook test.yaml 

PLAY [mydev] ****************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************************************************
ok: [172.168.1.136]
 [WARNING]: Failure using method (v2_runner_on_ok) in callback plugin (<ansible.plugins.callback./etc/ansible/callback_plugins/human_log.CallbackModule object at 0x7f2d9dea4e90>): local variable 'output' referenced before assignment

ok: [172.168.1.144]

TASK [debug] ****************************************************************************************************************************************************************************************************************************
ok: [172.168.1.136] => {
    "msg": "hello"
}
{"host": "172.168.1.136", "log": "hello"}
ok: [172.168.1.144] => {
    "msg": "hello"
}
{"host": "172.168.1.144", "log": "hello"}

TASK [check ls] *************************************************************************************************************************************************************************************************************************
changed: [172.168.1.144]
{"host": "172.168.1.144", "log": "222222222222"}
changed: [172.168.1.136]
{"host": "172.168.1.136", "log": "111111111"}

PLAY RECAP ******************************************************************************************************************************************************************************************************************************
172.168.1.136              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
172.168.1.144              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```



***优化版本***

```python
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os,sys
import urllib2
reload(sys)
sys.setdefaultencoding('utf-8')

try:
    import simplejson as json
except ImportError:
    import json


class CallbackModule(object):

    """
    Ansible callback plugin for human-readable result logging
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'human_log'
    CALLBACK_NEEDS_WHITELIST = False
    runcommand_id=''
    awx_job_id=''
    API_URL=""
    

    ####### V2 METHODS ######

    def v2_runner_on_failed(self, result, ignore_errors=False):
        data = result
        if 'rc' in data._result.keys() and data._result['stderr']:
            time_str = self.Conf_time(str(data._result['delta']))

            out_data={'hostIp':str(data._host),'resultCode':str(data._result['rc']),'execDuration':str(time_str),'logContent': str(data._result['stderr'])}
            self.human_log(out_data)

    def v2_runner_on_ok(self, result):
        data = result
        if 'rc' in data._result.keys() and data._result['stdout']:
            time_str = self.Conf_time(str(data._result['delta']))
            out_data={'hostIp':str(data._host),'resultCode':str(data._result['rc']),'execDuration':str(time_str),'logContent': str(data._result['stdout'])}
            self.human_log(out_data)


    def v2_playbook_on_start(self, playbook):
        

        taskdata = playbook._loader.__dict__['_FILE_CACHE']

        dict1=json.dumps(taskdata)
        jss = json.loads(dict1)
        
        for i in jss.values():
            if type(i) == dict:
                if i.get('runcommand_id'):
                    self.runcommand_id = i.get('runcommand_id')
                if i.get('awx_job_id'):                    
                    self.awx_job_id = i.get('awx_job_id')
                if i.get('api_url'):
                    self.API_URL =  i.get('api_url')        
        #print(self.runcommand_id) 

    def v2_runner_on_unreachable(self, result):
        data = result 
        out_data={'hostIp':str(data._host),'resultCode':"5",,'execDuration':"0",'logContent': str(data._result['msg'])}
        self.human_log(out_data)

    def Conf_time(self,time_str):
        line = time_str.split(":")
        sec_line = line[2].split(".")
        seconds = int(line[0])*3600000 + int(line[1])*60000 + int(sec_line[0])*1000 + int(sec_line[1])/1000
        return int(seconds) 

    def human_log(self,out_data, **kwargs):

        data = dict(out_data,**{'nodeLogId':str(self.runcommand_id),'awxId':str(self.awx_job_id)})
        if self.API_URL:
        
            headers = {'Content-Type': 'application/json'}
            request = urllib2.Request(url=self.API_URL, headers=headers, data=json.dumps(data))
            response = urllib2.urlopen(request)
        print(data)
```



### 3.23 给不同IP分配不同参数

需求：给不同IP分配不同参数，笔者需要给3个zookeeper节点分配不同的myid

有myid1 myid2 myid3 有191-193 三台服务器,用什么方法可以在playbook中,将myid1 发送到191,myid2发送到192,myid3发送到193

```yaml
myid{{ ansible_play_hosts.index(inventory_hostname) + 1 }}
```



### 3.24 设置任务超时时间，和默认值



```yaml
---

- hosts: all
  remote_user: root

  tasks:

  - name: simulate long running op (15 sec), wait for up to 45 sec, poll every 5 sec
    command: /bin/sleep 15
    async: 45
    #async: "{{ timeout:300 }}"
    poll: 5
```

 

***设置timeout 默认值为300秒***

```yaml
#async: "{{ timeout:300 }}"
```

如果您想异步执行任务并在以后检查它，则可以执行类似于以下的任务：

```yaml
---
# Requires ansible 1.8+
- name: 'YUM - async task'
  yum:
    name: docker-io
    state: present
  async: 1000
  poll: 0
  register: yum_sleeper

- name: 'YUM - check on async task'
  async_status:
    jid: "{{ yum_sleeper.ansible_job_id }}"
  register: job_result
  until: job_result.finished
  retries: 30
```

如果要在限制并发运行的任务量的同时运行多个异步任务，可以这样做：

```yaml
#####################
# main.yml
#####################
- name: Run items asynchronously in batch of two items
  vars:
    sleep_durations:
      - 1
      - 2
      - 3
      - 4
      - 5
    durations: "{{ item }}"
  include_tasks: execute_batch.yml
  loop: "{{ sleep_durations | batch(2) | list }}"

#####################
# execute_batch.yml
#####################
- name: Async sleeping for batched_items
  command: sleep {{ async_item }}
  async: 45
  poll: 0
  loop: "{{ durations }}"
  loop_control:
    loop_var: "async_item"
  register: async_results

- name: Check sync status
  async_status:
    jid: "{{ async_result_item.ansible_job_id }}"
  loop: "{{ async_results.results }}"
  loop_control:
    loop_var: "async_result_item"
  register: async_poll_results
  until: async_poll_results.finished
  retries: 30
```



### 3.25 利用公钥私钥实现文件传输

- 解决思路利用公钥私钥，生成传输专用key

  

```yaml
---
- name: delete add a line
  lineinfile:
    dest: ~/.ssh/authorized_keys
    state: absent
    regexp: 'public' 
  #ignore_errors: yes
  tags:
   - delete_key

- name: in key to remote
  shell: mkdir -p ~/.ssh;chmod 700 ~/.ssh ;echo {{ pubkey }} >> ~/.ssh/authorized_keys;chmod 600 ~/.ssh/authorized_keys
  delegate_to: 172.168.1.145
  #ignore_errors: yes
  tags:
   - in_key

- name: copy key file
  template:
    src: tokenkey.j2
    dest: /tmp/tokenkey
    mode: 0600
  #ignore_errors: yes
  tags:
   - copy_key

- name: pass file
  shell: rsync -Pav -e "ssh -o StrictHostKeyChecking=no -i /tmp/tokenkey" test@172.168.1.145:/home/test/mongodb-linux-x86_64-4.0.0.tgz /home/test/
  delegate_to: 172.168.1.144
  #ignore_errors: yes
  tags:
   - pass_file

- name: remove file
  shell: rm -rf /tmp/tokenkey
  #ignore_errors: yes
  tags:
   - rm_key

- name: delete add a line
  lineinfile:
    dest: ~/.ssh/authorized_keys
    state: absent
    regexp: 'public'
  #ignore_errors: yes
  tags:
   - delete_key
```

### 3.26 通过Ansible将Json发布到API

```yaml
My body_content.json:
{
  apiKey: '{{ KEY_FROM_VARS }}',
  data1: 'foo',
  data2: 'bar'
}


# Create an item via API
- uri: 
    url: "http://www.myapi.com/create"
    method: POST
    return_content: yes
    HEADER_Content-Type: "application/json"
    body: "{{ lookup('file','create_body.json') | to_json }}"
    
    
我发布的内容低于我最终用于我的用例（Ansible 2.0）。如果您的json有效内容是内联（而不是文件），则此选项很有用。
此任务期望204作为其成功返回代码。由于body_format是json，因此会自动推断头部

- name: add user to virtual host
  uri: 
    url: http://0.0.0.0:15672/api/permissions/{{ rabbit_virtualhost }}/{{ rabbit_username }}
    method: PUT
    user: "{{ rabbit_username }}"
    password: "{{ rabbit_password }}"
    return_content: yes
    body: {"configure":".*","write":".*","read":".*"}
    body_format: json
    status_code: 204
    
它基本上相当于：
curl -i -u user:pass -H "content-type:application/json" -XPUT http://0.0.0.0:15672/api/permissions/my_vhost/my_user -d '{"configure":".*","write":".*","read":".*"}'
```

***ansible playbook执行curl -X***

```yaml
我想使用ansible playbook执行下一个命令：
curl -X POST -d@mesos-consul.json -H "Content-Type: application/json" http://marathon.service.consul:8080/v2/apps

最好的方法是使用 URI模块：
tasks:
- name: post to consul
  uri:
    url: http://marathon.service.consul:8080/v2/apps/
    method: POST
    body: "{{ lookup('file','mesos-consul.json') }}"
    body_format: json
    headers:
      Content-Type: "application/json"

由于您的json文件位于远程计算机上，因此最简单的执行方法可能是使用shell模块：
- name: post to consul
  shell: 'curl -X POST -d@/full/path/to/mesos-consul.json -H "Content-Type: application/json" http://marathon.service.consul:8080/v2/apps'
```

### 3.27 通过“vars_files”或“group_vars/all”文件加载变量

假设您想对一组用户进行循环，创建他们，并允许他们通过一组SSH密钥登录。

在本例中，我们假设您定义了以下内容并通过“vars_files”或“group_vars/all”文件加载:

```yaml
---
users:
  - name: alice
    authorized:
      - /tmp/alice/onekey.pub
      - /tmp/alice/twokey.pub
    mysql:
        password: mysql-password
        hosts:
          - "%"
          - "127.0.0.1"
          - "::1"
          - "localhost"
        privs:
          - "*.*:SELECT"
          - "DB1.*:ALL"
  - name: bob
    authorized:
      - /tmp/bob/id_rsa.pub
    mysql:
        password: other-mysql-password
        hosts:
          - "db1"
        privs:
          - "*.*:SELECT"
          - "DB2.*:ALL"
```

你可以循环遍历这些子元素，如下所示

```yaml
- name: Create User
  user:
    name: "{{ item.name }}"
    state: present
    generate_ssh_key: yes
  with_items:
    - "{{ users }}"

- name: Set authorized ssh key
  authorized_key:
    user: "{{ item.0.name }}"
    key: "{{ lookup('file', item.1) }}"
  with_subelements:
     - "{{ users }}"
     - authorized
```

给定mysql主机和privs子键列表，您还可以迭代嵌套子项中的列表：

```yaml
- name: Setup MySQL users
  mysql_user:
    name: "{{ item.0.name }}"
    password: "{{ item.0.mysql.password }}"
    host: "{{ item.1 }}"
    priv: "{{ item.0.mysql.privs | join('/') }}"
  with_subelements:
    - "{{ users }}"
    - mysql.hosts
```

### 3.28 ansible安装mysql案列

https://github.com/geerlingguy/ansible-role-mysql

### 3.29 ansible分发文件

笔者接到需求，awx任务接收json,执行任务，执行完成通过callback组件返回执行结果，但是结果需要的是多步结果

main.yml

```yaml
---
- include_tasks: addkey.yml
- include_tasks: sync.yml
- include_tasks: local.yml 
- include_tasks: delkey.yml
```

addkey.yml

```yaml
---
- name: create script 
  template:
    src: inkey.j2
    dest: /var/lib/awx/projects/filetransfer/tmp/{{ node_log_id }}_inkey    
  delegate_to: 127.0.0.1

- name: run script
  shell: sh /var/lib/awx/projects/filetransfer/tmp/{{ node_log_id }}_inkey     
  delegate_to: 127.0.0.1
  ignore_errors: yes
  register: msss

- name: copy token
  template:
    src: tokenkey.j2
    dest: /tmp/tokenkey
    mode: 0600
  delegate_to: "{{ host }}"
```

delkey.yml

```yaml
---
- name: remove token file
  file:
    path: "{{ item }}"
    state: absent 
  delegate_to: "{{ host }}"
  with_items:
    - "/tmp/tokenkey"
    - "/tmp/{{ node_log_id }}"

- name: create script 
  template:
    src: removekey.j2
    dest: /var/lib/awx/projects/filetransfer/tmp/{{ node_log_id }}_remove    
  delegate_to: 127.0.0.1

- name: run script
  shell: sh /var/lib/awx/projects/filetransfer/tmp/{{ node_log_id }}_remove
  delegate_to: 127.0.0.1 

- name: del script
  shell: |
    rm -rf /var/lib/awx/projects/filetransfer/tmp/*
    rm -rf /var/lib/awx/projects/filetransfer/file/*
  delegate_to: 127.0.0.1
```

sync.yml

```yaml
---
- name: create sync script
  template:
    src: sync.j2
    dest: /tmp/{{ node_log_id }}
    mode: 0755
  delegate_to: "{{ host }}"
  ignore_errors: yes

- name: run script
  shell: sh /tmp/{{ node_log_id }}
  ignore_errors: yes
  async: 10
  register: script_in

#- debug: msg="{{ script_in }}"
```

local.yml

```yaml
---
- name: create local script
  template:
    src: sync_loca.j2
    dest: /var/lib/awx/projects/filetransfer/tmp/{{ node_log_id }}_local
  ignore_errors: yes
  delegate_to: 127.0.0.1    

- name: get file in dfs
  shell: sh /var/lib/awx/projects/filetransfer/tmp/{{ node_log_id }}_local
  ignore_errors: yes
  delegate_to: 127.0.0.1

- name: create dir
  file:
    path: "{{ target_path }}"
    state: directory
  ignore_errors: yes

- name: put remote
  copy: 
    src: /var/lib/awx/projects/filetransfer/file/ 
    dest: "{{ target_path }}"
  register: script_in2
  ignore_errors: yes

- name: check file
  shell: ls -l "{{ target_path }}"
  ignore_errors: yes 
  register: check_file
    

- debug: msg="{{ msss }},{{ script_in }},{{ script_in2 }},{{ check_file }}"
  ignore_errors: yes

#script_in msg={{ script_in }}{{ check_file }}

```



templates:

inkey.j2

```jinja2
{% for item in jobNodeFileDTOList  %}
{% if item.sourceType == "REMOTE_SERVER"  %}
{% if item.sourceFileList %}
{% for sourceitem in item.sourceFileList  %} 
sshpass -p {{ item.sourceLaunchVarBase.password }} ssh -o StrictHostKeyChecking=no {{ item.sourceLaunchVarBase.username }}@{{ item.sourceLaunchVarBase.host }} 'mkdir -p ~/.ssh;chmod 700 ~/.ssh;echo {{ pubkey }} >> ~/.ssh/authorized_keys;chmod 600 ~/.ssh/authorized_keys'
{% endfor %}
{% endif %}
{% endif %}
{% endfor %}
```

removekey.j2

```jinja2
{% for item in jobNodeFileDTOList  %}
{% if item.sourceType == "REMOTE_SERVER"  %}
sshpass -p {{ item.sourceLaunchVarBase.password }} ssh -o StrictHostKeyChecking=no {{ item.sourceLaunchVarBase.username }}@{{ item.sourceLaunchVarBase.host }} 'sed -i '/public/d' 
{% endif %}
{% endfor %}
```

sync.jrsync相关cmd：

***sshpass -d12 /usr/bin/rsync --delay-updates -F --compress --delete-after --archive '--rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' '--out-format=<<CHANGED>>%i %n%L' /root/aqpay ' '"***

```jinja2
#!/bin/bash

{% for item in jobNodeFileDTOList  %}
 {% if item.sourceType == "REMOTE_SERVER"  %}
 {% if item.sourceFileList %}
 {% for sourceitem in item.sourceFileList  %} 
 rsync -Pav -e "ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/tokenkey" {{ item.sourceLaunchVarBase.username }}@{{ item.sourceLaunchVarBase.host }}:{{ sourceitem }} {{ target_path }}
 {% endfor %}
 {% endif %}
 {% if item.sourceDirList  %}     
 {% for sourcediritem in item.sourceDirList  %}   
 rsync -Pav -e "ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /tmp/tokenkey" {{ item.sourceLaunchVarBase.username }}@{{ item.sourceLaunchVarBase.host }}:{{ sourcediritem }} {{ target_path }}
 {% endfor %}
 {% endif %}
{% endif %}
{% endfor %}

```

sync_local.j2

```jinja2
{% for item in jobNodeFileDTOList  %}
{% if item.sourceType == "LOCAL"  %}
/usr/bin/fdfs_download_file /etc/fdfs/client.conf {{ item.annexUrl }} /var/lib/awx/projects/filetransfer/file/{{ item.fileName }} 
{% endif %}
{% endfor %}
```

tokenkey.j2  私钥文件



callback_plugins文件：

```python
#coding=utf-8

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os,sys
import urllib2
import logging

reload(sys)
sys.setdefaultencoding('utf-8')

try:
    import simplejson as json
except ImportError:
    import json

#INFO DEBUG WARNING 
logging.basicConfig(level=logging.WARNING,
                    filename='output.log',
                    datefmt='%Y/%m/%d %H:%M:%S',
                    #format='%(asctime)s - %(name)s - %(levelname)s - %(lineno)d -%(module)s - %(message)s')
                    format='%(asctime)s -human_log- %(levelname)s - %(lineno)d -%(module)s - %(message)s')
logger = logging.getLogger(__name__)


class CallbackModule(object):

    """
    Ansible callback plugin for human-readable result logging
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'sync_log'
    CALLBACK_NEEDS_WHITELIST = False
    runcommand_id=''
    awx_job_id=''
    API_URL=""
    std_res=""
    std_times= 0
    std_rc= 0

    ####### V2 METHODS ######

    def v2_runner_on_ok(self, result):
        data = result
        #print(data._result)
        if str(data._host) != "127.0.0.1":
            logger.debug("v2_runner_on_ok: %s"%data._host)
            logger.info("v2_runner_on_ok.data.__dict__: %s"%data.__dict__)
            
            if str(data._task) == "TASK: filetransfer : debug":
                debug_result = data._result
                
                for key,value in debug_result.items():
                    if key == "msg":
                        for res_tun in value:
                            for k,v in res_tun.items():
                                
                                #累加str结果
                                if k == "stderr" or k == "stdout" : 
                                    if v:
                                        self.std_res += "%s\n\n"%v
								#累加rc结果
                                if k == "rc":
                                    if v:
                                        self.std_rc += v
								#累加时间并计算
                                if k == "delta":
                                    if v:
                                        self.std_times += self.Conf_time(v)
                                #拼接输出结果
                                out_data={"hostIp":str(data._host),"resultCode":str(self.std_rc),"execDuration":str(self.std_times),"logContent": str(self.std_res)}
                
                        logger.debug("v2_runner_on_ok.out_data: %s"%out_data)
                        self.human_log(out_data)


    def v2_playbook_on_start(self, playbook):

        taskdata = playbook._loader.__dict__['_FILE_CACHE']
        dict1=json.dumps(taskdata)
        jss = json.loads(dict1)
        
        logger.info("v2_playbook_on_start.taskdata: %s"%taskdata) 
       # print(taskdata) 
        for i in jss.values():            
            if type(i) == dict:
                if i.get('awx_job_template_name'):
                    self.runcommand_id = i.get('node_log_id')
                    self.awx_job_id = i.get('awx_job_id')
                    self.API_URL = i.get('api_url')
        
    def Conf_time(self,time_str):
        line = time_str.split(":")
        sec_line = line[2].split(".")
        seconds = int(line[0])*3600000 + int(line[1])*60000 + int(sec_line[0])*1000 + int(sec_line[1])/1000
        return int(seconds) 

    def human_log(self,out_data, **kwargs):
        #print(out_data)
                        
        res_data = dict(out_data,**{"nodeLogId":str(self.runcommand_id),"awxId":str(self.awx_job_id)})
        logger.warning("human_log.data: %s"%res_data) 
                
        if self.API_URL:   
            headers = {'Content-Type': 'application/json'}
            request = urllib2.Request(url=self.API_URL, headers=headers, data=json.dumps(res_data))
            logger.warning("human_log.data: %s"%res_data)
        try:
            # pass
            response = urllib2.urlopen(request)
        except urllib2.HTTPError as e: 
            logger.warning("human_log.HTTPError: %s"%e)

```

### 3.30 yum 

```yaml
- name: 安装最新版本的apache
  yum: name=httpd state=latest

- name: 移除apache
  yum: name=httpd state=absent

- name: 安装一个特殊版本的apache
  yum: name=httpd-2.2.29-1.4.amzn1 state=present

- name: 升级所有的软件包
  yum: name=* state=latest

- name: 从一个远程yum仓库安装nginx
  yum: name=http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm state=present

- name: 从本地仓库安装nginx
  yum: name=/usr/local/src/nginx-release-centos-6-0.el6.ngx.noarch.rpm state=present

- name: 安装整个Development tools相关的软件包
  yum: name="@Development tools" state=present
  
  - name: install the latest version of Apache
  yum:
    name: httpd
    state: latest

- name: ensure a list of packages installed
  yum:
    name: "{{ packages }}"
  vars:
    packages:
    - httpd
    - httpd-tools

- name: remove the Apache package
  yum:
    name: httpd
    state: absent

- name: install the latest version of Apache from the testing repo
  yum:
    name: httpd
    enablerepo: testing
    state: present

- name: install one specific version of Apache
  yum:
    name: httpd-2.2.29-1.4.amzn1
    state: present

- name: upgrade all packages
  yum:
    name: '*'
    state: latest

- name: upgrade all packages, excluding kernel & foo related packages
  yum:
    name: '*'
    state: latest
    exclude: kernel*,foo*

- name: install the nginx rpm from a remote repo
  yum:
    name: http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: present

- name: install nginx rpm from a local file
  yum:
    name: /usr/local/src/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    state: present

- name: install the 'Development tools' package group
  yum:
    name: "@Development tools"
    state: present

- name: install the 'Gnome desktop' environment group
  yum:
    name: "@^gnome-desktop-environment"
    state: present

- name: List ansible packages and register result to print with debug later.
  yum:
    list: ansible
  register: result

- name: Install package with multiple repos enabled
  yum:
    name: sos
    enablerepo: "epel,ol7_latest"

- name: Install package with multiple repos disabled
  yum:
    name: sos
    disablerepo: "epel,ol7_latest"

- name: Install a list of packages
  yum:
    name:
      - nginx
      - postgresql
      - postgresql-server
    state: present

- name: Download the nginx package but do not install it
  yum:
    name:
      - nginx
    state: latest
    download_only: true

```

### 3.31 检测端口

利用wait_for检查端口是否使用

```
- name: Check all port numbers are accessible from current host
  wait_for:
    host: mywebserver.com
    port: "{{ item }}"
    state: started         # Port should be open
    delay: 0               # No wait before first check (sec)
    timeout: 3             # Stop checking after timeout (sec)
  ignore_errors: yes
  with_items:
    - 443
    - 80
    - 80443
    
    
    
- name: Wait 300 seconds for port 8000 of any IP to close active connections, don't start checking for 10 seconds
  wait_for:
    host: 0.0.0.0
    port: 8000
    delay: 10
    state: drained
```



## 4. ansible相关案列-Windows

### 4.1 Ansible 监控windows2008

1.安装pywinrm(ansible控制机器)

Pip install pywinrm

 

2.windows上安装python2.7.5 setuptools pip  (windows)

配置pip的，按照官方说明文档，它的配置文件应该放在%APPDATA%/pip/目录下，配置文件名称是pip.ini，我们先按下win+R键。或者在开始菜单上点右键，点运行。然后在出来的窗口中输入%APPDATA%，然后点击确定。

 

3.设置环境变量C:\Python27\Scripts; C:\Python27\，安装pywinrm (windows)

 

4.配置windows

4.1 升级到.net 3.0以上

4.2 升级到powershell 3.0以上

执行$host和$psversiontable查看版本，ps是$host的Version，.net是$psveriontable的CLRVersion

 

4.3 更改powershell策略为remotesigned

set-executionpolicy remotesigned

![1558937021055](D:\smeyun\doc\ansible\1558937021055.png)

 4) 下载并运行https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1

​        5) 在powershell中执行winrm qc启动winrm

​        6) 在cmd中执行  

​            \> winrm set winrm/config/service '@{AllowUnencrypted="true"}'

​            \> winrm set winrm/config/service/auth '@{Basic="true"}'

 ![1558937050045](D:\smeyun\doc\ansible\1558937050045.png)

4、修改ansible服务端

​        1) 修改默认得到Inventory /etc/ansible/hosts，添加

​            [windows]

​            192.168.56.101 ansible_ssh_user="Administrator" ansible_ssh_pass="geely@2018" ansible_ssh_port=5985 ansible_connection="winrm" ansible_winrm_server_cert_validation=ignore

​        2) 测试：

​                ansible 192.168.56.101 -m win_ping

 

```powershell
\# 测试ping通信

ansible windows -m win_ping

\# 查看ip地址

ansible windows -m win_command -a "ipconfig" 

ansible windows -m win_shell -a "mkdir c:/111/;dir"
```

 

配置winrm服务

Windows上winrm服务默认是未启用的，使用如下命令可以查看状态

 winrm enumerate winrm/config/listener

 

使用如下命令配置winrm服务

```powershell
\> winrm quickconfig

\> winrm set winrm/config/service/auth '@{Basic="true"}'

\> winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```



 

至此，windows主机的配置就完成了，接下来我们配置linux管理节点进行验证。

 

![1558937071758](D:\smeyun\doc\ansible\1558937071758.png)

参考：<https://docs.ansible.com/ansible/latest/modules/list_of_windows_modules.html>

### 4.2 awx (Ansible Tower) 管理windows

一些包可能需要一个交互式用户登录进行安装。通过正确的凭证,您可以使用成为实现这一目标。下面的例子显示了一个安装包,需要使用。注意,您可以成为:系统,它不需要你提供一个密码。

msi和win_package模块：

```yaml
- name: Install Visual C thingy with list of arguments instead of a string
  win_package:
    path:
http://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe
    product_id: '{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}'
    arguments:
    - /install
    - /passive
    - /norestart
```

上图中,我们看到产品ID列。虽然Ansible可以并提取ID从MSI的地方,我们不想迫使主机下载MSI如果它不是必要的。当你供应产品ID,Ansible可以快速检查包已经安装没有从网上下载一个潜在的巨大的MSI第一。你可以安装产品ID。可以找到这样的一个示例如下:

```yaml
- name: Install Remote Desktop Connection Manager locally omitting the product_id
  win_package:
    path: C:\temp\rdcman.msi
    state: present
```

如前所述,您还可以下载从网络共享文件,并指定所需的凭证访问共享。下面的例子展示了它的实际效果,安装7 - zip从网络资源:

```yaml
- name: Install 7zip from a network share specifying the credentials
  win_package:
    path: \\domain\programs\7z.exe
    product_id: 7-Zip
    arguments: /S
    state: present
    user_name: DOMAIN\User
    user_password: Password
```

与模块开始,最简单的一个例子可能是安装一个轻量级CLI的工具。让我们使用git,因为人们的工作流程都是一样的,对吧?

```yaml
- name: Install git
  win_chocolatey:
    name: git
    state: present
```

说真的,那就是很容易安装git。同样易于安装不同版本的东西如果你需要有一个特定的版本。假设你需要notepad++,6.6版。它会看起来像这样:

```yaml
- name: Install notepadplusplus version 6.6
  win_chocolatey:
    name: notepadplusplus
    version: '6.6'
```

一些包可能需要一个交互式用户登录进行安装。通过正确的凭证,您可以使用成为实现这一目标。下面的例子显示了一个安装包,需要使用。注意,您可以成为:系统,它不需要你提供一个密码。

```yaml
- name: Install a package that requires 'become'
  win_chocolatey:
    name: officepro2013
  become: yes
  become_user: Administrator
  become_method: runas
```

win_chocolatey模块是强大而强大的但没有成为在某些情况下是行不通的。没有简单的方法来发现如果一个包需要变得如此的最好的办法是试一试没有和使用成为如果失败。

参考：<https://docs.ansible.com/ansible/latest/modules/win_chocolatey_module.html#win-chocolatey-module>

### 4.3 awx管理windows

openflcon-agent.yml

```yaml
- host: '127.0.0.1'
  gather_facts: False
  vars:
  - ansible_connection: local
  task:
  - name: remove ssh key
    shell: ssh-keygen -R {{ host }}

- host: "{{ host }}"
  #become: true
  vars:
  - ansible_connection: winrm
  - ansible_winrm_server_cert_validation: ignore 
  - ansible_ssh_port: 5985  #这里必须赋值

  gather_facts: False
  role:
    - windows
```

windows下压缩，解压缩

```yaml
压缩一个文件：
makecab c:/file_name.txt c:/file_name.zip

解压一个文件：
expand c:/file_name.zip c:/file_name.txt
```

### 4.4 Tasklist taskkill 防火墙

![1558937386156](D:\smeyun\doc\ansible\1558937386156.png)

例外清單中，加入連接埠，例如下面指令分別允許 TCP 1234 連入，禁止 UDP 5678 連出：

```yaml
netsh advfirewall firewall add rule name="允許 TCP 1234 連入" protocol=TCP dir=in localport=1234 action=allow 
netsh advfirewall firewall add rule name="禁止 UDP 5678 連出" protocol=UDP dir=out localport=5678 action=block

netsh advfirewall firewall add rule name="允許 TCP 20~21 連入" protocol=TCP dir=in localport=20-21 action=allow
netsh advfirewall firewall add rule name="允許 hello.exe 連入" dir=in program="c:\alexc\hello.exe" action=allow
```

### 4.5 WinSW 创建windows服务

- As of 2015-10-27, WinSW is no longer available at the below location. Please follow the Using NSSM instructions above.

- Download [WinSW](http://repo.jenkins-ci.org/releases/com/sun/winsw/winsw/)

- - Place the executable (e.g. winsw-1.9-bin.exe) into this folder (c:\verdaccio) and rename it to verdaccio-winsw.exe

- Create a configuration file in c:\verdaccio, named verdaccio-winsw.xml with the following configuration xml verdaccio verdaccio verdaccio node c:\verdaccio\node_modules\verdaccio\src\lib\cli.js -c c:\verdaccio\config.yaml roll c:\verdaccio\.

- Install your service

- - cd c:\verdaccio
  - verdaccio-winsw.exe install

- Start your service

- - verdaccio-winsw.exe start

Some of the above config is more verbose than I had expected, it appears as though 'workingdirectory' is ignored, but other than that, this works for me and allows my verdaccio instance to persist between restarts of the server, and also restart itself should there be any crashes of the verdaccio process.



程序下载链接：

<https://github.com/kohsuke/winsw/releases>

yaml文件配置：

```yaml
<service>
<id>jenkins</id>
<name>Jenkins</name>
<description>This service runs Jenkins continuous integration system.</description>
<env name="JENKINS_HOME" value="%BASE%"/>
<executable>java</executable>
<arguments>-Xrs -Xmx256m -jar "%BASE%\jenkins.war" --httpPort=8080</arguments>
<logmode>rotate</logmode>
</service>

<service>
<id>kcp</id>
<name>kcp</name>
<description>这个服务用来将ss使用kcp协议加速</description>
<executable>client_windows_amd64</executable>
<arguments>-c kcp-config.json</arguments>
<logmode>reset</logmode>
</service>

<service>
  <id>nginx</id>
  <name>nginx</name>
  <description>nginx</description>
  <executable>D:\WebServer\nginx-1.12.2\nginx.exe</executable>
  <logpath>D:\WebServer\nginx-1.12.2\</logpath>
  <logmode>roll</logmode>
  <depend></depend>
  <startargument>-p</startargument>
  <startargument>D:\WebServer\nginx-1.12.2\</startargument>
  <stopexecutable>D:\WebServer\nginx-1.12.2\nginx.exe</stopexecutable>
  <stopargument>-p</stopargument>
  <stopargument>D:\WebServer\nginx-1.12.2\</stopargument>
  <stopargument>-s</stopargument>
  <stopargument>stop</stopargument>
</service>
```

基本用法

```yaml
* verdaccio-winsw.exe install
* verdaccio-winsw.exe uninstall
* verdaccio-winsw.exe start
* verdaccio-winsw.exe status
```

### 4.6 管理windows yaml

win_copy—拷贝文件到远程Windows主机，传输/etc/passwd文件至远程F:\file\目录下

 Playbook写法如下：

```yaml
---
- name: windows module example
  hosts: windows
  tasks:
     - name: Move file on remote Windows Server from one location to another
       win_file: src=/etc/passwd dest=F:\file\passwd
```

win_file —创建，删除文件或目录

```yaml
---
- name: windows module example
  hosts: windows
  tasks:
     - name: Rm Path
       win_file: path=F:\file\passwd state=absent
```

![1558937638789](D:\smeyun\doc\ansible\1558937638789.png)

```yaml
- name: Copy a single file
  win_copy:
    src: /srv/myfiles/foo.conf
    dest: C:\Temp\renamed-foo.conf

- name: Copy a single file keeping the filename
  win_copy:
    src: /src/myfiles/foo.conf
    dest: C:\Temp\

- name: Copy folder to C:\Temp (results in C:\Temp\temp_files)
  win_copy:
    src: files/temp_files
    dest: C:\Temp

- name: Copy folder contents recursively
  win_copy:
    src: files/temp_files/
    dest: C:\Temp

- name: Copy a single file where the source is on the remote host
  win_copy:
    src: C:\Temp\foo.txt
    dest: C:\ansible\foo.txt
    remote_src: yes

- name: Copy a folder recursively where the source is on the remote host
  win_copy:
    src: C:\Temp
    dest: C:\ansible
    remote_src: yes

- name: Set the contents of a file
  win_copy:
    content: abc123
    dest: C:\Temp\foo.txt

解压文件：
- name: unzip agent file
  win_unzip: 
    src: 'c:\111\222\\{{ ops_file }}'
    dest: 'c:\111\333'
    create: 'c:\111\333'
```

下面的例子显示了如何使用win_updates:

```yaml
安装所有关键和安全更新:
- name: install all critical and security updates
  win_updates:
    category_names:
    - CriticalUpdates
    - SecurityUpdates
    state: installed
  register: update_result

如果需要重新启动主机:
- name: reboot host if required
  win_reboot:
  when: update_result.reboot_required

下面的示例演示如何使用win_hotfix安装一个更新或热修复补丁:
- name: download KB3172729 for Server 2012 R2
  win_get_url:
    url: http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/07/windows8.1-kb3172729-x64_e8003822a7ef4705cbb65623b72fd3cec73fe222.msu
    dest: C:\temp\KB3172729.msu

- name: install hotfix
  win_hotfix:
    hotfix_kb: KB3172729
    source: C:\temp\KB3172729.msu
    state: present
  register: hotfix_result

- name: reboot host if required
  win_reboot:
  when: hotfix_result.reboot_required
```



设置用户和组:

```yaml
创建用户和组：
- name: create local group to contain new users
  win_group:
    name: LocalGroup
    description: Allow access to C:\Development folder

创建本地用户：
- name: create local user
  win_user:
    name: '{{item.name}}'
    password: '{{item.password}}'
    groups: LocalGroup
    update_password: no
    password_never_expired: yes
  with_items:
  - name: User1
    password: Password1
  - name: User2
    password: Password2


创建目录：

- name: create Development folder
  win_file:
    path: C:\Development
    state: directory

设置目录权限：
- name: set ACL of Development folder
  win_acl:
    path: C:\Development
    rights: FullControl
    state: present
    type: allow
    user: LocalGroup

删除目录：
- name: remove parent inheritance of Development folder
  win_acl_inheritance:
    path: C:\Development
    reorganize: yes
    state: absent
```

模块win_domain_user和win_domain_group管理域中的用户和组。下面是一个例子,确保一批域创建用户:

```yaml
- name: ensure each account is created
  win_domain_user:
    name: '{{item.name}}'
    upn: '{{item.name}}@MY.DOMAIN.COM'
    password: '{{item.password}}'
    password_never_expires: no
    groups:
    - Test User
    - Application
    company: Ansible
    update_password: on_create
  with_items:
  - name: Test User
    password: Password
  - name: Admin User
    password: SuperSecretPass01
  - name: Dev User
    password: '@fvr3IbFBujSRh!3hBg%wgFucD8^x8W5'
```

```yaml
PowerShell下运行一个命令:
- name: run a command under PowerShell
  win_shell: Get-Service -Name service | Stop-Service

运行一个命令在cmd:
- name: run a command under cmd
  win_shell: mkdir C:\temp
  args:
    executable: cmd.exe

运行多个shell命令:
- name: run a multiple shell commands
  win_shell: |
    New-Item -Path C:\temp -ItemType Directory
    Remove-Item -Path C:\temp -Force -Recurse
    $path_info = Get-Item -Path C:\temp
    $path_info.FullName

使用win_command运行一个可执行的:
- name: run an executable using win_command
  win_command: whoami.exe

运行cmd命令:
- name: run a cmd command
  win_command: cmd.exe /c mkdir C:\temp

运行一个根据脚本:
- name: run a vbs script
  win_command: cscript.exe script.vbs
```

创建和运行计划任务

```yaml
创建计划任务运行过程:
- name: create scheduled task to run a process
  win_scheduled_task:
    name: adhoc-task
    username: SYSTEM
    actions:
    - path: PowerShell.exe
      arguments: |
        Start-Sleep -Seconds 30 # this isn't required, just here as a demonstration
        New-Item -Path C:\temp\test -ItemType Directory
    # remove this action if the task shouldn't be deleted on completion
    - path: cmd.exe
      arguments: /c schtasks.exe /Delete /TN "adhoc-task" /F
    triggers:
    - type: registration

等待完成预定任务:
- name: wait for the scheduled task to complete
  win_scheduled_task_stat:
    name: adhoc-task
  register: task_stat
  until: (task_stat.state is defined and task_stat.state.status != "TASK_STATE_RUNNING") or (task_stat.task_exists == False)
  retries: 12
  delay: 10
```



### 4.7 使用NSSM将exe封装为服务

NSSM是一个服务封装程序，它可以将普通exe程序封装成服务，使之像windows服务一样运行。同类型的工具还有微软自己的srvany，不过nssm更加简单易用，并且功能强大。它的特点如下：

 

支持普通exe程序（控制台程序或者带界面的Windows程序都可以）

安装简单，修改方便

可以重定向输出（并且支持Rotation）

可以自动守护封装了的服务，程序挂掉了后可以自动重启

可以自定义环境变量

这里面的每一个功能都非常实用，使用NSSM来封装服务可以大大简化我们的开发流程了。

 

开发的时候是一个普通程序，降低了开发难度，调试起来非常方便

安装简单，并且可以随时修改服务属性，更新也更加方便

可以利用控制台输出直接实现一个简单的日志系统

不用考虑再加一个服务实现服务守护功能

我觉得它还可以需要增加的一个功能是将输入输出重定向为一个tcp连接，这样可以通过telnet的方式实现程序的交互了，那样就更加好用了。

 

下面就简单的介绍一下如何使用这个工具。

 

官网：https://nssm.cc/

![1558937793460](D:\smeyun\doc\ansible\1558937793460.png)

![1558937804106](D:\smeyun\doc\ansible\1558937804106.png)



## 5. 其他

### 5.1 ansible 加密

```yaml
创建加密文件：默认加密方式为AES(基于共享密钥)
ansible-vault create foo.yml

Editing加密文件：
ansible-vault edit foo.yml

更新密码：如下命令可以同时批量修改多个文件的组织密码并重新设置新密码.
ansible-vault rekey foo.yml bar.yml baz.yml

加密普通文件：
ansible-vault encrypt foo.yml bar.yml baz.yml

解密加密文件：
ansible-vault decrypt foo.yml bar.yml baz.yml

查阅已加密文件：
ansible-vault view foo.yml bar.yml baz.yml

在Vault下允许playbook：密码存储一行一个
ansible-playbook site.yml --ask-vault-pass

ansible-playbook site.yml --vault-password-file ~/.vault_pass.txt
ansible-playbook site.yml --vault-password-file ~/.vault_pass.py
```

### 5.2 ansible文档查询

```yaml
ansible-doc yum

列出所有已经安装的模块文档：
ansible-doc -l
```



### 5.3 官方role列子

[https://galaxy.ansible.com](https://galaxy.ansible.com/)

<https://getansible.com/advance/best_practice/zui_jia_shi_yong_fang_fa>

<https://www.w3cschool.cn/automate_with_ansible/>

```shell
#下载官方role案列
ansible-galaxy install geerlingguy.firewall

```





### 5.4 性能调优

一、关闭 gathering facts

如果您观察过 ansible-playbook 的执行过程中，您会发现 ansible-playbook 的第 1 个步骤总是执行 gather facts，不论你有没有在 playbook 设定这个 tasks。如果你不需要获取被控机器的 fact 数据的话，你可以关闭获取 fact 数据功能。关闭之后，可以加快 ansible-playbook 的执行效率，尤其是你管理很大量的机器时，这非常明显。关闭获取 facts 很简单，只需要在 playbook 文件中加上“gather_facts:  false”即可。如下

![1558927786251](D:\smeyun\doc\ansible\1558927786251.png)

二、开启pipelining

SSH pipelining 是一个加速 Ansible 执行速度的简单方法。ssh pipelining 默认是关闭，之所以默认关闭是为了兼容不同的 sudo 配置，主要是 requiretty 选项。如果不使用 sudo，建议开启。打开此选项可以减少 ansible 执行没有传输时 ssh 在被控机器上执行任务的连接数。不过，如果使用 sudo，必须关闭 requiretty 选项。修改 /etc/ansible/ansible.cfg 文件可以开启 pipelining

改为：pipelining=True

![1558927809895](D:\smeyun\doc\ansible\1558927809895.png)

三、添加ControlMaster的配置

安装最新版本openssh，配置ssh持久化连接

1、安装openssh6.6p1参考如下，查看版本命令rpm -qa openssh，如已经是最新直接执行步骤2

<http://www.cnblogs.com/andriy-h/p/6386444.html>



2、配置ssh

```shel
nsible的目录/home/shdxspark/.ssh下创建或修改config，如下：

[shdxspark@ossdevops2 .ssh]$ more config
Host *
Compression yes
ServerAliveInterval 60
ServerAliveCountMax 5
ControlMaster auto
ControlPath ~/.ssh/sockets/%r@%h-%p
ControlPersist 4h

修改完后赋权600：chmod 600 config
```



四、并行执行

使用async和poll这两个关键字便可以并行运行一个任务. async这个关键字触发ansible并行运作任务,而async的值是ansible等待运行这个任务的最大超时值,而poll就是ansible检查这个任务是否完成的频率时间.

```yaml
- name: update app
  shell: sleep 10
  async: 1000
  poll: 0
```

设置poll为0可以不等待任务执行完毕：设置sleep为10秒，结果1.53秒即执行完成

![1558927886600](D:\smeyun\doc\ansible\1558927886600.png)

五、在ansible.cfg中配置fact缓存使用

```yaml
[defaults]
gathering = smart
fact_caching = redis
fact_caching_timeout = 86400
# seconds

请执行适当的系统命令来启动和运行redis:
yum install redis
service redis start
pip install redis

在ansible.cfg中使用以下代码来配置fact缓存使用jsonfile:

[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /path/to/cachedir
fact_caching_timeout = 86400
# seconds
```

# 6 官方集成API解决方案 AWX

<https://github.com/ansible/awx>

安装手册：

<https://github.com/ansible/awx/blob/devel/INSTALL.md>

https://docs.ansible.com/ansible-tower/latest/html/

下载地址：

 https://releases.ansible.com/ansible-tower/setup/

参考文档：https://docs.ansible.com/ansible-tower/latest/html/

自动化神器 Ansible

https://www.fastzhong.com/2017/02/28/ansible/>

https://www.pyfdtic.com/2018/03/15/Ansible-基本原理与安装配置/



破解安装：

https://github.com/ansible/awx

https://hub.docker.com/u/ansible



在多租户Edge & DC环境中使用AWX和Ansible自动化& SFC

https://pantheon.tech/awx-ansible-lightyio/



api：

https://docs.ansible.com/ansible-tower/latest/html/towerapi/api_ref.html#/Authentication/Authentication_applications_list_0

https://access.redhat.com/documentation/en-us/red_hat_satellite/6.1/html/api_guide



商业版本：

https://releases.ansible.com/ansible-tower/setup/







## 6.1 批量导入资产

新版本的ansible-tower非常强大，笔者相信他一定能站起来。关于资产的导入`ansible tower`内部支持从云厂商或者私有虚拟化云直接导入机器，如果你使用的云厂商不支持，还可自己编写python/shell脚本来调用云厂商API添加到`ansible tower`资产中。抓紧 Let’s Go

***1. 通过UI界面导入***

点击`Inventories`点击添加按钮，会提示出两种`Inventory`：`Inventory 正常的资产`， `Smart Inventory 根据从Inventory筛选条件变化的`

![1561360921209](D:\smeyun\doc\spring\1561360921209.png)





![1561360958900](D:\smeyun\doc\spring\1561360958900.png)

***2. 通过命令行`tower-manage`批量添加主机***

通过Tower自带的命令行工具`tower-manage`来批量导入主机，可以从主机的`/etc/ansible/hosts`中直接导入

```yaml
tower-manage inventory_import --source=/etc/ansible/hosts --group-filter=test --inventory-name=测试环境 --keep-vars

    1.569 INFO     Updating inventory 7: 测试环境
    1.674 INFO     Reading Ansible inventory source: /etc/ansible/hosts
    3.003 INFO     Processing JSON output...
    3.004 INFO     Loaded 7 groups, 11 hosts
    3.292 INFO     Inventory import completed for  (测试环境 - 17) in 1.7s
    
    
--source            指定inventory文件
--group-filter      从文件中通过组名过滤
--host-filter       通过host name过滤
--inventory-name    导入到指定名称资产清单
--inventory-id      导入到指定ID的资产清单
# name 和 id 选一个
--overwrite         覆盖主机和组，默认不覆盖
--overwrite-vars    覆盖主机变量
--keep-vars         保持主机变量
--enabled-value     导入的主机状态是否激活默认激活
```



## 6.2 创建凭证

可以创建各种各样的凭证，连接云厂商Api的凭证/连接gitlab的凭证/连接Linux主机的凭证/自定义的凭证等等。。我们先创建一个Gitlab认证用来拉取我们的Playbook

![1561361231212](D:\smeyun\doc\spring\1561361231212.png)



![1561361247850](D:\smeyun\doc\spring\1561361247850.png)

## 6.3.创建项目

`playbook`拉取的方式主要有：

```
- Manual        从本地目录读取
- Git           从Git拉取
- Mercurial     从mer
- SVN
- RedHatInsights
```

这里选用Git从Gitlab上拉取

![1561361316510](D:\smeyun\doc\spring\1561361316510.png)

Options选项配置：

```yaml
- Clean 
在从gitlab拉取前清除本地修改的playbook
- Delete on Update 
当更新时删除所有本地储存playbook
- Update Revision on Launch 
当Templates任务运行时，自动从git拉取更新
```

tower 测试playbook地址：https://jsproxy.ga/-----https://github.com/ansible/tower-example



## 6.4 创建模版

最后一步来了,创建`Templates`

![1561361421411](D:\smeyun\doc\spring\1561361421411.png)

Options选项配置：

```yaml
- Enable Privilege Escalation 
# 默认脚本以awx用户执行playbook，开启后使用管理员身份
- Allow Provisioning Callbacks 
# 运行通过url回调来启动这个任务
- Enable Concurrent Jobs 
# 允许相同任务一起运行
- Use Fact Cache 
# 使用缓存
```

点击`SCHEDULES`可以添加计划任务

## 6.5 重新生成token

访问url： http://30.23.18.106/api/v2/tokens/

- <application-id> 改成1，就会生成新的token，将其填入给api请求即可，这个值每次刷新都是不一样的。
- token值组合： Bearer <token-value>

```
{
    "description": "My Access Token",
    "application": <application-id>,
    "scope": "write"
}
```

## 6.6 生产定制

### 1.定制docker images

在生产环境要求对task镜像做定制化的文件注入：

```shell
docker commit -m "add fastdfs" -a "yunhua" 302932323 ansible/awx_task:6.0.1
docker commit -m "add fastdfs" -a "yunhua" 322343423 ansible/awx_web:6.0.1

docker save ansible/awx_task.tar:6.0.1 -o awx_task.tar
docker save ansible/awx_wab:6.0.1 -o awx_wab.tar
```

### 2.离线pip安装包制作

```shell
1.获取一份当前安装的清单文件
pip3 freeze > requirements.txt

2.下载清单中弄过的安装包
mkdir -p /tmp/pkg
pip3 download -r requirements.txt -d /tmp/pkg

3.安装下载的离线包
pip3 install --no-index --find-links=./pkg docker-compose

注意， --no-index 表示我要导入包的顺序是无序的，因为包与包之间可能会存在依赖关系，所以我们要关闭这些依赖
```

Python pip离线安装package方法总结（以TensorFlow为例）

https://imshuai.com/python-pip-install-package-offline-tensorflow



## 6.7 故障处理记录

### 6.7.1 清理消息队列

方法1：直接改数据库

```
登录postgresql 容器
docker exec -it postgres bash

登录数据库：
psql -U awx -d awx
select * from main_unifiedjob where status like 'pand%';

将任务修改为failed
update main_unifiedjob set status="failed" where status like 'pand%';

#退出
\q
```

方法2：通过awx_web执行命令

```
docker exec -it awx_web bash
awx-manage shell_plus

from awx.main.models import UnifiedJob
unified_job_obj=UnifiedJob()
unified_job_obj.status = "pending"
unified_job_obj.delete()
```

参考：https://github.com/ansible/awx/issues/955



