#!/usr/bin/env bash
#
# Prepare a stand with Redmine with a dependent service Onlyoffice Document Server and add a connector

CONNECTOR_URL=https://github.com/ONLYOFFICE/onlyoffice-redmine/releases/download/v2.1.0/onlyoffice_redmine.zip
CONNECTOR_NAME=onlyoffice-redmine.zip
SERVICE_TAG='latest'
NGINX_CONF='nginx.conf'
APP_ADDR=$(wget -qO- ifconfig.me/ip)
SCHEME='http'
JWT_SECRET='mysecret'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

#############################################################################################
# Install the necessary dependencies on the host and install Redmine and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_redmine() {
  source /app/common/install_dependencies.sh
  source /app/common/get_connector.sh
  jwt_configuration
  install_dependencies
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
  get_connector
  apt-get install unzip -y
  unzip /connectors/$CONNECTOR_NAME -d /connectors
  mv /connectors/onlyoffice-redmine /connectors/onlyoffice_redmine
  export TAG="${SERVICE_TAG}"
  export JWT_ENV="${JWT_ENV}"
  export NGINX_CONF="${NGINX_CONF}"
  cd /app/redmine/
  envsubst < docker-compose.yml | docker-compose -f - up -d
}

#############################################################################################
# Check redmine startup and status
# Globals:
#   SERVICE_TAG
#   OUTPUT
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_redmine() {
  echo -e "\e[0;32m Waiting for the launch of Redmine \e[0m"
  for i in {1..15}; do
    echo "Getting the Redmine status: ${i}"
    OUTPUT="$(curl -Is ${SCHEME}://${APP_ADDR}/ | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m redmine is ready to serve \e[0m"
      local REDMINE_READY
      REDMINE_READY='yes'
      break
    else
      sleep 10
    fi
  done
  if [[ "${REDMINE_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of Redmine. Check the container logs using the command: sudo docker logs -f redmine \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the Redmie web interface at ${SCHEME}://${APP_ADDR}/ and follow a few configuration steps \e[0m"
}

main() {
install_redmine
check_redmine
complete_installation
}

main
