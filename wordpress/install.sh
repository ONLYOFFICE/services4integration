#!/usr/bin/env bash
#
# Prepare a stand with Wordpress with a dependent service Onlyoffice Document Server and add a connector

CONNECTOR_URL=''
SERVICE_TAG='latest'
IP=$(hostname -I)
IP_ARR=($IP)
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh

#############################################################################################
# Install the necessary dependencies on the host and install Redmine and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_wordpress() {
  source /app/common/install_dependencies.sh
  install_dependencies
  mkdir -p /var/lib/wordpress/wp-content/plugins
  git clone --branch=develop https://github.com/ONLYOFFICE/onlyoffice-wordpress.git /var/lib/wordpress/wp-content/plugins/onlyoffice-wordpress
  export TAG="${SERVICE_TAG}"
  cd /app/wordpress/
  envsubst < docker-compose.yml | docker-compose -f - up -d
}

#############################################################################################
# Check redmine startup and status
# Globals:
#   SERVICE_TAG
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_wordpress() {
  echo -e "\e[0;32m Waiting for the launch of Wordpress \e[0m"  
  for i in {1..15}; do
    echo "Getting the Wordpress status: ${i}"
    OUTPUT="$(curl -Is http://${IP_ARR[0]}/ | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "302" ]; then
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
  echo -e "\e[0;32m Now you can go to the Wordpress web interface at http://${IP_ARR[0]}/ and follow a few configuration steps \e[0m"
}

main() {
  install_wordpress
  check_wordpress
  complete_installation
}
