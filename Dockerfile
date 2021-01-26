FROM php:8-fpm as php

ARG USER_ID=1001
ARG GROUP_ID=1001

RUN groupadd -g ${GROUP_ID} php \
    && useradd -m -u ${USER_ID} -g php php

# Maj list paquet
RUN apt-get update \
    # AMQP
    && apt-get install -y librabbitmq-dev libssh-dev \
    && docker-php-source extract \
    && mkdir /usr/src/php/ext/amqp \
    && curl -L https://github.com/php-amqp/php-amqp/archive/master.tar.gz | tar -xzC /usr/src/php/ext/amqp --strip-components=1 \
    && docker-php-ext-install amqp \
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
ENV PATH "$PATH:/var/www/html/no"

USER ${USER_ID}

FROM php as rabbit-consumer

WORKDIR /var/www/html/docker/rabbit-consumer/

CMD ["./rabbitmq-consumer"]

FROM lambci/lambda:build-provided.al2 as lambda

#COPY docker/lambda/Dockerfile ./

#CMD docker build -t php . && docker run php
CMD docker run php