#!/bin/bash

set -e

read_secret() {
    local path="$1"

    if [ ! -f "$path" ]; then
        echo "Missing Docker secret: $path" >&2
        exit 1
    fi
    tr -d '\r\n' < "$path"
}

MYSQL_PASSWORD="$(read_secret /run/secrets/mysql_password)"
WP_ADMIN_PASSWORD="$(read_secret /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(read_secret /run/secrets/wp_user_password)"

cd /var/www/html

WP_CLI="wp --allow-root --path=/var/www/html"

echo "Waiting for MariaDB..."
until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done

echo "MariaDB is ready."

if [ ! -f /usr/local/bin/wp ]; then
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x /usr/local/bin/wp
fi

if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    $WP_CLI core download

    echo "Creating wp-config.php with the database connection settings..."
    $WP_CLI config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    echo "Add Redis cache settings..."
    $WP_CLI config set WP_REDIS_HOST "${REDIS_HOST}"
    $WP_CLI config set WP_REDIS_PORT "${REDIS_PORT}" --raw
    $WP_CLI config set WP_CACHE true --raw

    echo "Installing WordPress..."
    $WP_CLI core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    echo "Installing Redis plugin..."
    $WP_CLI plugin install redis-cache --activate
    $WP_CLI redis enable || true

    echo "Creating second WordPress user..."
    $WP_CLI user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F
