#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-jira"
CONNECTOR_NAME="onlyoffice-integration-web-jira.jar"

install_nextcloud() {
  source /app/common/install_dependencies.sh
  install_dependencies
  cd /app/nextcloud/
  export EXT_IP=`wget -q -O - ifconfig.me/ip`
  docker-compose up -d
}

#main
install_nextcloud
