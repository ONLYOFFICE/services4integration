#!/usr/bin/env bash
#
# Prepare a stand with a Jira cluster with dependent services Haproxy, PostgreSQL, Onlyoffice Document Server, install the first node of the cluster and add a connector

SERVICE_TAG='latest'
CONNECTOR_URL='https://github.com/ONLYOFFICE/onlyoffice-jira/releases/download/v1.0.1/onlyoffice-jira-app-1.0.1.jar'
CONNECTOR_NAME='onlyoffice-integration-web-jira.jar'
JIRA_NODES='cluster-jira-node-1'
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}
JWT_SECRET='mysecret'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

################################################################################################################
# Install the necessary dependencies on the host and install the first node of the cluster and the dependent services
# Globals:
#   SERVICE_TAG
#   IP_PROXY
#   JIRA_NODE_ID
# Arguments:
#   None
# Outputs:
#   Writes the installation message to stdout
################################################################################################################
install_jira() {
  source /app/common/install_dependencies.sh
  install_dependencies
  jwt_configuration
  export SERVICE_TAG="${SERVICE_TAG}"
  export IP_PROXY="${IP_PROXY}"
  export JIRA_NODE_ID=jira_node_1
  mkdir -p /jira/share/plugins/installed-plugins
  chown -R 2001:2001 /jira/share/
  docker network create --driver bridge onlyoffice
  cd /app/jira/cluster/
  envsubst < docker-compose.yml | docker-compose -f - up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}

################################################################################################################
# Check the launch and status of the first node of the Jira cluster
# Globals:
#   JIRA_NODES
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
################################################################################################################
check_launch_jira() {
  echo -e "\e[0;32m Waiting for the launch of Jira \e[0m"
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Getting the ${JIRA_NODES} status: ${i}"
    docker logs ${JIRA_NODES} | grep -w "Jira is ready to serve"
    if [[ "$?" -ne 0 ]]; then
      sleep 5
    else
      echo -e "\e[0;32m Jira Node ${JIRA_NODES} works \e[0m"
      local NODE_READY
      NODE_READY='yes'
      break
    fi
  done
  if [[ "${NODE_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of ${JIRA_NODES}. Check the container logs using the command: sudo docker logs -f ${JIRA_NODES} \e[0m"
    exit 1
  fi
}

################################################################################################################
# Add a connector to the shared directory of the Jira cluster
# Globals:
#   CONNECTOR_NAME
# Arguments:
#   None
################################################################################################################
prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  cp /connectors/${CONNECTOR_NAME} /jira/share/plugins/installed-plugins/
  chown -R 2001:2001 /jira/share/
}

################################################################################################################
# Checking the presence of the connector in the shared directory of the cluster through the first node
# Globals:
#   JIRA_NODES
#   CONNECTOR_NAME
# Arguments:
#   None
# Outputs:
#   Writes the verification status message to stdout
# Returns:
#   0, if the check was successful, non-zero on error
################################################################################################################
check_connector_in_container() {
  docker exec -e CONNECTOR_NAME=${CONNECTOR_NAME} ${JIRA_NODES} bash -c 'test -e /data/jira/sharedhome/plugins/installed-plugins/${CONNECTOR_NAME}'
  if [ $? -ne 0 ]; then
    err "\e[0;31m The connector under test was not added to the container in the /data/jira/sharedhome/plugins/installed-plugins directory \e[0m"
    exit 1
  else
    echo -e "\e[0;32m The connector was successfully added \e[0m"
  fi
}

################################################################################################################
# Initializing the database with the parameters specified in docker-compose before using Jira
# Globals:
#   JIRA_NODES
#   IPADDR[0]
# Arguments:
#   None
# Outputs:
#   Writes a message about the initialization result to stdout
# Returns:
#   0, if initialization was successful, non-zero on error
################################################################################################################
database_initialization() {
  echo "Database initialization begins. Please wait..."
  sleep 25
  curl -L http://${IPADDR[0]}
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Readiness check: ${i}"
    docker logs ${JIRA_NODES} | grep -w "Upgrade Succeeded! JIRA has been upgraded"
    if [[ "$?" -ne 0 ]]; then
      sleep 5
    else
      echo -e "\e[0;32m Initialization completed successfully \e[0m"
      local DATABASE_READY
      DATABASE_READY='yes'
      break
    fi
  done
  if [[ "${DATABASE_READY}" != 'yes' ]]; then
    err "\e[0;31m Readiness check failed. Check the container logs using the command: sudo docker logs -f ${JIRA_NODES} \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Jira is ready for further configuration \e[0m"
  echo -e "\e[0;32m Now you can go to the Jira web interface at http://${IPADDR[0]}/ and follow a few configuration steps \e[0m"
}

main() {
  install_jira
  check_launch_jira
  prepare_connector
  check_connector_in_container
  database_initialization
  complete_installation
}

main
