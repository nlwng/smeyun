

yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel mysql pcre-devel curl-devel libxslt-devel


./configure --prefix=/usr/local/php \
 --with-curl \
 --with-apxs2=/usr/local/apache2/bin/apxs \
 --with-freetype-dir \
 --with-gd \
 --with-gettext \
 --with-iconv-dir \
 --with-kerberos \
 --with-libdir=lib64 \
 --with-libxml-dir \
 --with-mysqli \
 --with-openssl \
 --with-pcre-regex \
 --with-pdo-mysql \
 --with-pdo-sqlite \
 --with-pear \
 --with-png-dir \
 --with-xmlrpc \
 --with-xsl \
 --with-zlib \
 --with-openssl \
 --enable-fpm \
 --enable-bcmath \
 --enable-libxml \
 --enable-inline-optimization \
 --enable-gd-native-ttf \
 --enable-mbregex \
 --enable-mbstring \
 --enable-opcache \
 --enable-pcntl \
 --enable-shmop \
 --enable-soap \
 --enable-sockets \
 --enable-sysvsem \
 --enable-xml \
 --enable-zip 


make &&  make install

error:

/usr/bin/ld: ext/ldap/.libs/ldap.o: undefined reference to symbol 'ber_strdup@@OPENLDAP_2.4_2'
//usr/lib/x86_64-linux-gnu/liblber-2.4.so.2: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make: *** [sapi/cli/php] Error 1

解决办法：在PHP源码目录下 vim Makefile 找到 EXTRA_LIBS 行（带有很多参数的行），在行末添加 ‘ -llber ‘ 保存退出再次make即可。


配置文件
# cp php.ini-development /usr/local/php/lib/php.ini
# cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
# cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
# cp -R ./sapi/fpm/php-fpm /etc/init.d/php-fpm

启动
#  /etc/init.d/php-fpm
重启
# killall php-fpm
#  /etc/init.d/php-fpm

/usr/local/apache2/bin/apachectl stop

MediaWiki使用：
How do I stop anonymous users from editing any page?
$wgGroupPermissions['*']['edit'] = false;

How do I completely disable caching?
$wgEnableParserCache = false;
$wgCachePages = false;

How do I restrict account creation?
$wgFileExtensions = array_merge($wgFileExtensions, array( 'pdf', 'txt', 'mp3' ));















