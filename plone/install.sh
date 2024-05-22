#!/bin/bash
# Prepares a Plone stand with an installed connector.

SERVICE_TAG="6.0.5"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-plone/releases/download/v4.0.0/onlyoffice.plone-4.0.0.tar.gz"
CONNECTOR_REPO="https://github.com/ONLYOFFICE/onlyoffice-plone.git"
CONNECTOR_NAME="${CONNECTOR_URL##*/}"
JWT_SECRET='mysecret'
APP_ADDR=$(wget -q -O - ifconfig.me/ip)
NGINX_CONF='nginx.conf'
DS_TAG='latest'
SCHEME='http'
source /app/common/error.sh
source /app/common/check_parameters.sh $@
source /app/common/jwt_configuration.sh

install_plone_with_onlyoffice() {
  source /app/common/install_dependencies.sh
  install_dependencies
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    #get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
  prepare_connector
  jwt_configuration
  sed -i "s!server_name  plone.localhost;!server_name ${APP_ADDR};!g" /app/plone/${NGINX_CONF}
  export JWT_ENV="${JWT_ENV}"
  export SERVICE_TAG="${SERVICE_TAG}"
  export NGINX_CONF="${NGINX_CONF}"
  cd /app/plone/
  envsubst < docker-compose.yml | docker-compose -f - up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
#  sed -i -e "s!https://documentserver/!${SCHEME}://${APP_ADDR}/ds-vpath/!g" \
#    /app/plone/onlyoffice/src/onlyoffice/connector/browser/controlpanel.py
}

check_ready() {
  local plone_started
  local healthcheck_ds
  local ds_started

  for i in {1..30}; do
    curl -f -s http://localhost > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo -e "\e[0;32m Waiting for the launch of plone \e[0m"
        sleep 10
    else
      echo -e "\e[0;32m plone works \e[0m"
      plone_started='true'
      break
    fi
  done

  if [[ "${plone_started}" != 'true' ]]; then
    err "\e[0;31m I didn't wait for the launch of plone. \e[0m"
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
complete_installation() {
  echo -e "\e[0;32m Then you can go to the plone web interface at: \
http://${EXT_IP} and check the connector operation. \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
main() {
  install_plone_with_onlyoffice
  check_ready
  complete_installation
}
main

