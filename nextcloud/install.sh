#!/usr/bin/env bash

install_nextcloud() {
  source /app/common/install_dependencies.sh
  install_dependencies
  cd /app/nextcloud/
  export EXT_IP=`wget -q -O - ifconfig.me/ip`
  docker-compose up -d
}

install_connector() {
  cd /var/lib/docker/volumes/nextcloud_nextcloud/_data/apps
  git clone --recurse-submodules https://github.com/ONLYOFFICE/onlyoffice-nextcloud.git onlyoffice
  chown -R www-data:www-data onlyoffice
}

#main
install_nextcloud
install_connector
