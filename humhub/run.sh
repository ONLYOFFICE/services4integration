#!/bin/sh
# There is no bash in the container.
# In a HumHub container:
#   - a nginx.conf is being prepared for working with a document server;
#   - the HumHub is launched;
#   - the connector is activated and adjusted.

set -x

sed -i "$(($(grep -n 'http {' /etc/nginx/nginx.conf | \
  awk -F':' '{print $1}')+1))i\    include       /tmp/nginx_conf/map.conf;" \
  /etc/nginx/nginx.conf

sed -i "$(($(grep -n 'server {' /etc/nginx/nginx.conf | \
  awk -F':' '{print $1}')+1))i\        include       /tmp/nginx_conf/local.conf;" \
  /etc/nginx/nginx.conf

supervisord -n -c /etc/supervisord.conf &> /tmp/server.log &
sleep 10
cd /var/www/localhost/htdocs/protected
./yii module/enable onlyoffice
./yii settings/set onlyoffice serverUrl /ds-vpath/
./yii settings/set onlyoffice internalServerUrl http://ds
./yii settings/set onlyoffice storageUrl http://humhub
tail -f /tmp/server.log
