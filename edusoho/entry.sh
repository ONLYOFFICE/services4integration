#!/bin/bash
TMP_DIR="/app/edusoho/"
HOME_DIR="/var/www/edusoho/"
PRIVATE_FILES=${HOME_DIR}/app/data/private_files
UDISK=${HOME_DIR}/app/data/udisk

# Prepare mysql dirs and  enable service
usermod -d /var/lib/mysql/ mysql
cp ${HOME_DIR}/app/config/parameters.yml.dist ${HOME_DIR}/app/config/parameters.yml
service mysql start

# Prepare some depends folders for EduSoho
mkdir -p ${PRIVATE_FILES}
mkdir -p ${UDISK}
chmod -R 777 ${HOME_DIR}/app/
chown www-data:www-data ${PRIVATE_FILES} ${UDISK}


# Create database and tables from edusoho.sql script
mysql -u "root" --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';"
mysql -u "root" --execute="FLUSH PRIVILEGES;"
mysql -uroot -e 'CREATE DATABASE `edusoho` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci'
mysql -u "root" --database="edusoho" < "/var/www/edusoho/web/install/edusoho.sql"

# Prepare nginx configs
rm -f /etc/nginx/sites-enabled/default
cp ${TMP_DIR}/edusoho.conf /etc/nginx/sites-enabled

# Start php service
php-fpm7.1

# Start nginx service
service nginx start
echo "Container ready"

# Infinity sleep for container will be runned
sleep infinity

