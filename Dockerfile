FROM php:7.0.15-fpm

ENV PHPREDIS_VERSION 3.1.1
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts

RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
        unzip git sudo ntp openssh-client \
        libc-client-dev \ 
        libkrb5-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libicu-dev \
        zlib1g-dev \
        g++ \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mysqli pdo pdo_mysql intl opcache redis \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install -j$(nproc) imap \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get remove --purge -y g++\
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN mkdir /var/www/.composer \
    && chown www-data:www-data /var/www/.composer \
    && sudo -u www-data composer global require "fxp/composer-asset-plugin:~1.2"

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
ENV PHP_OP_CACHE_SAVE_COMMENTS 1

#ports
EXPOSE 9000
