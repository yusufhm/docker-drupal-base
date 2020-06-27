FROM drupal:8.8

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-url="https://github.com/yusufhm/docker-drupal-composer" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.schema-version="0.1.0"

# Install additional dependencies.
RUN set -eux; \
    apt-get update && apt-get install -y git libmemcached-dev zip zlib1g-dev \
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
