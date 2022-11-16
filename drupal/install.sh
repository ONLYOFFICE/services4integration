#!/usr/bin/env bash
#
# Prepare a stand with drupal with a dependent service Onlyoffice Document Server and add a connector

IP=$(hostname -I)
IP_ARR=($IP)
SERVICE_TAG=latest
JWT_SECRET='mysecret'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-drupal/archive/refs/tags/v1.0.1.zip'
CONNECTOR_NAME='onlyoffice.zip'
source /app/common/error.sh
source /app/common/check_parameters.sh
source /app/common/jwt_configuration.sh

#############################################################################################
# Install the necessary dependencies on the host and install drupal and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_drupal() {
source /app/common/install_dependencies.sh
install_dependencies
jwt_configuration
create_dockerfile
export TAG="${SERVICE_TAG}"
export JWT_ENV="${JWT_ENV}"
cd /app/drupal/
envsubst < docker-compose.yml | docker-compose -f - up -d
check_drupal
docker exec --workdir /opt/bitnami/drupal drupal composer require firebase/php-jwt
docker exec drupal drush pm:enable onlyoffice -y
}

create_dockerfile() {
echo 'FROM bitnami/drupal:'${SERVICE_TAG}'
USER 0
RUN install_packages wget
RUN wget -O '${CONNECTOR_URL}' '${CONNECTOR_NAME}'
RUN unzip '${CONNECTOR_NAME}' -d /opt/bitnami/drupal/modules/
CMD [ "/opt/bitnami/scripts/apache/run.sh" ]
' > /app/drupal/Dockerfile
}
#############################################################################################
# Check drupal startup and status
# Globals:
#   IP_ARR
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_drupal() {
  echo -e "\e[0;32m Waiting for the launch of drupal \e[0m"  
  for i in {1..30}; do
    echo "Getting the drupal status: ${i}"
    OUTPUT="$(curl -Is http://${IP_ARR[0]} | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m drupal is ready to serve \e[0m"
      local DRUPAL_READY
      DRUPAL_READY='yes'
      break
    else  
      sleep 10
    fi
  done
  if [[ "${DRUPAL_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of drupal. Check the container logs using the command: sudo docker logs -f drupal \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the Redmie web interface at http://${IP_ARR[0]}/ and follow a few configuration steps \e[0m"
}

main() {
jwt_configuration
install_drupal
complete_installation
}

main
