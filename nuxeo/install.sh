#!/usr/bin/env bash
#
# Prepare a stand with nuxeo with a dependent service Onlyoffice Document Server and add a connector

APP='nuxeo'
SERVICE_TAG='latest'
CONNECTOR_URL=https://github.com/ONLYOFFICE/onlyoffice-nuxeo/releases/download/v2.0.0/onlyoffice-nuxeo-package-2.0.0.zip
CONNECTOR_NAME='onlyoffice.zip'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh

#############################################################################################
# Install the necessary dependencies on the host and install nuxeo and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_app() {
  source /app/common/install_dependencies.sh
  source /app/common/get_connector.sh
  install_dependencies
  get_connector
  IP=$(wget -qO- ifconfig.me/ip)
  create_config
  export IP="${IP}"
  cd /app/nuxeo
  envsubst < docker-compose.yml | docker-compose -f - up -d
}
create_config() {
echo 'onlyoffice.docserv.url=http://'${IP}'
onlyoffice.jwt.secret=mysecret
org.nuxeo.dev=true
' > /app/nuxeo/nuxeo.conf
echo 'FROM nuxeo:'${SERVICE_TAG}'
COPY /app/nuxeo/nuxeo.conf /docker-entrypoint-initnuxeo.d/nuxeo.conf
' > /app/nuxeo/Dockerfile
}

#############################################################################################
# Check nuxeo startup and status
# Globals:
#   IP
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_app() {
  echo -e "\e[0;32m Waiting for the launch of $APP \e[0m"
  for i in {1..30}; do
    echo "Getting the $APP status: ${i}"
    OUTPUT="$(curl -Is http://${IP}:8080 | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m $APP is ready to serve \e[0m"
      local APP_READY
      APP_READY='yes'
      break
    else
      sleep 30
    fi
  done
  if [[ "${APP_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of $APP \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the $APP web interface at http://${IP}:8080/ and follow a few configuration steps \e[0m"
}

main() {
install_app
check_app
complete_installation
}

main

