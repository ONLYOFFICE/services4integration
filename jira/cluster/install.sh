#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-jira/releases/download/v1.0.0/onlyoffice-jira-app-1.0.0.jar"
CONNECTOR_NAME="onlyoffice-integration-web-jira.jar"
JIRA_NODES=(jira-node-1 jira-node-2)
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
source /app/common/check_parameters.sh ${@}
install_jira(){
  source /app/common/install_dependencies.sh
  install_dependencies
  mkdir -p /jira/haproxy
  mkdir -p /jira/share/plugins/installed-plugins
  chown -R 2001:2001 /jira/share/
  sed -i 's/EXTERNALIP/'${IPADDR[0]}'/g' /app/jira/cluster/docker-compose.yml
  sed -i 's/SERVICE_TAG/'${SERVICE_TAG}'/g' /app/jira/cluster/docker-compose.yml
  cp /app/jira/cluster/haproxy.cfg /jira/haproxy/
  docker network create --driver bridge onlyoffice
  docker-compose -f /app/jira/cluster/docker-compose.yml up -d
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
check_launch_jira(){
  echo -e "\e[0;32m Waiting for the launch of Jira \e[0m"
  for name in "${JIRA_NODES[@]}"; do
    for i in {1..30}; do
      echo "Getting the $name status: $i"
      docker logs ${name} | grep -w "Jira is ready to serve"
      if [ $? -ne 0 ]; then
        if [[ "$i" == '29' ]]; then
          echo -e "\e[0;31m I didn't wait for the launch of $name. Check the container logs using the command: sudo docker logs -f $name \e[0m"
          exit 1
        else
          sleep 5
        fi
      else
        echo -e "\e[0;32m Jira Node $name works \e[0m"
        break
      fi
    done
  done
}
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  cp /connectors/${CONNECTOR_NAME} /jira/share/plugins/installed-plugins/
  chown -R 2001:2001 /jira/share/
}
check_connector_in_container(){
  for name in "${JIRA_NODES[@]}"; do
    docker exec ${name} bash -c 'test -e /data/jira/sharedhome/plugins/installed-plugins/${CONNECTOR_NAME}'
    if [ $? -ne 0 ]; then
      echo -e "\e[0;31m The connector under test was not added to the container in the /data/jira/sharedhome/plugins/installed-plugins directory \e[0m"
      exit 1
    else
      echo -e "\e[0;32m The connector was successfully added to ${name}. Ready to go \e[0m"
    fi
  done
}
complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the Jira web interface at http://${IPADDR[0]}:8080/ and follow a few configuration steps \e[0m"
}
install_jira
check_launch_jira
prepare_connector
check_connector_in_container
complete_installation
