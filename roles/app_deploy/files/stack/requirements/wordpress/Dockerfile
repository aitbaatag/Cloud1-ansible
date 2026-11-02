FROM debian:bookworm

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    wget \
    php \
    php8.2-fpm \
    php-mysql \
    redis-tools \
    vsftpd \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*


# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Stores PHP-FPM’s PID 
RUN mkdir -p /run/php

COPY /tools/wp-cli.sh ./wp-cli.sh
RUN chmod +x ./wp-cli.sh

EXPOSE 9000
CMD ["./wp-cli.sh"]
