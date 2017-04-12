制作ubuntu安装源：
#install apt-mirrorapt-get install apt-mirror

# vi /etc/apt/mirror.list
加入以下内容：
############# config ##################
#
# set base_path    /var/spool/apt-mirror
  set base_path    /home/openstack/ubuntu
# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript $var_path/clean.sh
# set defaultarch  <running host architecture>
# set postmirror_script $var_path/postmirror.sh
# set run_postmirror 0
  set nthreads     20
  set _tilde 0 
deb http://mirrors.163.com/ubuntu/ trusty main restricted
deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted
deb http://mirrors.163.com/ubuntu/ trusty universe
deb http://mirrors.163.com/ubuntu/ trusty-updates universe
deb http://mirrors.163.com/ubuntu/ trusty multiverse
deb http://mirrors.163.com/ubuntu/ trusty-updates multiverse
deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-security main restricted
deb http://mirrors.163.com/ubuntu/ trusty-security universe
deb http://mirrors.163.com/ubuntu/ trusty-security multiverse
deb http://extras.ubuntu.com/ubuntu trusty main
clean http://mirrors.163.com/ubuntu/
执行：apt-mirror


安装apache2
      apt-get install apache2
apache2的根目录为：
/var/www/
ln -s /home/openstack/ubuntu/ /var/www/ubuntu/

在客户端配置
vi /etc/apt/source.list
加入：
deb http://10.10.1.111// trusty main restricted
deb http://10.10.1.111/ubuntu/ trusty-updates main restricted
deb http://10.10.1.111/ubuntu/ trusty universe
deb http://10.10.1.111/ubuntu/ trusty-updates universe
deb http://10.10.1.111/ubuntu/ trusty multiverse
deb http://10.10.1.111/ubuntu/ trusty-updates multiverse
deb http://10.10.1.111/ubuntu/ trusty-backports main restricted universe multiverse
deb http://10.10.1.111/ubuntu/ trusty-security main restricted
deb http://10.10.1.111/ubuntu/ trusty-security universe
deb http://10.10.1.111/ubuntu/ trusty-security multiverse


服务器配置openstack源
############# config ##################
#
# set base_path    /var/spool/apt-mirror
  set base_path    /home/openstack/icehouse
# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript $var_path/clean.sh
# set defaultarch  <running host architecture>
# set postmirror_script $var_path/postmirror.sh
# set run_postmirror 0
  set nthreads     20
 
deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/icehouse main
deb-src http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/icehouse main
clean 
  
 
 ln -s /home/openstack/icehouse/ /var/www/icehouse/
 #apt-mirror
在客户端配置：
deb http://10.10.1.111/ubuntu precise-updates/icehouse main
deb-src http://10.10.1.111/ubuntu precise-updates/icehouse main
到这里本地ubuntu源和openstack源就搭建完成了