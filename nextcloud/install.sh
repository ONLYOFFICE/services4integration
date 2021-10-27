#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v7.1.2/onlyoffice.tar.gz"
CONNECTOR_NAME="onlyoffice.tar.gz"
source /app/common/check_parameters.sh ${@}
source /app/common/get_connector.sh

install_nextcloud() {
  export SERVICE_TAG=`echo $SERVICE_TAG`
  export EXT_IP=`wget -q -O - ifconfig.me/ip`  
  source /app/common/install_dependencies.sh
  install_dependencies
  cd /app/nextcloud/
  docker-compose up -d
}

install_connector() {
  get_connector
  cd /connectors
  tar -xzf $CONNECTOR_NAME && rm -f $CONNECTOR_NAME
  docker cp /connectors/onlyoffice nextcloud_app:/var/www/html/apps
  docker exec -d nextcloud_app sh -c "chown -R www-data:www-data apps/onlyoffice"
}

check_ready() {
for ((i=30; i>0 ; i--))
  do
    if [[ "$(curl --connect-timeout 2 -L -s -o /dev/null -w ''%{http_code}'' http://localhost:8080)" != "200" ]]
      then 
        echo Waiting to ready
        sleep 10
      else
        echo Nextcloud is up on 
        echo http://$EXT_IP:8080
        return 1
    fi
  done
    echo Nextcloud is unavailable
    exit 1
}

#main
install_nextcloud
check_ready
install_connector
