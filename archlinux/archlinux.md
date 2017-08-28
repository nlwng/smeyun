
# images
https://www.archlinux.org/download/

# install 

```
fdisk -l 
fdisk /dev/sda
n p 1
n p w

刷新：
partprobe /dev/sda

mkfs.ext4 /dev/sda
mount /dev/sda /mnt

system base install:
pacstrap /mnt base base-devel

create fatab:
genfstab -U -p /mnt >> /mnt/etc/fstab

切换root
arch-chroot /mnt /bin/bash

set Lang：
vi /etc/locale.conf    添加一行LANG=en_US.UTF-8
vi /etc/locale.gen     把en_US.UTF-8 UTf-8,zh_CN.GBK GBK,zh_CN.UTF-8 UTF-8,zh_CN GB2312前面的注释去掉
locale-gen               更新语言环境

set time：
#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime



```

# note
http://www.cnblogs.com/vachester/p/5635819.html