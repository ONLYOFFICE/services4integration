#!/bin/bash

wget https://suitecrm.com/download/138/suite713/561945/suitecrm-7-13-1.zip
unzip suitecrm-7-13-1.zip -d /var/www/
mv /var/www/SuiteCRM-7.13.1 /var/www/suitecrm

mkdir -p /var/www/suitecrm
chown -R www-data:www-data /var/www/suitecrm
chmod -R 755 /var/www/suitecrm
chmod -R 775 /var/www/suitecrm/cache
chmod -R 775 /var/www/suitecrm/custom
chmod -R 775 /var/www/suitecrm/data
chmod -R 775 /var/www/suitecrm/modules
chmod -R 775 /var/www/suitecrm/themes
chmod -R 775 /var/www/suitecrm/upload
chmod -R 775 /var/www/suitecrm/config_override.php 2>/dev/null

apt install -y apache2 unzip mariadb-server expect
systemctl enable apache2 mariadb --now

mysql -u root <<< "
   CREATE DATABASE suitecrm;
   GRANT ALL ON suitecrm.* TO 'suitecrm'@'localhost' IDENTIFIED BY 'password';
   FLUSH PRIVILEGES;
   EXIT;
"

add-apt-repository ppa:ondrej/php -y
apt install -y php-imagick php7.4-fpm php7.4-mysql php7.4-common php7.4-gd php7.4-imap php7.4-json php7.4-curl php7.4-zip php7.4-xml php7.4-mbstring php7.4-bz2 php7.4-intl php7.4-gmp
a2dismod php7.4
a2dismod mpm_prefork
a2enmod mpm_event proxy_fcgi setenvif
systemctl restart apache2

tee /etc/apache2/sites-available/suitecrm.conf <<EOF
<VirtualHost *:80>
  ServerName example.com
  ServerAlias *
  DocumentRoot /var/www/suitecrm/

  ErrorLog ${APACHE_LOG_DIR}/suitecrm_error.log
  CustomLog ${APACHE_LOG_DIR}/suitecrm_access.log combined

  <Directory />
    Options FollowSymLinks
    AllowOverride All
  </Directory>

  <Directory /var/www/suitecrm/>
    Options FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
  </Directory>

Include /etc/apache2/conf-available/php7.4-fpm.conf

</VirtualHost>
EOF

a2ensite suitecrm.conf
systemctl restart apache2

sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 30M/g' /etc/php/7.4/fpm/php.ini
systemctl restart php7.4-fpm
systemctl restart apache2
