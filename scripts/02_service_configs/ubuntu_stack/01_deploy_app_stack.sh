#!/usr/bin/env bash
# 01_deploy_app_stack.sh
# Turnkey deployment of LAMP Stack, MariaDB, GLPI 10.0, and BookStack on APP-UBU-01 (10.10.10.20)

set -euo pipefail

echo "========================================================="
echo " Deploying Core Application Stack on APP-UBU-01 (Ubuntu) "
echo " Tools: Apache2, MariaDB 10.6, PHP 8.1, GLPI 10, BookStack"
echo "========================================================="

export DEBIAN_FRONTEND=noninteractive

echo "--> [1/6] Updating system repositories & installing LAMP dependencies..."
apt update && apt upgrade -y
apt install -y apache2 mariadb-server curl wget unzip git \
  php8.1 php8.1-curl php8.1-gd php8.1-intl php8.1-mbstring \
  php8.1-mysql php8.1-xml php8.1-zip php8.1-bz2 php8.1-ldap \
  php8.1-cli php8.1-soap php8.1-bcmath libapache2-mod-php8.1

echo "--> [2/6] Configuring MariaDB Databases & Service..."
systemctl enable --now mariadb

mariadb -e "CREATE DATABASE IF NOT EXISTS glpidb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb -e "CREATE USER IF NOT EXISTS 'glpiuser'@'localhost' IDENTIFIED BY 'Guardian@2026_\$';"
mariadb -e "GRANT ALL PRIVILEGES ON glpidb.* TO 'glpiuser'@'localhost';"

mariadb -e "CREATE DATABASE IF NOT EXISTS bookstackdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb -e "CREATE USER IF NOT EXISTS 'bookstackuser'@'localhost' IDENTIFIED BY 'Guardian@2026_\$';"
mariadb -e "GRANT ALL PRIVILEGES ON bookstackdb.* TO 'bookstackuser'@'localhost';"
mariadb -e "FLUSH PRIVILEGES;"

echo "--> [3/6] Downloading & Installing GLPI 10.0.16..."
GLPI_VER="10.0.16"
cd /tmp
wget -c "https://github.com/glpi-project/glpi/releases/download/${GLPI_VER}/glpi-${GLPI_VER}.tgz"
tar -xzf "glpi-${GLPI_VER}.tgz" -C /var/www/html/
chown -R www-data:www-data /var/www/html/glpi
chmod -R 755 /var/www/html/glpi

echo "--> [4/6] Installing Composer & BookStack..."
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

cd /var/www
if [ ! -d "/var/www/bookstack" ]; then
    git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch bookstack
    cd /var/www/bookstack
    composer install --no-dev --no-plugins --quiet
    cp .env.example .env
    sed -i "s|APP_URL=.*|APP_URL=http://10.10.10.20:8080|g" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=bookstackdb|g" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=bookstackuser|g" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=Guardian@2026_\$|g" .env
    php artisan key:generate --no-interaction --force
    php artisan migrate --no-interaction --force
    chown -R www-data:www-data /var/www/bookstack
    chmod -R 755 /var/www/bookstack/storage /var/www/bookstack/bootstrap/cache /var/www/bookstack/public/uploads
fi

echo "--> [5/6] Configuring Apache VirtualHosts & PHP Extensions..."
a2enmod rewrite
a2enmod php8.1

# Configure BookStack on Port 8080
if ! grep -q "Listen 8080" /etc/apache2/ports.conf; then
    echo "Listen 8080" >> /etc/apache2/ports.conf
fi

cat << 'EOF' > /etc/apache2/sites-available/bookstack.conf
<VirtualHost *:8080>
    ServerName wiki.thinkpolaris.local
    ServerAdmin admin@thinkpolaris.local
    DocumentRoot /var/www/bookstack/public

    <Directory /var/www/bookstack/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/bookstack-error.log
    CustomLog ${APACHE_LOG_DIR}/bookstack-access.log combined
</VirtualHost>
EOF

a2ensite bookstack.conf
systemctl restart apache2

echo "========================================================="
echo " [SUCCESS] Application Stack Deployed on APP-UBU-01!"
echo " GLPI Helpdesk:  http://10.10.10.20/glpi"
echo " BookStack Wiki: http://10.10.10.20:8080"
echo "========================================================="
