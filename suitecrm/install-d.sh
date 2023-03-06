#!/bin/bash

source /app/common/install_dependencies.sh
install_dependencies

curl -sSL https://raw.githubusercontent.com/bitnami/containers/main/bitnami/suitecrm/docker-compose.yml > docker-compose.yml
docker-compose up -d