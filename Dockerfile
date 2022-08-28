FROM ubuntu:20.04 as base

ENV HOME /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8

RUN apt-get update -y && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:ondrej/php  && \
    apt-get update -y

RUN apt-get -y install php8.1 php-mysql php-curl php-mcrypt \
    php-cli php-dev php-pear libsasl2-dev wget php-zip unzip

RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

RUN wget -O composer-setup.php https://getcomposer.org/installer && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

FROM base AS build

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

RUN useradd -ms /bin/bash ubuntu

RUN chown -R ubuntu:ubuntu /usr/src/app 

USER ubuntu

COPY . /usr/src/app

RUN composer install

RUN php artisan fix:passport &&\
    php artisan migrate && \
    php artisan passport:install

CMD ["php", "artisan", "serve"]

ENV PORT 8000

EXPOSE 8000