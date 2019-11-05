FROM ubuntu:18.04
MAINTAINER Hoa Nguyen <ho@nguyenmanh.me>

# ENV
ENV DEBIAN_FRONTEND noninteractive
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV TZ         Asia/Saigon

# timezone and locale
RUN apt-get update \
    && apt-get install -y software-properties-common \
        language-pack-en-base sudo \
        apt-utils tzdata locales \
        curl wget gcc g++ make autoconf libc-dev pkg-config \
    && locale-gen en_US.UTF-8 \
    && echo $TZ > /etc/timezone \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get autoclean \
    && rm -vf /var/lib/apt/lists/*.* /tmp/* /var/tmp/*

# nginx php
RUN add-apt-repository -y ppa:nginx/stable \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y build-essential \
    zlib1g-dev \
    vim \
    unzip \
    sudo \
    dialog \
    net-tools \
    git \
    supervisor \
    nginx \
    php7.3-common \
    php7.3-dev \
    php7.3-fpm \
    php7.3-bcmath \
    php7.3-curl \
    php7.3-gd \
    php7.3-geoip \
    php7.3-imagick \
    php7.3-intl \
    php7.3-json \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-memcache \
    php7.3-memcached \
    php7.3-mongo \
    php7.3-mysqlnd \
    php7.3-pgsql \
    php7.3-redis \
    php7.3-sqlite \
    php7.3-xml \
    php7.3-xmlrpc \
    php7.3-zip \
    php7.3-soap \
    php7.3-xdebug \
    php7.3-amqp \
&& phpdismod xdebug opcache \
&& mkdir /run/php && chown www-data:www-data /run/php \
&& apt-get autoclean \
&& rm -vf /var/lib/apt/lists/*.* /var/tmp/*

# configuration
COPY conf/nginx/vhost.conf /etc/nginx/sites-available/default
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/php73/php.ini /etc/php/7.3/fpm/php.ini
COPY conf/php73/cli.php.ini /etc/php/7.3/cli/php.ini
COPY conf/php73/php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf
COPY conf/php73/www.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY conf/supervisor/supervisord.conf /etc/supervisord.conf

# Start Supervisord
COPY ./start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 80 443

CMD ["/bin/bash", "/start.sh"]
