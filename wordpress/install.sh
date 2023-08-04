#!/usr/bin/env bash
#
# Prepare a stand with Wordpress with a dependent service Onlyoffice Document Server and add a connector

CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-wordpress/releases/download/v1.0.2/onlyoffice.zip'
CONNECTOR_NAME='onlyoffice.zip'
SERVICE_TAG='latest'
APP_ADDR=$(wget -q -O - ifconfig.me/ip)
NGINX_CONF='nginx.conf'
JWT_SECRET='mysecret'
DS_TAG='latest'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

#############################################################################################
# Install the necessary dependencies on the host and install Wordpress and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_wordpress() {
  source /app/common/install_dependencies.sh
  source /app/common/get_connector.sh
  source /app/common/docs_ready_check.sh
  source /app/common/gen_password.sh
  install_dependencies
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
  fi
  jwt_configuration
  gen_password
  apt-get install unzip -y
  mkdir -p /var/wordpress
  export TAG="${SERVICE_TAG}"
  export JWT_ENV="${JWT_ENV}"
  export NGINX_CONF="${NGINX_CONF}"
  export PASSWORD="${PASSWORD}"
  export DS_TAG="${DS_TAG}"
  cd /app/wordpress/
  envsubst < docker-compose.yml | docker-compose -f - up -d
  docs_ready_check
  check_wordpress
  get_connector
  unzip /connectors/$CONNECTOR_NAME -d /var/wordpress/wp-content/plugins
}

#############################################################################################
# Check wordpress startup and status
# Globals:
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_wordpress() {
  echo -e "\e[0;32m Waiting for the launch of Wordpress \e[0m"
  for i in {1..15}; do
    echo "Getting the Wordpress status: ${i}"
    OUTPUT="$(curl -Is http://${APP_ADDR}/ | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" -o "${OUTPUT}" == "302" -o "${OUTPUT}" == "301" ]; then
      echo -e "\e[0;32m wordpress is ready to serve \e[0m"
      local WORDPRESS_READY
      WORDPRESS_READY='yes'
      break
    else
      sleep 10
    fi
  done
  if [[ "${WORDPRESS_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of Wordpress. Check the container logs using the command: sudo docker logs -f wordpress \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the Wordpress web interface at http:/${APP_ADDR}/wp-admin/ and follow a few configuration steps \e[0m"
  echo -e "\e[0;32m Login: adm \e[0m"
  echo -e "\e[0;32m Password: "${PASSWORD}" \e[0m"
  }

main() {
  install_wordpress
  complete_installation
}

main


