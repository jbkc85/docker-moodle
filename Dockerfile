FROM ubuntu:16.04
MAINTAINER Jason Cameron <jbkc85@gmail.com>

ENV MOODLE_VERSION=31 \
    MOODLE_GITHUB=https://github.com/moodle/moodle.git \
    MOODLE_DESTINATION=/var/www/moodle

ENV APACHE_CONFDIR /etc/apache2 \
    APACHE_ENVVARS $APACHE_CONFDIR/envvars

# Download Essential Packages
RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install apache2 php libapache2-mod-php7.0 && \
    apt-get -y install graphviz aspell php7.0-pspell php7.0-curl \
                    php7.0-gd php7.0-intl php7.0-mysql php7.0-xmlrpc \
                    php7.0-ldap php7.0-zip php7.0-pgsql && \
    apt-get -y install git-core && \
    apt-get clean && rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# Copy in and make default content areas
COPY rootfs /
RUN mkdir -p /var/www /var/moodledata && \
    git clone -b MOODLE_${MOODLE_VERSION}_STABLE --depth 1 ${MOODLE_GITHUB} ${MOODLE_DESTINATION}

# Disable mpm_event and re-enable mpm_prefork for apache
# Ensure apache2-foreground is executable
RUN a2dismod mpm_event && a2enmod mpm_prefork && \
    chmod +x /apache2-foreground

EXPOSE 80 443
CMD ["apache2-foreground"]
