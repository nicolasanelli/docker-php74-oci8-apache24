#######################################
#  Imagem com base no Ubuntu focal,
#  contendo PHP 7.4, Apache 2.4.38, e
#   oracle instant-client 18.5 (oci)
#######################################
FROM ubuntu:20.04
MAINTAINER nicolasanelli

#ENV APACHE_DOCUMENT_ROOT /hadrion/qualis/home
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
#ENV TZ=America/Sao_Paulo
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_18_5

# Atualizando o cache do repositório apt
RUN apt-get update

# Configurando o timezone
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
#    apt-get install -y tzdata && \
#    dpkg-reconfigure -f noninteractive tzdata

# Instalando o PHP 7.4 (Apache2 é instalado junto)
RUN apt-get install php7.4 php-pear php7.4-dev -y

## Habilitando reescrita de URL do apache
RUN a2enmod rewrite

# Instalando ferramentas necessárias
RUN apt-get install --no-install-recommends -y \
        zip unzip

# Adicionando conteúdo do oci-18.5
ADD oci/x64-18.5.0.0.0/ /opt/oracle/
RUN unzip /opt/oracle/instantclient-basiclite-linux.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.zip -d /opt/oracle \
    && ln -sfn /opt/oracle/instantclient_18_5/libclntsh.so.18.1 /opt/oracle/instantclient_18_5/libclntsh.so \
    && ln -sfn /opt/oracle/instantclient_18_5/libclntshcore.so.18.1 /opt/oracle/instantclient_18_5/libclntshcore.so \
    && ln -sfn /opt/oracle/instantclient_18_5/libocci.so.18.1 /opt/oracle/instantclient_18_5/libocci.so \
    && rm -rf /opt/oracle/*.zip

## Instalando oci pdo_oci para o PHP
RUN apt-get install --no-install-recommends libaio-dev -y \
    && echo 'instantclient,/opt/oracle/instantclient_18_5' | pecl install oci8-2.2.0 \
    &&  echo "extension=oci8.so" > /etc/php/7.4/cli/conf.d/oci8.ini \
    &&  echo "extension=oci8.so" > /etc/php/7.4/apache2/conf.d/oci8.ini \
    && echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_18_5" >> /etc/apache2/envvars

## Instalando extensões do ldap
RUN apt-get install --no-install-recommends libldap2-dev php7.4-ldap -y

## Instalando extensões do GD (para relatórios e manipulação de imagens)
RUN apt-get install --no-install-recommends zlib1g-dev \
    libfreetype6-dev libjpeg-turbo8-dev libpng-dev php7.4-gd -y

## Instalando extensões do zip
RUN apt-get install --no-install-recommends libzip-dev php7.4-zip -y

## Instalando extensões do curl
RUN apt-get install --no-install-recommends php7.4-curl -y

## Instalando extensões do mbstring
RUN apt-get install --no-install-recommends php7.4-mbstring -y

RUN echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Limpando repositório
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD /usr/sbin/apache2ctl -D FOREGROUND
