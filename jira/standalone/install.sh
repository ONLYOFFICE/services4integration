#!/usr/bin/env bash
#
# Prepare a stand with Jira standalone with a dependent service Onlyoffice Document Server and add a connector

SERVICE_TAG='latest'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-jira/releases/download/v4.1.1/onlyoffice-jira-app-4.1.1.jar'
CONNECTOR_NAME='onlyoffice-integration-web-jira.jar'
PLUGIN_DIRECTORY='/var/atlassian/application-data/jira/plugins/installed-plugins/'
DS_TAG='latest'
JWT_SECRET='mysecret'
NGINX_CONF='nginx.conf'
SCHEME='http'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

#############################################################################################
# Install the necessary dependencies on the host and install Jira and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   Writes the installation message to stdout
#############################################################################################
install_jira(){
  source /app/common/install_dependencies.sh
  install_dependencies
  jwt_configuration
  APP_ADDR="$(wget -q -O - ifconfig.me/ip)"
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
  MYSQL_PASSWORD=$(openssl rand -base64 20 | tr -d '/+' | head -c 16)
  echo 'JWT_ENV='${JWT_ENV}'
SERVICE_TAG='${SERVICE_TAG}'
NGINX_CONF='${NGINX_CONF}'
DOMAIN_NAME='${APP_ADDR}'
DS_TAG='${DS_TAG}'
MYSQL_PASSWORD='${MYSQL_PASSWORD}'
' > /app/jira/standalone/.env
  cd /app/jira/standalone
  docker-compose up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}

#############################################################################################
# Check Jira startup and status
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
#############################################################################################
check_launch_jira(){
  echo -e "\e[0;32m Waiting for the launch of Jira \e[0m"
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Getting the Jira status: ${i}"
    docker logs jira | grep -wq "Jira is ready to serve"
    if [[ "$?" -ne 0 ]]; then
      sleep 5
    else
      echo -e "\e[0;32m Jira works \e[0m"
      local JIRA_READY
      JIRA_READY='yes'
      break
    fi
  done
  if [[ "${JIRA_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of Jira. Check the container logs using the command: sudo docker logs -f jira \e[0m"
    exit 1
  fi
}

#############################################################################################
# Add a connector to a Jira container
# Globals:
#   CONNECTOR_NAME
# Arguments:
#   None
#############################################################################################
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  chown -R 2001:2001 /connectors/
  docker cp /connectors/${CONNECTOR_NAME} jira:${PLUGIN_DIRECTORY}
}

#############################################################################################
# Check for a connector in the plug-in directory in the Jira container
# Globals:
#   CONNECTOR_NAME
# Arguments:
#   None
# Outputs:
#   Writes the verification status message to stdout
# Returns:
#   0, if the check was successful, non-zero on error
#############################################################################################
check_connector_in_container(){
  docker exec -e CONNECTOR_NAME=${CONNECTOR_NAME} -e PLUGIN_DIRECTORY=${PLUGIN_DIRECTORY} jira bash -c 'test -e ${PLUGIN_DIRECTORY}${CONNECTOR_NAME}'
  if [ $? -ne 0 ]; then
    err "\e[0;31m The connector under test was not added to the container in the /var/atlassian/application-data/jira/plugins directory \e[0m"
    exit 1
  else
    echo -e "\e[0;32m The connector was successfully added to Jira. Ready to go \e[0m"
  fi
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
  install_jira
  check_launch_jira
  prepare_connector
  check_connector_in_container
  complete_installation
}

main
