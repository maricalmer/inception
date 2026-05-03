FROM debian:12

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Override PHP-FPM config
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php /var/www/adminer

RUN curl -L https://www.adminer.org/latest.php -o /var/www/adminer/index.php

RUN chown -R www-data:www-data /var/www/adminer

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
