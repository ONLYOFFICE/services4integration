FROM ubuntu:20.04

#ENV LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive

ENV LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive

EXPOSE 80 443

ARG EDUSOHO_VERSION="22.4.7"
ARG PHP_VER="7.1"

RUN    mkdir -p /var/www /run/php \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt install -y language-pack-en-base \
                      software-properties-common \
                      wget \
                      gcc \
                      make \
                      perl \
                      vim \
                      libmcrypt-dev \
                      mcrypt \
                      mysql-server \
    && add-apt-repository ppa:ondrej/php \
    && apt-get -y update \
    && apt-get -y install curl \
                       php-pear \
                       php${PHP_VER} \
                       php${PHP_VER}-mysql \
                       php${PHP_VER}-cli \
                       php${PHP_VER}-common \
                       php${PHP_VER}-curl \
                       php${PHP_VER}-dev \
                       php${PHP_VER}-fpm \
                       php${PHP_VER}-json \
                       php${PHP_VER}-mbstring \
                       php${PHP_VER}-mcrypt \
                       php${PHP_VER}-dev \
                       php${PHP_VER}-fpm \
                       php${PHP_VER}-json \
                       php${PHP_VER}-mbstring \
                       php${PHP_VER}-mcrypt \
                       php${PHP_VER}-xml \
                       php${PHP_VER}-gd \
                       nginx \
                       zip \
                       supervisor\
    && sed -i 's/listen = .*/listen = 127.0.0.1:9000/g' /etc/php/${PHP_VER}/fpm/pool.d/www.conf \
    && service php${PHP_VER}-fpm restart \
    && cd /var/www \
    && wget https://github.com/edusoho/edusoho/archive/refs/tags/v${EDUSOHO_VERSION}.zip \
    && unzip v${EDUSOHO_VERSION}.zip \
    && mv edusoho-${EDUSOHO_VERSION} edusoho \
    && cd edusoho \
    && mkdir -p app/cache app/logs app/data web/files \
    && chown -R www-data:www-data . \
    && chmod -R 777 . \
    && service nginx stop \
    && service mysql stop 

COPY edusoho.conf /app/edusoho/edusoho.conf
COPY entry.sh /app/edusoho/entry.sh

ENTRYPOINT ["/app/edusoho/entry.sh"]
