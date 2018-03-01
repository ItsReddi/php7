FROM php:7.0.16-fpm-alpine

###Environments defaults
ENV PHP_SESSION_SAVE_HANDLER files
ENV PHP_SESSION_SAVE_PATH /tmp
ENV PHP_OP_CACHE_ENABLE 1
ENV PHP_OP_CACHE_REVALIDATE_FREQ 600
ENV PHP_OP_CACHE_SAVE_COMMENTS 1
ENV PHPREDIS_VERSION 3.1.1

###Get redis php extension
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts

RUN apk upgrade --update \
&& apk add --no-cache --virtual .app-deps \
   unzip git sudo \
&& apk add --no-cache --virtual .dynamic-deps \
   freetype-dev \
   libjpeg-turbo-dev \
   libpng-dev \
   libmcrypt-dev \
   icu-dev \
   openssl-dev \
   krb5-dev \
   curl-dev \
   imap-dev \
&& apk add --no-cache --virtual .build-deps \
   autoconf \
   g++ \
   make \
&& docker-php-ext-install \ 
   iconv mcrypt mbstring mysqli pdo_mysql curl session zip intl opcache redis \
&& docker-php-ext-configure \
   gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
&& docker-php-ext-install \
   gd \
&& docker-php-ext-configure \
   imap --with-imap-ssl --with-kerberos \
&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
##CLEANUP
&& apk del .build-deps \
&& find / -type f -iname \*.apk-new -delete \
&& rm -rf /var/cache/apk/*

### install fxp globally used for php bower assets
RUN mkdir /var/www/.composer \
    && chown www-data:www-data /var/www/.composer \
    && sudo -u www-data composer global require "fxp/composer-asset-plugin:~1.2"

###Timezone tricks
#RUN echo "Europe/Berlin" > /etc/timezone
#RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
#RUN dpkg-reconfigure -f noninteractive tzdata

COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-cli.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY conf/www.conf /usr/local/etc/php-fpm.d/

#ports
EXPOSE 9000
