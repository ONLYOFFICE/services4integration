#!/usr/bin/env bash
CONNECTOR_URL=https://github.com/ONLYOFFICE/onlyoffice-redmine/releases/download/v1.1.0/onlyoffice-redmine.zip
CONNECTOR_NAME=onlyoffice-redmine.zip
SERVICE_TAG='latest'

source /app/common/check_parameters.sh "${@}"
source /app/common/install_dependencies.sh
source /app/common/get_connector.sh

install_dependencies
get_connector
apt-get install unzip -y
unzip /connectors/$CONNECTOR_NAME -d /connectors
mv /connectors/onlyoffice-redmine /connectors/onlyoffice_redmine
docker-compose up -d

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

