#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-jira/releases/download/v1.0.1/onlyoffice-jira-app-1.0.1.jar"
CONNECTOR_NAME="onlyoffice-integration-web-jira.jar"
JIRA_NODES=(cluster-jira-node-1)
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}
source /app/common/check_parameters.sh ${@}

install_jira() {
  source /app/common/install_dependencies.sh
  install_dependencies
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

check_launch_jira() {
  echo -e "\e[0;32m Waiting for the launch of Jira \e[0m"
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Getting the ${JIRA_NODES} status: $i"
    docker logs ${JIRA_NODES} | grep -w "Jira is ready to serve"
    if [ $? -ne 0 ]; then
      sleep 5
    else
      echo -e "\e[0;32m Jira Node ${JIRA_NODES} works \e[0m"
      NODE_READY="yes"
      break
    fi
  done
  if [[ "$NODE_READY" != "yes" ]]; then
    echo -e "\e[0;31m I didn't wait for the launch of ${JIRA_NODES}. Check the container logs using the command: sudo docker logs -f ${JIRA_NODES} \e[0m"
    exit 1
  fi
}

prepare_connector() {
  source /app/common/get_connector.sh
  get_connector
  cp /connectors/${CONNECTOR_NAME} /jira/share/plugins/installed-plugins/
  chown -R 2001:2001 /jira/share/
}

check_connector_in_container() {
  docker exec -e CONNECTOR_NAME=$CONNECTOR_NAME ${JIRA_NODES} bash -c 'test -e /data/jira/sharedhome/plugins/installed-plugins/${CONNECTOR_NAME}'
  if [ $? -ne 0 ]; then
    echo -e "\e[0;31m The connector under test was not added to the container in the /data/jira/sharedhome/plugins/installed-plugins directory \e[0m"
    exit 1
  else
    echo -e "\e[0;32m The connector was successfully added \e[0m"
  fi
}

database_initialization() {
  echo "Database initialization begins. Please wait..."
  sleep 25
  curl -L http://${IPADDR[0]}
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Readiness check: $i"
    docker logs ${JIRA_NODES} | grep -w "Upgrade Succeeded! JIRA has been upgraded"
    if [ $? -ne 0 ]; then
      sleep 5
    else
      echo -e "\e[0;32m Initialization completed successfully \e[0m"
      DATABASE_READY="yes"
      break
    fi
  done
  if [[ "$DATABASE_READY" != "yes" ]]; then
    echo -e "\e[0;31m Readiness check failed. Check the container logs using the command: sudo docker logs -f ${JIRA_NODES} \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Jira is ready for further configuration \e[0m"
  echo -e "\e[0;32m Now you can go to the Jira web interface at http://${IPADDR[0]}/ and follow a few configuration steps \e[0m"
}

install_jira
check_launch_jira
prepare_connector
check_connector_in_container
database_initialization
complete_installation
