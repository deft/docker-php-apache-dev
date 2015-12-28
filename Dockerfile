FROM php:7.0-apache

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
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install bcmath exif gd intl opcache mbstring pdo_mysql soap zip

RUN pecl install -o -f apcu-5.1.0 \
        && echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

RUN     pecl install -o -f xdebug-2.4.0beta1  \
        && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini

RUN    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.*/bin-Q16/* /usr/local/bin/ \
        && mkdir -p /tmp/imagick \
        && cd /tmp/imagick \
        && git clone https://github.com/mkoppanen/imagick.git . \
        && git checkout phpseven \
        && phpize \
        && ./configure --with-imagick=/opt/local \
        && make \
        && make install \
        && echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/imagick.so" > /usr/local/etc/php/conf.d/imagick.ini \
        && cd / && rm -rf /tmp/imagick


#RUN ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.*/bin-Q16/* /usr/local/bin/ \
#        && pecl install -o -f imagick-3.3.0RC2 \
#        && echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/imagick.so" > /usr/local/etc/php/conf.d/imagick.ini \
#        && rm -rf /tmp/pear

VOLUME /tmp
RUN a2enmod rewrite
RUN rm /etc/apache2/mods-enabled/alias.conf
COPY apache.conf /etc/apache2/sites-enabled/000-default.conf
COPY php.ini /usr/local/etc/php/
WORKDIR /source

