#docker install maridb
#update gcc
wget http://ftpmirror.gnu.org/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2
tar -xf  gcc-5.2.0.tar.bz2


./contrib/download_prerequisites

#Linux没有网络连接（我主机和虚拟机是Host-only，不能联网，所以另外想办法），则用Windows上网下载这几个包：
