#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-jira"
CONNECTOR_NAME="onlyoffice-integration-web-jira.jar"

install_dependencies() {
  source /app/common/install_dependencies.sh
  install_dependencies
}

get_ip() {
export EXT_IP=`wget -q -O - ifconfig.me/ip`
}

install_nextcloud() {
cd /app/nextcloud/
docker-compose up -d
}

#main
get_ip
install_dependencies
install_nextcloud
