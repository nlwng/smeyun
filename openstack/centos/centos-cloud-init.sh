    1  cd /etc/
    2  ll sudoers
    3  chmod 640 sudoers
    4  vi sudoers
    5  chmod 440 sudoers
    6  usermod -a -G centos wheel
    7  cat /etc/sudoers
    8  usermod -a -G centos wheel
    9  usermod -a -G wheel centos
   10  ll sudoers
   11  chmod 640 sudoers
   12  vi sudoers
   13  groups centos
   14  chmod 440 sudoers
   15  ll sudoers
   16  chmod 640 sudoers
   17  vi sudoers
   18  chmod 440 sudoers
   19  passwd
   20  vi /etc/passwd
   21  passwd
   22  exit
   23  vi /etc/shadow
   24  passwd root
   25  passwd
   26  cd /etc/sysconfig/network-scripts/
   27  ls
   28  vi ifcfg-eth0 
   29  ethtool 
   30  reboot
   31  ls
   32  ifconfig
   33  ping 10.0.6.94
   34  ping 10.0.6.107
   35  cd /etc/
   36  ls
   37  cd networks 
   38  vi networks 
   39  vi network
   40  vi /etc/sysconfig/network
   41  cd /etc/sysconfig/network-scripts/
   42  ls
   43  vi ifcfg-eth0 
   44  ifconfig
   45  reboot
   46  ping 10.0.6.94
   47  ping 10.201.255.254
   48  shutdown -h now
   49  cd /etc/udev/rules.d/
   50  ls
   51  cat 70-persistent-net.rules 
   52  rm 70-persistent-net.rules 
   53  ls
   54  cd /boot/grub/
   55  ls
   56  vi menu.lst 
   57  netstat -lntp
   58  df
   59  ls
   60  top
   61  df
   62  top
   63  ps -ef|grep yum
   64  ps -ef
   65  ps -ef|grep yum
   66  top
   67  vi menu.lst 
   68  reboot
   69  ifconfig
   70  dmesg|grep eth
   71  cd /etc/networks 
   72  cd /etc/
   73  ls
   74  cat networks 
   75  cd syscconfig
   76  cd sysconfig/
   77  ls
   78  ls networking/
   79  cd networking/
   80  ls
   81  cd devices/
   82  ls
   83  cd ../profiles/
   84  ls
   85  cd default/
   86  ls
   87  cd ..
   88  ls
   89  cd ..
   90  ls
   91  cd ../
   92  ls
   93  cd ..
   94  ls
   95  cd udev/
   96  ls
   97  cd udev.conf 
   98  cd rules.d/
   99  ls
  100  cd ..
  101  ls
  102  cd makedev.d/
  103  ls
  104  yum update
  105  ifconfig
  106  ethtool -k eth0
  107  ethtool -K tso off
  108  ethtool -K eth0 tso off
  109  ethtool -k eth0
  110  cd /etc/sysconfig/network-scripts/
  111  ls
  112  vi ifcfg-eth0 
  113  ifdown eth0
  114  ifup eth0
  115  q
  116  vi ifcfg-eth0 
  117  ifdown eth0
  118  ifup eth0
  119  vi ifcfg-eth0 
  120  ifdown eth0
  121  ifup eth0
  122  ifconfig
  123  ls
  124  ethtool -k eth0
  125  ping www.sohu.com
  126  yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  127  yum -y install git
  128  yum -y distro-sync
  129  yum -y install acpid
  130  chkconfig acpid on
  131  yum install -y parted
  132  yum install cloud-init cloud-utils
  133  cd /etc/cloud/
  134  ls
  135  vi cloud.cfg
  136  reboot
  137  python --version
  138  lsb_release -a
  139  service --status-all
  140  ls
  141  ip a
  142  ethtools -k eth0
  143  ethtool -k eth0
  144  vi /etc/network/interfaces
  145  sl
  146  ls
  147  ethtool -k eth0
  148  cd /etc/sysconfig
  149  ls
  150  cd network-scripts/
  151  ls
  152  vi ifcfg-eth0 
  153  grep -r ETHTOOL_OPT *
  154  grep -r ETHTOOL_OPTS *
  155  grep -n -r ETHTOOL_OPTS *
  156  vi network-functions
  157  ethtool -k eth0
  158  ethtool -K eth0 tso off
  159  ethtool -k eth0
  160  vi ~/.bash_history
  161  service network restart
  162  ethtool -k eth0
  163  vi /var/log/dmesg
  164  vi /etc/rc.local 
  165  which ethtool
  166  vi /etc/rc.local 
  167  reboot
  168  cd /etc/sysconfig
  169  ls
  170  vi network
  171  cd /etc/udev/rules.d/
  172  ls
  173  ls 70-persistent-net.rules 
  174  rm 70-persistent-net.rules 
  175  cd /tmp
  176  ls
  177  rm -rf *
  178  ls
  179  cd /var/log
  180  du -sh *
  181  ls | grep cloud
  182  rm cloud-init*
  183  shutdown -h now
  184  cd /etc/sysconfig
  185  vi network
  186  cd /etc/udev/rules.d/
  187  ls
  188  rm 70-persistent-net.rules 
  189  cd /var/lgo
  190  cd /var/lg
  191  cd /var/log
  192  lsssssss cloud*
  193  ls could*
  194  ls 
  195  ls cloud*
  196  rm cloud-init*
  197  cd /tmp
  198  ls
  199  rm -rf *
  200  shutdown -h now