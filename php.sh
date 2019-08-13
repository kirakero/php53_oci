#!/bin/bash


cd /usr/local/src/




mkdir /usr/local/src/php5-build
cd /usr/local/src/php5-build
wget -O php-5.3.29.tar.gz http://de1.php.net/get/php-5.3.29.tar.gz/from/this/mirror --no-check-certificate
tar -xzf php-5.3.29.tar.gz
cd php-5.3.29



mkdir /usr/share/php53

./configure
    --prefix=/usr/share/php53      \
    --datadir=/usr/share/php53    \
    --mandir=/usr/share/man    \
    --bindir=/usr/bin/php53    \
    --includedir=/usr/include/php53  \
    --sysconfdir=/etc/php53/apache2 \
    --with-config-file-path=/etc/php53/apache2 \
    --with-config-file-scan-dir=/etc/php53/conf.d \
    --enable-bcmath \
    --with-curl=shared,/usr \
    --with-mcrypt=shared,/usr \
    --enable-cli \
    --with-gd \
    --with-mysql \
    --with-mysqli \
    --enable-libxml \
    --enable-session \
    --enable-xml \
    --enable-simplexml \
    --enable-filter \
    --enable-inline-optimization \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib \
    --with-bz2 \
    --with-curl \
    --enable-exif \
    --enable-soap \
    --with-pic \
    --disable-rpath \
    --disable-static \
    --enable-shared \
    --with-gnu-ld \
    --enable-mbstring
make && make install

a2enmod cgi fastcgi actions
service apache2 restart

printf "#Include file for virtual hosts that need to run PHP 5.3 \n\
      SetHandler application/x-httpd-php5 \n\
      ScriptAlias /php53-cgi /usr/lib/cgi-bin/php53-cgi \n\
      Action application/x-httpd-php5 /php53-cgi \n\
      AddHandler application/x-httpd-php5 .php" >> /etc/apache2/php53.conf