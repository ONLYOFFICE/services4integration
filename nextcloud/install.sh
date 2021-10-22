#!/usr/bin/env bash
source /app/common/check_parameters.sh ${@}

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

check_ready() {
while [[ "$(curl --connect-timeout 2 -L -s -o /dev/null -w ''%{http_code}'' http://localhost:8080)" != "200" ]]
  do 
    echo Waiting to ready
    sleep 5
  done
    echo Nextcloud is up on 
    echo http://$EXT_IP:8080
}

#main
install_nextcloud
check_ready
install_connector
