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
while [[ "$(curl --connect-timeout 2 -s -o /dev/null -w ''%{http_code}'' http://localhost:8080)" != "200" ]]; do echo ..; sleep 5; done; echo backend is up; install_connector
