FROM alpine:3.23.4

# Build metadata arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# OCI annotations
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.authors=""
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.documentation=""
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.title="Typemill, PHP, Nginx & SSL on Alpine Linux"
LABEL org.opencontainers.image.description="Minimal image with Nginx, SSL certs & PHP-FPM 8.3 (with required extensions and depencies for Typemill CMS), based on Alpine Linux."

# PHP is version 8.3 because not all Typemill plugins support newer versions yet
# libjpeg-dev replaced with libjpeg-turbo-dev
# php83-phar for composer

RUN apk update --no-cache && apk add --no-cache \
    ca-certificates \
    curl \
    htop \
    libjpeg-turbo-dev \
    libpng-dev \
    nginx \
    openssl \
    php83 \
    php83-common \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-fpm \
    php83-gd \
    php83-iconv \
    php83-mbstring \
    php83-openssl \
    php83-phar \
    php83-session \
    php83-soap \
    php83-sqlite3 \
    php83-xml \
    php83-zip \
    supervisor \
    tzdata \
    unzip \
    zlib-dev 

# Create alias to php
RUN ln -s /usr/bin/php83 /usr/bin/php

# Setup document root
WORKDIR /var/www/html

# Make sure files/folders needed by the processes are accessable
RUN chown -R nobody:nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Download and extract the Typemill source
ENV TYPEMILL_VERSION=2.23.1
RUN curl -L -o /tmp/typemill.zip https://github.com/typemill/typemill/archive/refs/tags/v${TYPEMILL_VERSION}.zip && \
unzip /tmp/typemill.zip -d /tmp/ && mv /tmp/typemill-${TYPEMILL_VERSION}/* /var/www/html/ && \
rm -rf /tmp/typemill* && chown -R nobody:nobody /var/www/html/

RUN [ -f system/typemill/author/js/vue.js ] \
 && [ -f system/typemill/author/js/vue.global.prod.js ] \
 && mv system/typemill/author/js/vue.global.prod.js system/typemill/author/js/vue.js

# Apply a "PHP min version" fix to composer.json, as a depency needs this to be set to at least 8.2 - we're installing 8.3 anyway
RUN sed -i 's/"php": "8.1.0"/"php": "8.3.0"/g' composer.json && \ 
sed -i 's/"php": "\^8.1"/"php": "\^8.3"/g' composer.json

# Install Composer for php depency management, using Typemill repo's script
RUN chmod +x /var/www/html/docker-utils/install-composer && \
    /var/www/html/docker-utils/install-composer && \
    ./composer.phar update && \
    chmod +x /var/www/html/docker-utils/init-server

# Create a default copy of content and theme in case of empty directories binding
RUN mkdir -p /var/www/html/content.default/ && \
    cp -R /var/www/html/content/* /var/www/html/content.default/ && \
    mkdir -p /var/www/html/themes.default/ && \
    cp -R /var/www/html/themes/* /var/www/html/themes.default/ && \
    mkdir -p /var/www/html/media.default/ && \
    cp -R /var/www/html/media/* /var/www/html/media.default/ && \
    mkdir -p /var/www/html/settings.default/ && \
    cp -R /var/www/html/settings/* /var/www/html/settings.default/ && \
    mkdir -p /var/www/scripts

# mount data from persistent storage if not empty
RUN find /var/www/html/content -type d -empty -exec cp -R /var/www/html/content.default/* /var/www/html/content \; && \
    find /var/www/html/themes -type d -empty -exec cp -R /var/www/html/themes.default/* /var/www/html/themes \; && \
    find /var/www/html/media -type d -empty -exec cp -R /var/www/html/media.default/* /var/www/html/media \;

RUN if [ -z "$(ls -A /var/www/html/settings)" ]; then \
        cp -R /var/www/html/settings.default/* /var/www/html/settings/ ; \
    fi

# Fix ownership (in case of new folders)
RUN chown -R nobody:nobody /var/www/

# Switch to the nonprivileged user
USER nobody

EXPOSE 80
EXPOSE 443

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping || exit 1