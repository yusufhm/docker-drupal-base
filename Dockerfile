FROM drupal:8.8

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-url="https://github.com/yusufhm/docker-drupal-composer" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.schema-version="0.1.0"

# Install additional dependencies.
RUN set -eux; \
    apt-get update && apt-get install -y git libmemcached-dev mariadb-client rsync zip zlib1g-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached; \
    apt-get purge -y --auto-remove zlib1g-dev; \
    rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install bcmath

# Install composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /etc/profile && \
    composer global require hirak/prestissimo

# Install nvm.
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
    nvm install stable --lts

# Web server config.
RUN sed -i 's_/var/www/html_/var/www/docroot_' /etc/apache2/sites-enabled/000-default.conf && \
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    echo "memory_limit = -1" > /usr/local/etc/php/php.ini && \
    mkdir -p ~/.ssh && ln -s /run/secrets/host_ssh_key ~/.ssh/id_rsa
