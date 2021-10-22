#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-jira"
CONNECTOR_NAME="onlyoffice-integration-web-jira.jar"
source /app/common/check_parameters.sh ${@}
install_dependencies(){
  source /app/common/install_dependencies.sh
  install_dependencies
}
get_ip(){
export EXT_IP=`wget -q -O - ifconfig.me/ip`
}
install_nexcloud() {
cd /app/nextcloud/
docker-compose run -d
}

get_ip
install_dependencies
install_nexcloud
