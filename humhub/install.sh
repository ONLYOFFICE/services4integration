#!/bin/bash
# Prepares a HumHub stand with an installed connector. 

SERVICE_TAG="stable"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-humhub/releases/download/v2.2.2/onlyoffice.zip"
#CONNECTOR_NAME="onlyoffice.zip"
source /app/common/error.sh
source /app/common/check_parameters.sh $@
install_humhub_with_onlyoffice(){
  source /app/common/install_dependencies.sh
  install_dependencies
  prepare_connector
  prepare_files
  docker-compose -f /app/humhub/docker-compose.yml up -d 
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  unzip /connectors/${CONNECTOR_URL##*/} -d /app/humhub/modules
}
prepare_files() {
  sed -i -e  "s!mriedmann/humhub!mriedmann/humhub:${SERVICE_TAG}!g" \
    /app/humhub/docker-compose.yml
}
check_ready() {
  local humhub_started
  local healthcheck_ds
  local ds_started
  
  for i in {1..30}; do
    curl -f -s http://localhost
    if [[ "$?" -ne 0 ]]; then
	  echo -e "\e[0;32m Waiting for the launch of humhub \e[0m"
        sleep 10
      else
        echo -e "\e[0;32m humhub works \e[0m"
        humhub_started='true'
        break
    fi
  done

  if [[ "$humhub_started" != 'true' ]]; then
    err "\e[0;31m I didn't wait for the launch of humhub. \e[0m"
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
    err "\e[0;31m Document server did not start. 
      Check the container logs using the command: 
	  sudo docker logs -f onlyoffice-document-server. \e[0m"
    exit 1
  fi
}
complete_installation(){
  EXT_IP=$(wget -q -O - ifconfig.me/ip)
  echo -e "\e[0;32m Then you can go to the humhub web interface at: http://$EXT_IP and check the connector operation. \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
main() {
  install_humhub_with_onlyoffice
  check_ready
  complete_installation
}