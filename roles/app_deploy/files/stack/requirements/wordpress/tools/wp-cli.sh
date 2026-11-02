#!/bin/sh


# Create a directory for WordPress
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
cd /var/www/html


# Check if WordPress is already installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
  echo "WordPress not found, downloading..."
  # Download WordPress
  wp core download --allow-root



  # Wait for MariaDB to be ready
  echo "Waiting for MariaDB to be ready..."
  until mysql -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -hmariadb -P3306 "$DB_NAME" -e "SELECT 1" 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 1
  done
  echo "MariaDB is ready!"

  # generate a config file (wp-config.php) and set up the database
  wp config create \
    --allow-root \
    --dbname="${WORDPRESS_DB_NAME}" \
    --dbuser="${WORDPRESS_DB_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}"

  # Install WordPress
  echo "Installing WordPress..."
  wp core install \
    --allow-root \
    --url="${WORDPRESS_SITE_URL}" \
    --title="${WORDPRESS_SITE_TITLE}" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}"



  echo "Creating additional user..."
  wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
    --user_pass="${WORDPRESS_USER_PASSWORD}" \
    --allow-root

  echo "✅ WordPress installation completed!"

  chown -R www-data:www-data /var/www/html
  chmod -R 775 /var/www/html
else
  echo "WordPress already installed, skipping setup"

  chown -R www-data:www-data /var/www/html
  chmod -R 775 /var/www/html
fi

# Install and configure required plugin if not already installed
if [ ! -d "/var/www/html/wp-content/plugins/redis-cache" ]; then
  echo "removing default plugins..."
  wp plugin delete --all
  echo "Installing Redis Cache plugin..."
  wp plugin install redis-cache --activate --allow-root

  # add Redis configuration to wp-config.php
  wp config set WP_REDIS_HOST "${WP_REDIS_HOST}" --allow-root
  wp config set WP_REDIS_PORT "${WP_REDIS_PORT}" --allow-root
  wp config set WP_CACHE "${WP_CACHE}" --allow-root
  wp redis enable --allow-root

  echo "✅ Redis Cache plugin installed and configured!"
else
  echo "Redis Cache plugin already installed, skipping installation"
fi



# Configure php-fpm to listen on port 9000
sed -i 's/listen = .*/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf

# Start PHP-FPM
echo "Starting PHP-FPM..."

exec php-fpm8.2 -F
