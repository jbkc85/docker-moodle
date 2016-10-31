FROM php:7.0-apache
MAINTAINER Jason Cameron <jbkc85@gmail.com>

ENV MOODLE_VERSION=31 \
    MOODLE_GITHUB=https://github.com/moodle/moodle.git \
    MOODLE_DESTINATION=/var/www/html

# Download Essential Packages
RUN apt-get update \
    && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
                          graphviz aspell libpspell-dev git-core \
    && apt-get install -y libicu-dev libxml2-dev libcurl4-openssl-dev \
                          libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install intl pdo pdo_mysql xmlrpc curl pspell \
                              ldap zip pdo_pgsql gd opcache \
    && docker-php-ext-enable intl pdo pdo_mysql pdo_pgsql xmlrpc curl \
                             pspell ldap zip gd opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# Copy in and make default content areas
COPY php.ini /usr/local/etc/php
RUN mkdir -p /var/moodledata && \
    git clone -b MOODLE_${MOODLE_VERSION}_STABLE --depth 1 ${MOODLE_GITHUB} ${MOODLE_DESTINATION}

# Enable mod_rewrite
RUN a2enmod rewrite
