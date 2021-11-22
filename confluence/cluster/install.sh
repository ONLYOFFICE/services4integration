#!/usr/bin/env bash
#
# Prepare a stand with a Confluence cluster with dependent services Haproxy, PostgreSQL, Onlyoffice Document Server, install the first node of the cluster and add a connector

SERVICE_TAG='7.13'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-confluence/releases/download/v3.0.1/onlyoffice-confluence-plugin-3.0.1.jar'
CONNECTOR_NAME='onlyoffice-integration-web-confluence.jar'
CONFLUENCE_NODES='cluster-confluence-node-1'
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh

##############################################################################
# Install the necessary dependencies on the host
# Arguments:
#   None
##############################################################################
install_dependencies() {
  source /app/common/install_dependencies.sh
  install_dependencies
}

##############################################################################
# Add a connector to the shared directory of the Confluence cluster
# Globals:
#   CONNECTOR_NAME
# Arguments:
#   None
##############################################################################
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  mkdir -p /confluence/share
  chown -R 2002:2002 /confluence/share/
  cp /connectors/${CONNECTOR_NAME} /confluence/
}

##############################################################################
# Install the first node of the cluster and dependent services
# Globals:
#   SERVICE_TAG
#   IP_PROXY
# Arguments:
#   None
# Outputs:
#   Writes the installation message to stdout
##############################################################################
install_confluence() {
  export SERVICE_TAG="${SERVICE_TAG}"
  export IP_PROXY="${IP_PROXY}"
  docker network create --driver bridge onlyoffice
  cd /app/confluence/cluster/
  envsubst < docker-compose.yml | docker-compose -f - up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}

##############################################################################
# Check the launch and status of the first node of the Confluence cluster
# Globals:
#   CONFLUENCE_NODES
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
##############################################################################
check_launch_confluence() {
  echo -e "\e[0;32m Waiting for the launch of Confluence \e[0m"
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Getting the ${CONFLUENCE_NODES} status: ${i}"
    CODE="$(curl -m 3 -s -o /dev/null -w '%{http_code}' http://localhost/status)"
    if [[ "${CODE}" != '200' ]]; then
      sleep 5
    else
      echo -e "\e[0;32m Confluence Node ${CONFLUENCE_NODES} works \e[0m"
      local NODE_READY
      NODE_READY='yes'
      break
    fi
  done
  if [[ "${NODE_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of ${CONFLUENCE_NODES}. Check the container logs using the command: sudo docker logs -f ${CONFLUENCE_NODES} \e[0m"
    exit 1
  fi
}

###########################################################################################################
# Check the presence of the connector in the first node of the cluster
# Globals:
#   CONFLUENCE_NODES
#   CONNECTOR_NAME
# Arguments:
#   None
# Outputs:
#   Writes the verification status message to stdout
# Returns:
#   0, if the check was successful, non-zero on error
###########################################################################################################
check_connector_in_container() {
  echo "Checking the presence of the connector in the first node of the cluster"
  docker exec -e CONNECTOR_NAME=${CONNECTOR_NAME} ${CONFLUENCE_NODES} bash -c 'test -e /opt/atlassian/confluence/confluence/WEB-INF/atlassian-bundled-plugins/${CONNECTOR_NAME}'
  if [ $? -ne 0 ]; then
    err "\e[0;31m The connector under test was not added to the container in the /opt/atlassian/confluence/confluence/WEB-INF/atlassian-bundled-plugins directory \e[0m"
    exit 1
  else
    echo -e "\e[0;32m The connector was successfully added \e[0m"
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Confluence is ready for further configuration \e[0m"
  echo -e "\e[0;32m Now you can go to the Confluence web interface at http://${IPADDR[0]}/ and follow a few configuration steps \e[0m"
}

main() {
  install_dependencies
  prepare_connector
  install_confluence
  check_launch_confluence
  check_connector_in_container
  complete_installation
}

main
