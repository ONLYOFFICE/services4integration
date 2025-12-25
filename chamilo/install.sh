#!/usr/bin/env bash
SERVICE_TAG="1.11.32"
PHP_VERSION="7.4"
IP=""
CONNECTOR_URL=""
DB_USER="chamilouser"
DB_PWD=""
CONNECTOR_NAME="onlyoffice.zip"
JWT_SECRET="mysecret"

source /app/common/check_parameters.sh "${@}"
source /app/common/jwt_configuration.sh
CHAMILO_URL="https://github.com/chamilo/chamilo-lms/releases/download/v$SERVICE_TAG/chamilo-$SERVICE_TAG.zip"

dependencies_install () {
source /app/common/install_dependencies.sh
install_dependencies
apt install -y apache2
systemctl stop apache2.service
systemctl start apache2.service
systemctl enable apache2.service
apt-get install -y mariadb-server mariadb-client
systemctl stop mariadb.service
systemctl start mariadb.service
systemctl enable mariadb.service
ROOT_PASSWORD=$(openssl rand -base64 16 | tr -d '/+' | head -c 12)
mysql -u root << EOF
use mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
apt-get install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
OIFS=$IFS
IFS='.'
VERSION_ARR=($SERVICE_TAG)
IFS=$OIFS

if [ ${VERSION_ARR[0]} -le 1 ]; then
  if [ ${VERSION_ARR[1]} -le 11 ]; then
    if [ ${VERSION_ARR[2]} -le 14 ]; then PHP_VERSION="7.1"
    fi
  fi
fi

apt install -y php$PHP_VERSION libapache2-mod-php$PHP_VERSION php$PHP_VERSION-common \
  php$PHP_VERSION-sqlite3 php$PHP_VERSION-curl php$PHP_VERSION-intl php$PHP_VERSION-mbstring \
  php$PHP_VERSION-xmlrpc php$PHP_VERSION-mysql php$PHP_VERSION-gd php$PHP_VERSION-xml \
  php$PHP_VERSION-cli php$PHP_VERSION-ldap php$PHP_VERSION-apcu php$PHP_VERSION-zip
}

configure_php () {
sed -i 's/file_uploads.*/file_uploads = On/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/allow_url_fopen.*/allow_url_fopen = On/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/short_open_tag.*/short_open_tag = On/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/memory_limit.*/memory_limit = 256M/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/upload_max_filesize.*/upload_max_filesize = 100M/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/max_execution_time.*/max_execution_time = 360/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/session.cookie_httponly =/session.cookie_httponly = On/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/post_max_size =.*/post_max_size = 10M/' /etc/php/$PHP_VERSION/apache2/php.ini
sed -i 's/short_open_tag.*/short_open_tag = Off/' /etc/php/$PHP_VERSION/apache2/php.ini
systemctl restart apache2.service
}

configure_database () {
DB_PWD=$(openssl rand -base64 16 | tr -d '/+' | head -c 12)
mysql -u root -p${ROOT_PASSWORD} << EOF
CREATE DATABASE chamilo;
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PWD}';
GRANT ALL ON chamilo.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PWD}' WITH GRANT OPTION;
FlUSH PRIVILEGES;
EOF
}

install_chamilo () {
cd /tmp && wget $CHAMILO_URL
apt install -y unzip
unzip chamilo-$SERVICE_TAG.zip
find ./ -maxdepth 1 -name "chamilo*zip" -exec rm -f {} \;
find ./ -maxdepth 1 -name "chamilo*" -exec mv {} /var/www/html/Chamilo \;
chown -R www-data:www-data /var/www/html/Chamilo/
chmod -R 755 /var/www/html/Chamilo/
IP=$(hostname -I)
IP_ARR=($IP)
echo '<VirtualHost *:80>
ServerAdmin admin@example.com
DocumentRoot /var/www/html/Chamilo
ServerName '${IP_ARR[0]}'
<Directory /var/www/html/Chamilo/>
Options FollowSymlinks
AllowOverride All
Require all granted
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
' > /etc/apache2/sites-available/chamilo.conf
a2ensite chamilo.conf
a2enmod rewrite
systemctl restart apache2.service
}

plugin_install () {
source /app/common/get_connector.sh
get_connector
rm -r /var/www/html/Chamilo/plugin/onlyoffice/
unzip /connectors/$CONNECTOR_NAME -d /connectors
cp -r /connectors/onlyoffice /var/www/html/Chamilo/plugin
chmod -R u+rwx /var/www/html/Chamilo/plugin/onlyoffice/
chmod -R go+rx /var/www/html/Chamilo/plugin/onlyoffice/
chown -R www-data:www-data /var/www/html/Chamilo/plugin/onlyoffice/
}

install_documentserver() {
  jwt_configuration
  docker run -i -t -d -p 3000:80 -e $JWT_ENV --restart=always onlyoffice/documentserver
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
  echo "DB_PASSWORD: ${DB_PWD}" | tee /var/lib/app_password
  echo "db_ROOT_PASSWORD: ${ROOT_PASSWORD}" >> /var/lib/app_password
}
main () {
dependencies_install
configure_php
configure_database
install_chamilo
if [ -e /connectors/onlyoffice.zip ]; then
  plugin_install
fi
install_documentserver
complete_installation
}
main
