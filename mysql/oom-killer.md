1. mysql 无法启动报错
2. 通过mysql日志查看错误为：
----------------
mysqld_safe mysqld from pid file /data/mysql5.6.27/data/Operations.pid ended

3.通过系统日志查看错误为：
----------------
Mar 16 11:39:44 Operations kernel: Out of memory: Kill process 10999 (mysqld) score 484 or sacrifice child
Mar 16 11:39:44 Operations kernel: Killed process 10999 (mysqld) total-vm:448616kB, anon-rss:407008kB, file-rss:0kB
Mar 16 11:46:42 Operations kernel: Adding 4194300k swap on /opt/swapfile.  Priority:-1 extents:3 across:4456444k FS

4.查询资料发现是OOM killer 问题造成的故障，Out of memory 问题
4.1 解决方案1，开启swap
dd if=/dev/zero of=/opt/swapfile bs=1M count=1024
mkswap /opt/swapfile
swapon /opt/swapfile
swapon -s

在fstab增加相关记录，否则重启就没了
#vi /etc/fstab
/opt/swapfile           swap                    swap    defaults        0 0

4.2 修改内核实现OOM控制

参考：
http://www.vpsee.com/2013/10/how-to-configure-the-linux-oom-killer/
http://www.weiruoyu.cn/?p=477
tag=>type: content:>url
flow
st=>start: Start
op=>operation: Your Operation
cond=>condition: Yes or No?
e=>end
st->op->cond
cond(yes)->e
cond(no)->op
