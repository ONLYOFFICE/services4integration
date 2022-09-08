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
  check_app
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
    if [ "$(curl -Ss "http://${IP}/api2/ping/")" == "\"pong\"" ]; then
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

  for i in {1..30}; do
    healthcheck_ds="$(curl -f -s http://${IP}:3000/healthcheck)"
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
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the ${APP} web interface at http://${IP}/ and follow a few configuration steps \e[0m"
  }

main() {
  install_app
  check_app
  complete_installation
}

main
