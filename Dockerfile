FROM php:7.1.1-fpm
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev unzip git
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libicu-dev \
        zlib1g-dev \
        g++ \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mysqli pdo pdo_mysql intl opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install -j$(nproc) imap

RUN apt-get install -y curl && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get upgrade -y && \
    apt-get install -y ntp

RUN rm -r /var/lib/apt/lists/*

RUN composer global require "fxp/composer-asset-plugin:~1.1.1"

###Timezone tricks
#RUN echo "Europe/Berlin" > /etc/timezone
#RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
#RUN dpkg-reconfigure -f noninteractive tzdata

COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY conf/www.conf /usr/local/etc/php-fpm.d/

#ports
EXPOSE 9000

#onstart
#CMD ["/bin/bash", "/init.sh"]
