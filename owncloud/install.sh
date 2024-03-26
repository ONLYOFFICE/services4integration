#!/bin/bash
# Prepares a owncloud stand with an installed connector. 

SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-owncloud/releases/\
download/v7.1.1/onlyoffice.tar.gz"
CONNECTOR_NAME="${CONNECTOR_URL##*/}"
source /app/common/error.sh
source /app/common/check_parameters.sh $@
install_owncloud_with_onlyoffice() {
  source /app/common/install_dependencies.sh
  install_dependencies
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
  chmod +x /usr/bin/yq
  git clone https://github.com/ONLYOFFICE/docker-onlyoffice-owncloud /apps
  prepare_connector
  prepare_files
  docker-compose -f /apps/docker-compose.yml up -d 
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  tar -C /apps -xvf /connectors/${CONNECTOR_NAME}
}
prepare_files() {
  IP=$(wget -q -O - ifconfig.me/ip)
  e="owncloud/server:${SERVICE_TAG}" yq -i '.services.app.image = strenv(e)' /apps/docker-compose.yml
  e="OWNCLOUD_TRUSTED_DOMAINS=localhost,${IP}" yq -i '(.services.app.environment.[] | select(. == "OWNCLOUD_TRUSTED_DOMAINS*")) = strenv(e)' /apps/docker-compose.yml
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
    healthcheck_ds="$(curl -f -s http://localhost/ds-vpath/healthcheck)"
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
  readonly EXT_IP=$(wget -q -O - ifconfig.me/ip)
  
  echo -e "\e[0;32m Then you can go to the owncloud web interface at: \
http://${EXT_IP} and check the connector operation. \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
main() {
  install_owncloud_with_onlyoffice
  check_ready
  complete_installation
}
main

