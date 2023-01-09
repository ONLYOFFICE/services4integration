#!/usr/bin/env bash
#
# Prepare a stand with Odoo with a dependent service Onlyoffice Document Server and add a connector

APP='Odoo'
##CONNECTOR_URL=''
##CONNECTOR_NAME=''
SERVICE_TAG='latest'
readonly IP=$(wget -q -O - ifconfig.me/ip)
##JWT_SECRET='mysecret'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
##source /app/common/jwt_configuration.sh

#############################################################################################
# Install the necessary dependencies on the host and install Odoo and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_app() {
  source /app/common/install_dependencies.sh
  ##source /app/common/get_connector.sh
  install_dependencies
  ##jwt_configuration
  apt-get install unzip -y
  export TAG="${SERVICE_TAG}"
  ##export JWT_ENV="${JWT_ENV}"
  cd /app/odoo/
  envsubst < docker-compose.yml | docker-compose -f - up -d
  check_app
  ##get_connector
}

#############################################################################################
# Check odoo startup and status
# Globals:
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_app() {
  echo -e "\e[0;32m Waiting for the launch of $APP \e[0m"
  for i in {1..15}; do
    echo "Getting the $APP status: ${i}"
    OUTPUT="$(curl -Is http://${IP}:8069/ | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "303" -o "${OUTPUT}" == "302" ]; then
      echo -e "\e[0;32m $APP is ready to serve \e[0m"
      local APP_READY
      APP_READY='yes'
      break
    else
      sleep 10
    fi
  done
  if [[ "${APP_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of $APP. Check the container logs using the command: sudo docker logs -f odoo \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the $APP web interface at http://${IP}/ and follow a few configuration steps \e[0m"
  }

main() {
  install_app
  complete_installation
}

main

