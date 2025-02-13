#!/usr/bin/env bash
#
# Prepare a stand with nuxeo with a dependent service Onlyoffice Document Server and add a connector

APP='nuxeo'
SERVICE_TAG='latest'
CONNECTOR_URL=https://github.com/ONLYOFFICE/onlyoffice-nuxeo/releases/download/v2.1.0/onlyoffice-nuxeo-package-2.1.0.zip
CONNECTOR_NAME='onlyoffice.zip'
JWT_SECRET='mysecret'
NGINX_CONF='nginx.conf'
SCHEME='http'
NUXEO_ONLINE_SERVICES_LOGIN=''
NUXEO_ONLINE_SERVICES_PROJECT=''
NUXEO_ONLINE_SERVICES_TOKEN=''
NUXEO_REPO_LOGIN=''
NUXEO_REPO_PASS=''
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

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
  APP_ADDR=$(wget -qO- ifconfig.me/ip)
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
  jwt_configuration
  create_config
docker login docker-private.packages.nuxeo.com -u ${NUXEO_REPO_LOGIN} -p ${NUXEO_REPO_PASS}
docker-compose up -d
}
create_config() {
echo " JWT_ENV=${JWT_ENV}
APP_ADDR=${APP_ADDR}
SCHEME=${SCHEME}
NGINX_CONF=${NGINX_CONF}
" > /app/nuxeo/.env
echo "onlyoffice.docserv.url=${SCHEME}://${APP_ADDR}/ds-vpath/
onlyoffice.jwt.secret=${JWT_SECRET}
org.nuxeo.dev=true
" > /app/nuxeo/nuxeo.conf
echo 'FROM docker-private.packages.nuxeo.com/nuxeo/nuxeo:2023
COPY nuxeo.conf /etc/nuxeo/conf.d/my-configuration.properties
COPY --chown=900:0 onlyoffice.zip $NUXEO_HOME/local-packages/onlyoffice.zip
' > /app/nuxeo/Dockerfile
echo "nuxeoctl register ${NUXEO_ONLINE_SERVICES_LOGIN} ${NUXEO_ONLINE_SERVICES_PROJECT} dev ${NUXEO_ONLINE_SERVICES_PROJECT} ${NUXEO_ONLINE_SERVICES_TOKEN}"'
nuxeoctl mp-install $NUXEO_HOME/local-packages/onlyoffice.zip
' > /app/nuxeo/cpf.sh
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
    OUTPUT="$(curl -Is ${SCHEME}://${APP_ADDR} | head -1 | awk '{ print $2 }')"
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
  echo -e "\e[0;32m Now you can go to the $APP web interface at ${SCHEME}://${APP_ADDR}/ and follow a few configuration steps \e[0m"
}

main() {
install_app
check_app
complete_installation
}

main

