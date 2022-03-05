#!/usr/bin/env bash
#
# Prepare a stand with drupal with a dependent service Onlyoffice Document Server and add a connector
IP=$(hostname -I)
IP_ARR=($IP)
source /app/common/error.sh
#############################################################################################
# Install the necessary dependencies on the host and install drupal and dependent service
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_drupal() {
source /app/common/install_dependencies.sh
install_dependencies
docker-compose up -d
}

#############################################################################################
# Check drupal startup and status
# Globals:
#   SERVICE_TAG
#   OUTPUT
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
install_drupal
check_drupal
complete_installation
}

main
