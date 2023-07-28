#!/usr/bin/env bash
#
# Prepare a stand with seafile with a dependent service Onlyoffice Document Server and add a connector

APP='seafile'
SERVICE_TAG='latest'
JWT_SECRET='mysecret'
NGINX_CONF='nginx.conf'
DS_TAG='latest'
SCHEME='http'
LOGIN='me@example.com'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

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
  source /app/common/gen_password.sh
  gen_password
  install_dependencies
  IP=$(wget -qO- ifconfig.me/ip)
  APP_ADDR=${IP}
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
  jwt_configuration
  export TAG="${SERVICE_TAG}"
  export IP="${IP}"
  export JWT_ENV="${JWT_ENV}"
  export NGINX_CONF="${NGINX_CONF}"
  export SCHEME="${SCHEME}"
  export DS_TAG="${DS_TAG}"
  export APP_ADDR="${APP_ADDR}"
  export PASSWORD="${PASSWORD}"
  if [ "${JWT_ENABLED}" == 'false' ]; then
    export JWT_SECRET=""
  else
    export JWT_SECRET="${JWT_SECRET}"
  fi
  cd /app/seafile
  envsubst < docker-compose.yaml | docker-compose -f - up -d
  APP_URI=${SCHEME}'://'${APP_ADDR}
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
    if [ "$(curl -Ss "${APP_URI}/api2/ping/")" == "\"pong\"" ]; then
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
    healthcheck_ds="$(curl -f -s ${APP_URI}/ds-vpath/healthcheck)"
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
  echo -e "\e[0;32m Now you can go to the ${APP} web interface at http://${APP_URI}/ and follow a few configuration steps \e[0m"
  echo -e "\e[0;32m    Login: ${LOGIN}"
  echo -e "\e[0;32m Password: ${PASSWORD}"
  }

main() {
  install_app
  check_app
  complete_installation
}

main
