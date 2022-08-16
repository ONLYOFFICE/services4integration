#!/usr/bin/env bash
#
# Prepare a stand with seafile with a dependent service Onlyoffice Document Server and add a connector

APP='seafile'
SERVICE_TAG='latest'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh

#############################################################################################
# Install the necessary dependencies on the host and install seafile and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_app() {
  source /app/common/install_dependencies.sh
  install_dependencies
  IP=$(wget -qO- ifconfig.me/ip)
  export TAG="${SERVICE_TAG}"
  export IP="${IP}"
  cd /app/seafile
  envsubst < docker-compose.yaml | docker-compose -f - up -d
  sleep 10
  docker exec seafile /run.sh
  docker-compose restart
}

#############################################################################################
# Check seafile startup and status
# Globals:
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_app() {
  echo -e "\e[0;32m Waiting for the launch of ${APP} \e[0m"
  for i in {1..15}; do
    echo "Getting the ${APP} status: ${i}"
    if [ $(curl -Ss "http://${IP}/api2/ping/") == "\"pong\"" ]; then
      echo -e "\e[0;32m ${APP} is ready to serve \e[0m"
      local APP_READY
      APP_READY='yes'
      break
    else
      sleep 10
    fi
  done
  if [[ "${APP_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of ${APP}. Check the container logs using the command: sudo docker logs -f seafile \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the ${APP} web interface at http://${IP}/ and follow a few configuration steps \e[0m"
  }

main() {
  install_app
  check_app
  complete_installation
}

main
