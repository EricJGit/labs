ARG PHP_IMAGE=php:8-fpm

FROM ${PHP_IMAGE} as php

ARG USER_ID=1001
ARG USER_NAME=php
ARG GROUP_ID=1001
ARG GROUP_NAME=php

RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} \
    && useradd -m -u ${USER_ID} -g ${GROUP_NAME} ${USER_NAME}

# Maj list paquet
RUN apt-get update \
    && apt-get install -y zsh wget supervisor \
    # AMQP
    && apt-get install -y librabbitmq-dev libssh-dev unzip \
    && docker-php-source extract \
    # PHP-AMQP master compile
    && mkdir /usr/src/php/ext/amqp \
    && curl -L https://github.com/php-amqp/php-amqp/archive/master.tar.gz | tar -xzC /usr/src/php/ext/amqp --strip-components=1 \
    && docker-php-ext-install amqp \
     # Protobuf compiler install
    && curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/protoc-3.14.0-linux-x86_64.zip \
    && mkdir /opt/protoc \
    && unzip protoc-3.14.0-linux-x86_64.zip -d /opt/protoc \
    && chown -R ${USER_NAME}:${GROUPE_NAME} /opt/protoc \
    && chmod +X /opt/protoc/bin/protoc \
    # PHP protobuf install
    && mkdir -p /usr/src/php/ext/protobuf/third_party/wyhash /tmp/protobuf \
    && curl -L https://github.com/protocolbuffers/protobuf/archive/master.tar.gz | tar -xzC /tmp/protobuf --strip-components=1 protobuf-master \
    && cp -R /tmp/protobuf/php/ext/google/protobuf/* /usr/src/php/ext/protobuf/ \
    && cp /tmp/protobuf/third_party/wyhash/* /usr/src/php/ext/protobuf/third_party/wyhash \
    && docker-php-ext-install protobuf \
    && docker-php-source delete \
    # XDdebug
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    ## Driver pgsql
    && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    # zip
    && apt-get install -y zlib1g-dev libzip-dev \
    && docker-php-ext-install zip \
    # Git
    && apt-get -y install git \
    # Node
    && apt-get -y install gnupg \
    && curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g serverless

ENV PATH="/opt/protoc/bin:${PATH}"

ARG XdebugFile=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "xdebug.mode=develop" >> $XdebugFile \
    && echo "xdebug.start_with_request=on" >> $XdebugFile \
    && echo "xdebug.discover_client_host=on" >> $XdebugFile

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# clean
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV MESSENGER_TRANSPORT_DSN=amqp://rabbitmq:rabbitmq@rabbit:5672
ENV PATH "$PATH:/var/www/html/"

RUN chown -R ${USER_NAME}:${GROUP_NAME} /var/log/supervisor/

USER ${USER_ID}

ENV TERM xterm
ENV ZSH_THEME agnoster

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true


#FROM php as rabbit-consumer

#WORKDIR /var/www/html/docker/rabbit-consumer/

#CMD ["./rabbitmq-consumer"]

#FROM lambci/lambda:build-provided.al2 as lambda

#COPY docker/lambda/Dockerfile ./

#CMD docker build -t php . && docker run php
#CMD docker run php