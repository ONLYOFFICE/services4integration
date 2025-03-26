#!/bin/bash
# Prepares a Moodle stand with an installed connector.

SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/moodle-mod_onlyofficeeditor/releases/download/v6.0.1/moodle-mod_onlyofficeeditor-6.0.1.zip"
DOCSPACE_CONNECTOR_URL="https://github.com/ONLYOFFICE/moodle-mod_onlyofficedocspace/releases/download/v1.0.2/moodle-mod_onlyofficedocspace-1.0.2.zip"
JWT_SECRET='mysecret'
NGINX_CONF="nginx.conf"
SCHEME="https"
SSL_PROXY="no"
DS_TAG="latest"
APP_ADDR=$(wget -q -O - ifconfig.me/ip)
PASSWORD=""
source /app/common/error.sh
source /app/common/check_parameters.sh $@
CONNECTOR_NAME="${CONNECTOR_URL##*/}"
DOCSPACE_CONNECTOR_NAME="${DOCSPACE_CONNECTOR_URL##*/}"
source /app/common/jwt_configuration.sh
source /app/common/gen_password.sh

install_moodle_with_onlyoffice() {
  export SERVICE_TAG="${SERVICE_TAG}"
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

  prepare_connector
  prepare_files
  docker-compose -f /app/moodle/docker-compose.yml up -d
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  mkdir /app/moodle/onlyoffice
  echo "${CONNECTOR_URL}"
  if [ -n "${CONNECTOR_URL}" ]; then
    unzip -d /app/moodle /connectors/${CONNECTOR_NAME}
    mkdir /app/moodle/onlyoffice/docs
    mv /app/moodle/moodle-mod_onlyofficeeditor*/* /app/moodle/onlyoffice/docs
    sed -i -e "s!https://documentserver.url!${SCHEME}://${APP_ADDR}/ds-vpath/!g" \
    /app/moodle/onlyoffice/docs/settings.php
    sed -i '/    $defaultjwtheader/ a\    $jwt = \x27mysecret\x27;' \
    /app/moodle/onlyoffice/docs/settings.php
    sed -i "/documentserversecret/{s/''/\$jwt/;}" \
    /app/moodle/onlyoffice/docs/settings.php

  fi
  if [ -n "${DOCSPACE_CONNECTOR_URL}" ]; then
    unzip -d /app/moodle /connectors/${DOCSPACE_CONNECTOR_NAME}
    mkdir /app/moodle/onlyoffice/docspace
    mv /app/moodle/moodle-mod_onlyofficedocspace*/* /app/moodle/onlyoffice/docspace
  fi
}
prepare_files() {
gen_password
echo "
SERVICE_TAG=${SERVICE_TAG}
SSL_PROXY=${SSL_PROXY}
PASSWORD=${PASSWORD}
JWT_ENV=${JWT_ENV}
NGINX_CONF=${NGINX_CONF}
DS_TAG=${DS_TAG}
APP_ADDR=${APP_ADDR}
" > /app/moodle/.env
}
check_ready() {
  local moodle_started
  local healthcheck_ds
  local ds_started

  for i in {1..30}; do
    curl -f -s ${SCHEME}://${APP_ADDR} > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo -e "\e[0;32m Waiting for the launch of moodle \e[0m"
        sleep 10
    else
      echo -e "\e[0;32m moodle works \e[0m"
      moodle_started='true'
      break
    fi
  done

  if [[ "${moodle_started}" != 'true' ]]; then
    err "\e[0;31m I didn't wait for the launch of moodle. \e[0m"
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
  echo -e "\e[0;32m Then you can go to the moodle web interface at: \
  ${SCHEME}://${APP_ADDR} and check the connector operation. \e[0m"
  echo -e "\e[0;32m User: user  Password: ${PASSWORD} \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
main() {
  install_moodle_with_onlyoffice
  check_ready
  complete_installation
}
main
