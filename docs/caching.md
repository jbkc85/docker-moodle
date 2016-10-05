# Caching Support

## Memcached

Since Memcached is still in a beta version for PHP7, it is not yet supported in this base image.  If you want, you can always extend this image to support it by adding the following command to your own Dockerfile:

```
FROM jbkc85/moodle
MAINTAINER YOU <you@example.com>

# Update and grab new packages
RUN apt-get update && \
    apt-get install php7.0-dev zlib1g-dev libmemcached-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# Grab code, make and install
RUN git clone https://github.com/php-memcached-dev/php-memcached && \
    cd php-memcached && git checkout -b php7 origin/php7 && \
    phpize & ./configure & make install clean

# Drop in Config files
RUN echo 'extension=memcached.so' >> /etc/php/7.0/mods-available/memcached.ini && \
    ln -s /etc/php7.0/mods-available/memcached.ini /etc/php/7.0/apache/conf.d/memcached.ini && \
    ln -s /etc/php7.0/mods-available/memcached.ini /etc/php/7.0/cli/conf.d/memcached.ini
```

This will add the *ability* to connect to Memcached from your container.  It is not advised to run memcached in the same container due to the clustering and scaling ability of containers, rather spin up another memcached container and connect to it instead.

## MongoDB

## Redis
