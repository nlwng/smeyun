#------------------------------------------------------------------

#修改网卡信息
echo "
auto lo
iface lo inet loopback

# The primary network interface
auto eth1
iface eth1 inet static
address $controller_ip
netmask 255.255.255.0
#gateway $gateway

auto eth0
#iface eth0 inet manual
iface eth0 inet dhcp
#up ip link set dev \$IFACE up
#down ip link set dev \$IFACE down

">/etc/network/interfaces

#------------------------------------------------------------------

#修改主机名
echo "controller">/etc/hostname

#------------------------------------------------------------------

#域名解析
echo "
127.0.0.1       localhost
# controller
$controller_ip      controller
# compute1
$compute1_ip        compute1
$compute2_ip        compute2
$compute3_ip        compute3
$compute4_ip        compute4
$compute5_ip        compute5
">/etc/hosts

#------------------------------------------------------------------

#修改主机名
echo "nameserver $dns">/etc/resolvconf/resolv.conf.d/base

#------------------------------------------------------------------

#重启系统
reboot
