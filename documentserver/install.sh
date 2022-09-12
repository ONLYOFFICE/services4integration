#!/usr/bin/env bash

# Prepare a pure documentserver standalone stand without any connectors.

SERVICE_TAG="latest"
DS_URL="https://github.com/ONLYOFFICE/Docker-DocumentServer.git"
DS_DIR=/apps/documentserver
IP_ADDR_INT="$(hostname -I | awk '{print $1}')"
IP_ADDR_EXT="$(wget -q -O - ifconfig.me/ip)"
SERVER_URL=${IP_ADDR_INT}

install_onlyoffice_documentserver() {
  source /app/common/install_dependencies.sh
  install_dependencies
  git clone ${DS_URL} ${DS_DIR}
  prepare_compose_file
  docker-compose -f ${DS_DIR}/docker-compose.yml up -d
  ready_check
}

# Disable build images for faster deploy
prepare_compose_file() {
  sed -i '/build:/d' ${DS_DIR}/docker-compose.yml
  sed -i '/context/d' ${DS_DIR}/docker-compose.yml
  sed -i "/container_name: onlyoffice-documentserver/a\   \ image: onlyoffice/documentserver:${SERVICE_TAG}" ${DS_DIR}/docker-compose.yml
}

ready_check () {
  while [ "$STATUS" != "200" ]
    do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}\n" http:/localhost/healthcheck/)
    echo "Waiting to ready document-server..."
    sleep 10
  done
  echo -e "\e[0;32m Document-Server is running \e[0m"
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can get access to DocumentServer at http://${IP_ADDR_INT}/ or http://${IP_ADDR_EXT}/ and start testing functionality \e[0m"
}

main() {
install_onlyoffice_documentserver
ready_check
complete_installation
}

main
