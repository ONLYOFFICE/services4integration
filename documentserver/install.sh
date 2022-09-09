#!/bin/bash

# Prepare a pure documentserver standalone stand without any connectors.

SERVICE_TAG="latest"
DS_URL="https://github.com/ONLYOFFICE/Docker-DocumentServer.git"
DS_DIR=/apps/documentserver

install_onlyoffice_documentserver() {
  source /app/common/install_dependencies.sh
  install_dependencies
  git clone ${DS_URL} ${DS_DIR}
  prepare_compose_file
  docker-compose -f ${DS_DIR}/docker-compose.yml up -d
}

# Disable build images for faster deploy
prepare_compose_file() {
  sed -i '/build:/d' ${DS_DIR}/docker-compose.yml
  sed -i '/context/d' ${DS_DIR}/docker-compose.yml
  sed -i '/container_name: onlyoffice-documentserver/a\   \ image: onlyoffice/documentserver:latest' ${DS_DIR}/docker-compose.yml
}

enable_ds_example(){
}

install_onlyoffice_documentserver
