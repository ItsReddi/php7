FROM php:7.0.15-fpm
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev unzip git sudo
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

#PHP REDIS
ENV PHPREDIS_VERSION 3.0.0
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

RUN apt-get install -y curl && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get upgrade -y && \
    apt-get install -y ntp

RUN rm -r /var/lib/apt/lists/*

RUN mkdir /var/www/.composer && chown www-data:www-data /var/www/.composer
RUN sudo -u www-data composer global require "fxp/composer-asset-plugin:~1.2"

###Timezone tricks
#RUN echo "Europe/Berlin" > /etc/timezone
#RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
#RUN dpkg-reconfigure -f noninteractive tzdata

COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY conf/www.conf /usr/local/etc/php-fpm.d/


###Environments defaults
ENV PHP_SESSION_SAVE_HANDLER files
ENV PHP_SESSION_SAVE_PATH /tmp
ENV PHP_OP_CACHE_ENABLE 1
ENV PHP_OP_CACHE_REVALIDATE_FREQ 600

#ports
EXPOSE 9000
