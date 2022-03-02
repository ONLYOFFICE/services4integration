#!/usr/bin/env bash
#
# Prepare a stand with Redmine with a dependent service Onlyoffice Document Server and add a connector

CONNECTOR_URL=https://github.com/ONLYOFFICE/onlyoffice-redmine/releases/download/v1.1.0/onlyoffice-redmine.zip
CONNECTOR_NAME=onlyoffice-redmine.zip
SERVICE_TAG='latest'
source /app/common/check_parameters.sh "${@}"

#############################################################################################
# Install the necessary dependencies on the host and install Redmine and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_redmine(){
  source /app/common/install_dependencies.sh
  source /app/common/get_connector.sh

  install_dependencies
  get_connector
  apt-get install unzip -y
  unzip /connectors/$CONNECTOR_NAME -d /connectors
  mv /connectors/onlyoffice-redmine /connectors/onlyoffice_redmine
  export TAG="${SERVICE_TAG}"
  cd /app/redmine/
  envsubst < docker-compose.yml | docker-compose -f - up -d
}
complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main(){
install_redmine
complete_installation
}

main
