FROM php:8.0.2-apache

ARG BUILD_DATE
ARG VCS_REF

ENV APACHE_DOCUMENT_ROOT /var/www/docroot

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-url="https://github.com/yusufhm/docker-drupal-base" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.schema-version="0.1.0"

RUN set -eux && \
    \
    \
    # Configure apache & php.
    sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php-cli.ini && \
    echo "memory_limit = -1" >> /usr/local/etc/php/php-cli.ini && \
    \
    \
    # Install composer.
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /etc/profile && \
    \
    \
    # Install dependencies.
    apt-get update && apt-get install -y \
    libfreetype6-dev libjpeg62-turbo-dev libmemcached-dev \
    mariadb-client libpng-dev libzip-dev unzip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pecl install apcu && \
    pecl install memcached-3.1.5 && \
    docker-php-ext-enable apcu && \
    docker-php-ext-enable memcached && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install zip && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install opcache && \
    apt-get purge -y libfreetype6-dev libjpeg62-turbo-dev libmemcached-dev \
    libpng-dev libzip-dev zlib1g-dev && \
    a2enmod rewrite && \
    \
    \
    # Install drush launcher.
    curl -OL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush && \
    cd /var/www && \
    \
    \
    # Create drupal user.
    adduser --disabled-password --gecos "" --uid 1000 drupal && \
    usermod -aG www-data drupal && \
    rmdir /var/www/html && \
    mkdir -p /var/www/docroot/sites/default/files && \
    chown -R drupal\: /var/www && \
    chown -R www-data\: /var/www/docroot/sites/default/files

WORKDIR /var/www

USER drupal
