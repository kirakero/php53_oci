#!/bin/bash

# originally from http://www.synet.sk/php/en/190-compiling-PHP5-3-3-under-CentOS-5-with-oracle-instantclient
# install following packages from Centos repos:
#=============================================
# yum install autoconf httpd-devel mod_ssl gcc-c++ pam-devel krb5-libs krb5-workstation krb5-devel krb5-server krb5-devel libmhash-devel libmcrypt-devel
# yum install aspell-devel mhash-devel t1lib-devel freetype-devel libpng-devel libjpeg-devel ncurses-devel libxml2-devel libxslt-devel
# yum install openldap-devel libtool bzip2 pcre-devel zlib-devel openssl-devel libstdc++-devel curl-devel bzip2-devel
# yum install php-devel libc-client libc-client-devel libtidy-devel
#=============================================
# before compiling PHP you must install oci8 with oracle instant client!

apt-get install -y apache2-prefork-dev libfreetype6-dev libldb-dev libldap2-dev libxslt-dev

ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

find . -name '*apxs*'
echo "done find"

# get current working directory path
CURRENTDIR=/usr/local/src
cd $CURRENTDIR

# set default place for PHP INI configuration
PHPINI="/etc/php"

# download from http://sk.php.net/get/php-5.3.29.tar.gz/from/a/mirror
PHP="php-5.3.29"

# temporary directory to collect compilation output
TEMP="temp"
#rm -r $TEMP >& /dev/null
mkdir $TEMP >& /dev/null
chmod -R 644 $TEMP

# log filename
STAMP=`date +%Y-%m-%d-%H-%M`
LOG="./$TEMP/compilation-php.$STAMP.log"
echo "LOG - Compilation Results" > $LOG

echo "=========================" | tee -a $LOG
echo "Defining resources and cleaning up previous compilation..." | tee -a $LOG
echo "=========================" | tee -a $LOG

#############################################
# clean up previosly compiled files
#############################################

# clean up previously compiled files:
if [ -d "$PHP" ]
then
	echo "=========================" | tee -a $LOG
	echo "Cleaning up previous compilation.." | tee -a $LOG
	echo "=========================" | tee -a $LOG
	cd ./$PHP
	make clean > ./.$LOG
	cd ..
fi

#############################################
# Untar sources
#############################################

echo "=========================" | tee -a $LOG
echo "Unpacking..." | tee -a $LOG
echo "=========================" | tee -a $LOG

# untar php
rm -r $PHP >& /dev/null
tar -zxvf $PHP.tar.gz >& /dev/null

#############################################
# collect available [configure --help] options
#############################################

echo "=========================" | tee -a $LOG
echo "Collecting available configuration options..." | tee -a $LOG
echo "=========================" | tee -a $LOG

cd ./$PHP
./configure --help > ./../$TEMP/config-options-$PHP.log
sleep 2
cd ..

############################################
# PHP START COMPILATION
############################################

cd $PHP

./configure \
	--prefix=/usr/local/php5 \
	--exec-prefix=/usr/local/php5 \
	--libdir=/usr/local/php5/lib \
	--with-apxs2=/usr/bin/apxs2 \
	--with-config-file-path=$PHPINI \
	--enable-calendar \
	--enable-shared \
	--enable-inline-optimization \
	--with-openssl \
	--with-kerberos \
	--with-zlib \
	--with-curl \
	--enable-zend-multibyte \
	--enable-ftp \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-bcmath \
	--enable-sigchild \
	--enable-mbstring \
	--enable-mbregex \
	--enable-soap \
	--enable-sockets \
	--with-pcre-regex \
	--enable-pcntl \
	--enable-wddx \
	--enable-zip \
	--with-gd \
	--enable-gd-native-ttf \
	--with-jpeg-dir=/usr/local \
	--with-png-dir=/usr/local \
	--with-freetype-dir=/usr/local \
	--with-ldap \
	--with-bz2 \
	--with-mhash \
	--with-mcrypt \
	--with-imap \
	--with-imap-ssl \
	--with-xsl \
	--with-xmlrpc \
	--with-tidy \
	--with-oci8=shared,instantclient,/usr/local/oracle/instantclient_10_2 \
	--with-pdo-oci=instantclient,/usr/local/oracle/instantclient_10_2,10.2 \
	--without-sqlite \
	--without-pear \
	>> ./.$LOG

sleep 2

cd ..
chmod -R 777 $PHP
chown -R root $PHP

echo "=========================" >> $LOG
echo "PHP - running make.." >> $LOG
echo "=========================" >> $LOG

cd ./$PHP
make >> ./.$LOG
sleep 2
cd ..

chmod -R 777 $PHP
chown -R root $PHP

echo "=========================" >> $LOG
echo "PHP - running make install.." >> $LOG
echo "=========================" >> $LOG

cd ./$PHP
make install >> ./.$LOG
sleep 2

echo "Creating $PHPINI"
mkdir $PHPINI >& /dev/null
echo "Copying php.ini development configuration file into $PHPINI"
cp php.ini-development ${PHPINI}/php.ini

cd ..
echo "DONE! Check logs in [$LOG]"
echo "=========================="
echo "NOW:"
echo "restart apache with command:[service httpd restart]"
echo "-- now you may want to: --"
echo " --> run phpinfo() and check available PHP extensions. If needed add extensions into ${PHPINI}/php.ini, e.g. extension=oci8.so"
echo " --> set DATE timezone in php.ini"
echo " --> check oracle oci_connect()/pdo connect. If needed, set oracle environment variables (TNS..) via virtual host."
echo " --> install debugging server modules"
echo " --> setup httpd virtual host for your PHP project"
echo " --> map www-root directory via samba into windows in order to develop on Win-based PHP IDE"
echo " --> set access permissions to www document-root (owner should be apache, mode 644)"
echo " --> good luck!"

# if OCI8/PDO_OCI compiled but not loaded, add into php.ini (/etc/php/php.ini) as needed:
# extension=pdo_oci.so
# extension=oci8.so