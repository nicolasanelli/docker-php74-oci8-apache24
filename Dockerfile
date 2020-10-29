#######################################
#  Based on Ubuntu focal,
#  contains PHP 7.4, Apache 2.4.38, and
#   oracle instant-client 18.5 (oci)
#######################################
FROM ubuntu:20.04
MAINTAINER nicolasanelli

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_18_5

## Updating apt repository
RUN apt-get update

## Installing PHP 7.4 (Apache2 é also installed)
RUN apt-get install php7.4 php-pear php7.4-dev -y

## Enable apache URL rewrite
RUN a2enmod rewrite

## Installing zip tools
RUN apt-get install --no-install-recommends -y \
        zip unzip

## Adding oci drivers
ADD oci/x64-18.5.0.0.0/ /opt/oracle/
RUN unzip /opt/oracle/instantclient-basiclite-linux.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.zip -d /opt/oracle \
    && ln -sfn /opt/oracle/instantclient_18_5/libclntsh.so.18.1 /opt/oracle/instantclient_18_5/libclntsh.so \
    && ln -sfn /opt/oracle/instantclient_18_5/libclntshcore.so.18.1 /opt/oracle/instantclient_18_5/libclntshcore.so \
    && ln -sfn /opt/oracle/instantclient_18_5/libocci.so.18.1 /opt/oracle/instantclient_18_5/libocci.so \
    && rm -rf /opt/oracle/*.zip

## Installing PHP oci pdo_oci
RUN apt-get install --no-install-recommends libaio-dev -y \
    && echo 'instantclient,/opt/oracle/instantclient_18_5' | pecl install oci8-2.2.0 \
    && echo "extension=oci8.so" > /etc/php/7.4/cli/conf.d/oci8.ini \
    && echo "extension=oci8.so" > /etc/php/7.4/apache2/conf.d/oci8.ini \
    && echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_18_5" >> /etc/apache2/envvars

## Installing ldap drivers, extensions and libs
RUN apt-get install --no-install-recommends libldap2-dev php7.4-ldap -y

## Installing GD libs (for pdf and image manipulation)
RUN apt-get install --no-install-recommends zlib1g-dev \
    libfreetype6-dev libjpeg-turbo8-dev libpng-dev php7.4-gd -y

## Installing PHP zip
RUN apt-get install --no-install-recommends libzip-dev php7.4-zip -y

## Installing PHP curl 
RUN apt-get install --no-install-recommends php7.4-curl -y

## Installing mbstring
RUN apt-get install --no-install-recommends php7.4-mbstring -y

## Installing pdftk
RUN apt-get install --no-install-recommends pdftk -y

## Installing poppler-utils (pdftotext)
RUN apt-get install --no-install-recommends poppler-utils -y

RUN echo "<?php phpinfo(); ?>" > /var/www/html/info.php

## Cleaning apt repo
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Defining default command to be executed on container run
CMD /usr/sbin/apache2ctl -D FOREGROUND
