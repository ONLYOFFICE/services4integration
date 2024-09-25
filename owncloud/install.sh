#!/bin/bash
# Prepares a owncloud stand with an installed connector.

SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-owncloud/releases/download/v9.3.1/onlyoffice.tar.gz"
CONNECTOR_NAME="${CONNECTOR_URL##*/}"
NGINX_CONF="nginx.conf"
JWT_SECRET="mysecret"
source /app/common/error.sh
source /app/common/check_parameters.sh $@
install_owncloud_with_onlyoffice() {
  source /app/common/install_dependencies.sh
  source /app/common/gen_password.sh
  source /app/common/jwt_configuration.sh
  gen_password
  install_dependencies
  jwt_configuration
  prepare_connector
  IP=$(wget -q -O - ifconfig.me/ip)
  APP_ADDR=${IP}
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
    NGINX_CONF="nginx_https.conf"
  fi
  prepare_files
  docker-compose -f /app/owncloud/docker-compose.yml up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  tar -xvf /connectors/${CONNECTOR_NAME}
}
prepare_files() {
echo "OWNCLOUD_DOMAIN=${APP_ADDR}
ADMIN_USERNAME=test
ADMIN_PASSWORD=${PASSWORD}
NGINX_CONF=${NGINX_CONF}
JWT_ENV=${JWT_ENV}
" > /app/owncloud/.env
echo "#!/bin/bash
set -x
/usr/bin/owncloud server &> /tmp/server.log &
sleep 40 # owncloud should init itself before ability to enable app
cp -r /tmp/onlyoffice /var/www/owncloud/custom/
chown -R www-data:www-data /var/www/owncloud/custom/onlyoffice
occ --no-warnings app:enable onlyoffice
occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value=\"${SCHEME}://${APP_ADDR}/ds-vpath/\"
occ --no-warnings config:system:set onlyoffice StorageUrl --value=\"${SCHEME}://${APP_ADDR}/\"
occ --no-warnings config:system:set onlyoffice jwt_secret --value=\"${JWT_SECRET}\"
tail -f /tmp/server.log
" > /app/owncloud/run.sh

}
check_ready() {
  local owncloud_started
  local healthcheck_ds
  local ds_started

  for i in {1..30}; do
    curl -f -s http://localhost > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo -e "\e[0;32m Waiting for the launch of owncloud \e[0m"
        sleep 10
    else
      echo -e "\e[0;32m owncloud works \e[0m"
      owncloud_started='true'
      break
    fi
  done

  if [[ "${owncloud_started}" != 'true' ]]; then
    err "\e[0;31m I didn't wait for the launch of owncloud. \e[0m"
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
  echo -e "\e[0;32m Then you can go to the owncloud web interface at: \
  ${SCHEME}://${APP_ADDR} and check the connector operation. \e[0m"
  echo -e "\e[0;32m Password:\n${PASSWORD} \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
main() {
  install_owncloud_with_onlyoffice
  check_ready
  complete_installation
}
main
