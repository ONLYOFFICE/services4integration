#!/usr/bin/env bash
#
# Prepare a stand with a Confluence cluster with dependent services Haproxy, PostgreSQL, Onlyoffice Document Server, install the first node of the cluster and add a connector

SERVICE_TAG='7.13'
CONNECTOR_URL=''
CONNECTOR_NAME=''
CONFLUENCE_NODES='cluster-confluence-node-1'
ALLIPADDR="$(hostname -I)"
JWT_SECRET='mysecret'
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh
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
  source /app/common/install_dependencies.sh
  install_dependencies
  jwt_configuration
  mkdir -p /confluence/share
  chown -R 2002:2002 /confluence/share/
  export SERVICE_TAG="${SERVICE_TAG}"
  export IP_PROXY="${IP_PROXY}"
  export JWT_ENV="${JWT_ENV}"
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

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Confluence is ready for further configuration \e[0m"
  echo -e "\e[0;32m Now you can go to the Confluence web interface at http://${IPADDR[0]}/ and follow a few configuration steps \e[0m"
}

main() {
  jwt_configuration
  install_confluence
  check_launch_confluence
  complete_installation
}

main
