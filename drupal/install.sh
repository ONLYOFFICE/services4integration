#!/usr/bin/env bash
#
# Prepare a stand with drupal with a dependent service Onlyoffice Document Server and add a connector

APP_ADDR=$(wget -q -O - ifconfig.me/ip)
SERVICE_TAG=latest
JWT_SECRET='mysecret'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-drupal/releases/download/v1.0.5/onlyoffice-drupal-1.0.5.zip'
CONNECTOR_NAME='onlyoffice.zip'
SCHEME='http'
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
source /app/common/gen_password.sh
install_dependencies
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
jwt_configuration
gen_password
create_dockerfile
export TAG="${SERVICE_TAG}"
export JWT_ENV="${JWT_ENV}"
export PASSWORD="${PASSWORD}"
export NGINX_CONF="${NGINX_CONF}"
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
RUN wget -O '${CONNECTOR_NAME}' '${CONNECTOR_URL}'
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
    OUTPUT="$(curl -Is ${SCHEME}://${APP_ADDR} | head -1 | awk '{ print $2 }')"
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
  echo -e "\e[0;32m Now you can go to the Drupal web interface at ${SCHEME}://${APP_ADDR}/ and follow a few configuration steps \e[0m"
}

main() {
jwt_configuration
install_drupal
complete_installation
}

main

