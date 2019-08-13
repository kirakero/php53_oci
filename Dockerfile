FROM ubuntu:12.04
MAINTAINER Alexander Schenkel <alex@alexi.ch>

VOLUME ["/var/www"]

RUN apt-get update && \
    apt-get install -y \
    curl wget unzip libaio-dev make build-essential


# Oracle instantclient
ADD instantclient-10.2.0.5.0/instantclient-basic-10.2.0.5.0-linux.zip /usr/local/src/
ADD instantclient-10.2.0.5.0/instantclient-sdk-10.2.0.5.0-linux.zip /usr/local/src/
# PECL OCI8
COPY oci8-1.4.10.tar /usr/local/src/
# PHP
RUN cd /usr/local/src && \
    wget -O php-5.3.29.tar.gz http://de1.php.net/get/php-5.3.29.tar.gz/from/this/mirror --no-check-certificate

# install Apache2
RUN apt-get install -y \
    apache2

RUN apt-get clean -y

# install dependencies
RUN apt-get -y install apache2 php5 php5-common php5-cli php5-mysql php5-gd php5-mcrypt php5-curl libapache2-mod-php5 php5-xmlrpc mysql-server mysql-client
RUN apt-get -y install build-essential php5-dev libbz2-dev libmysqlclient-dev libxpm-dev libmcrypt-dev libcurl4-gnutls-dev libxml2-dev libjpeg-dev libpng12-dev
RUN apt-get -y install flex libc-client-dev autoconf gcc
RUN apt-get -y install libmhash-dev libmcrypt-dev
RUN apt-get -y install zlib1g-dev libbz2-dev
RUN apt-get -y install libtidy-dev libldap2-dev libcurl4-gnutls-dev
RUN apt-get -y install libmysqlclient-dev libpq-dev
RUN apt-get -y install mysql-client mysql-server
RUN apt-get -y install php5-dev

# PECL OCI8
COPY oci8-1.4.3.tgz /usr/local/src/

ADD instantclient-10.2.0.5.0/* /usr/local/src/

RUN apt-get install -y gcc-multilib libc6-dev linux-libc-dev

# compile oci client
ADD compile-oci8-instantclient.sh /usr/local/src/
RUN chmod u+x /usr/local/src/compile-oci8-instantclient.sh
RUN /usr/local/src/compile-oci8-instantclient.sh

# compile php
COPY compile-php.sh /usr/local/src/
RUN chmod u+x /usr/local/src/compile-php.sh
RUN /usr/local/src/compile-php.sh

COPY apache_default /etc/apache2/sites-available/default
COPY run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
RUN a2enmod rewrite

EXPOSE 80
EXPOSE 443
CMD ["/usr/local/bin/run"]
