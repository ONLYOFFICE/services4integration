#!/usr/bin/env bash
#
# Prepare a stand with Liferay with the dependent service Onlyoffice Document Server and add a connector
APP="liferay"
SERVICE_TAG='7.4.3.129-ga129'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v3.0.0/liferay-docs-3.0.0-CE-7.4.jar'
CONNECTOR_NAME='onlyoffice-integration-web-liferay.jar'
JWT_SECRET="mysecret"
DS_TAG="latest"
NGINX_CONF="nginx.conf"
SCHEME='http'
APP_ADDR=$(wget -q -O - ifconfig.me/ip)
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

###################################################################################################
# Install the necessary dependencies on the host and install Liferay and the dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   Writes the installation message to stdout
###################################################################################################
install_liferay() {
  source /app/common/install_dependencies.sh
  install_dependencies
  jwt_configuration
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
    NGINX_CONF="nginx_https.conf"
    SSL_PROXY="yes"
  fi
  prepare_files
  docker-compose -f /app/liferay/docker-compose.yml up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}

###################################################################################################
# prepare global variables for docker-compose
# Globals:
#   JWT_ENV
#   SERVICE_TAG
#   DS_TAG
#   NGINX_CONF
#   SCHEME
#   APP_ADDR
# Arguments:
#   None
# Returns:
#   None
###################################################################################################
prepare_files() {
echo "JWT_ENV=${JWT_ENV}
SERVICE_TAG=${SERVICE_TAG}
DS_TAG=${DS_TAG}
NGINX_CONF=${NGINX_CONF}
SCHEME=${SCHEME}
APP_ADDR=${APP_ADDR}
" > /app/liferay/.env
}

###################################################################################################
# Check Liferay startup and status
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
###################################################################################################
check_ready() {
  local app_started
  local healthcheck_ds
  local ds_started

  for i in {1..30}; do
    curl -f -s ${SCHEME}://${APP_ADDR} > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo -e "\e[0;32m Waiting for the launch of app \e[0m"
        sleep 10
    else
      echo -e "\e[0;32m ${APP} works \e[0m"
      app_started='true'
      break
    fi
  done

  if [[ "${app_started}" != 'true' ]]; then
    err "\e[0;31m I didn't wait for the launch of app. \e[0m"
    exit 1
  fi

  for i in {1..30}; do
    healthcheck_ds="$(curl -f -s ${SCHEME}://${APP_ADDR}/ds-vpath/healthcheck)"
    if [[ "${healthcheck_ds}" != 'true' ]]; then
      echo -e "\e[0;32m Waiting for the launch of document-server \e[0m"
        sleep 10
    else
      echo -e "\e[0;32m document-server is running \e[0m"
      ds_started='true'
      break
    fi
  done

  if [[ "${ds_started}" != 'true' ]]; then
    err "\e[0;31m Document server did not start. \
Check the container logs using the command: \
sudo docker logs -f onlyoffice-document-server. \e[0m"
    exit 1
  fi
}

###################################################################################################
# Add a connector to a Liferay container
# Globals:
#   CONNECTOR_NAME
# Arguments:
#   None
# Returns:
#   0 if thing was copied, non-zero on error.
###################################################################################################
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  chown -R 1000:1000 /connectors/
  docker cp /connectors/${CONNECTOR_NAME} liferay:/opt/liferay/deploy/
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Then you can go to the ${APP} web interface at: \
  ${SCHEME}://${APP_ADDR} and check the connector operation. \e[0m"
  echo -e "\e[0;32m User: user  Password: ${PASSWORD} \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
  install_liferay
  check_ready
  prepare_connector
  complete_installation
}

main
