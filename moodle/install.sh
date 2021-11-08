#!/bin/bash
# Prepares a Moodle stand with an installed connector. 

SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-moodle/archive/\
refs/tags/v1.0.0.tar.gz"
CONNECTOR_NAME="${CONNECTOR_URL##*/}"
source /app/common/error.sh
source /app/common/check_parameters.sh $@
install_moodle_with_onlyoffice(){
  source /app/common/install_dependencies.sh
  install_dependencies
  prepare_connector
  prepare_files
  docker-compose -f /app/moodle/docker-compose.yml up -d 
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  tar -C /app/moodle -xvf /connectors/${CONNECTOR_NAME}
  mv /app/moodle/onlyoffice* /app/moodle/onlyoffice
}
prepare_files() {
  EXT_IP=$(wget -q -O - ifconfig.me/ip)
  sed -i -e "s!bitnami/moodle!bitnami/moodle:${SERVICE_TAG}!g" \
    /app/moodle/docker-compose.yml
  sed -i -e "s!https://documentserver.url!http://${EXT_IP}/ds-vpath/!g" \
    /app/moodle/onlyoffice/settings.php
}
check_ready() {
  local moodle_started
  local healthcheck_ds
  local ds_started

  for i in {1..30}; do
    curl -f -s http://localhost > /dev/null
    if [[ "$?" -ne 0 ]]; then
      echo -e "\e[0;32m Waiting for the launch of moodle \e[0m"
        sleep 10
      else
        echo -e "\e[0;32m moodle works \e[0m"
        moodle_started='true'
        break
    fi
  done

  if [[ "$moodle_started" != 'true' ]]; then
    err "\e[0;31m I didn't wait for the launch of moodle. \e[0m"
    exit 1
  fi

  for i in {1..30}; do
    healthcheck_ds="$(curl -f -s http://localhost/ds-vpath/healthcheck)"
    if [[ "$healthcheck_ds" != 'true' ]]; then
      echo -e "\e[0;32m Waiting for the launch of document-server \e[0m"
        sleep 10
      else
        echo -e "\e[0;32m document-server is running \e[0m"
        ds_started='true'
        break
    fi
  done

  if [[ "$ds_started" != 'true' ]]; then
    err "\e[0;31m Document server did not start. \
Check the container logs using the command: \
sudo docker logs -f onlyoffice-document-server. \e[0m"
    exit 1
  fi
}
complete_installation(){
  echo -e "\e[0;32m Then you can go to the moodle web interface at: \
http://$EXT_IP and check the connector operation. \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
main() {
  install_moodle_with_onlyoffice
  check_ready
  complete_installation
}
main
