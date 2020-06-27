FROM drupal

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-url="https://github.com/yusufhm/docker-drupal-composer" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.schema-version="0.1.0"

# Install composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=bin --filename=composer && \
    rm composer-setup.php && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /etc/profile && \
    composer global require hirak/prestissimo
