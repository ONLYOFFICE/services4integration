#!/usr/bin/env bash
#
# Prepare a stand with Liferay with the dependent service Onlyoffice Document Server and add a connector

SERVICE_TAG='7.4.0-ga1'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v2.0.0/onlyoffice.integration.web-2.0.0-CE7.4GA1.jar'
CONNECTOR_NAME='onlyoffice-integration-web-liferay.jar'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh

###################################################################################################
# Install the necessary dependencies on the host and install Liferay and the dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   Writes the installation message to stdout
###################################################################################################
install_liferay() {
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d --restart=always --name onlyoffice-document-server -p 3000:80 -e JWT_SECRET=mysecret onlyoffice/documentserver
  docker run -i -t -d --restart=always --name liferay -p 80:8080 liferay/portal:"${SERVICE_TAG}"
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}

###################################################################################################
# Check Liferay startup and status
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
###################################################################################################
check_launch_liferay() {
  echo -e "\e[0;32m Waiting for the launch of Liferay \e[0m"
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Getting the Liferay status: ${i}"
    docker ps | grep liferay | grep -w healthy
    if [[ "$?" -ne 0 ]]; then
      sleep 5
    else
      echo -e "\e[0;32m Liferay works \e[0m"
      local LIFERAY_READY
      LIFERAY_READY='yes'
      break
    fi
  done
  if [[ "${LIFERAY_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of Liferay. Check the container logs using the command: sudo docker logs -f Liferay \e[0m"
    exit 1
  fi
}

###################################################################################################
# Add a connector to a Liferay container
# Globals:
#   CONNECTOR_NAME
# Arguments:
#   None
# Returns:
#   0 if thing was copied, non-zero on error.
###################################################################################################
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  chown -R 1000:1000 /connectors/
  docker cp /connectors/${CONNECTOR_NAME} liferay:/opt/liferay/deploy/
}

###################################################################################################
# Check whether the connector is loaded into the container
# Arguments:
#   None
# Outputs:
#   Writes the verification status message to stdout
# Returns:
#   0, if the check was successful, non-zero on error
###################################################################################################
check_connector_in_container() {
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Checking whether the connector is loaded into the container: ${i}"
    docker logs liferay | grep -i "STARTED onlyoffice.integration.web"
    if [[ "$?" -ne 0 ]]; then
      sleep 5
    else
      echo -e "\e[0;32m The connector was successfully added to liferay. Ready to go \e[0m"
      local CONNECTOR_EXISTS
      CONNECTOR_EXISTS='yes'
      break
    fi
  done
  if [[ "${CONNECTOR_EXISTS}" != 'yes' ]]; then
    err "\e[0;31m An error occurred when adding a connector to liferay. Check the container logs using the command: sudo docker logs -f liferay \e[0m"
    exit 1
  fi
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
  install_liferay
  check_launch_liferay
  prepare_connector
  check_connector_in_container
  complete_installation
}

main
