FROM php:5.6-apache

RUN useradd deft -m -p deft -s /bin/bash && apt-get update && apt-get install -y --no-install-recommends \
        acl \
        curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libxml2-dev \
        libicu-dev \
        libmagick++-dev \
        nodejs \
        npm \
        ant \
        git \
        pdftk \
        netcat \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install bcmath bz2 exif gd intl opcache mbstring pdo_mysql soap zip \
    && pecl install -o -f apcu-4.0.10 \
    && echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
    && pecl install -o -f xdebug  \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \
    && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.*/bin-Q16/* /usr/local/bin/ \
    && pecl install -o -f imagick \
    && echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/imagick.so" > /usr/local/etc/php/conf.d/imagick.ini \
    && rm -rf /tmp/pear \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo

RUN ln -s /usr/bin/nodejs /usr/bin/node
VOLUME /tmp
RUN a2enmod rewrite
RUN rm /etc/apache2/mods-enabled/alias.conf
COPY apache.conf /etc/apache2/sites-enabled/000-default.conf
COPY php.ini /usr/local/etc/php/
WORKDIR /source

