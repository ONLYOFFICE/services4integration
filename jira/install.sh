#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-jira"
CONNECTOR_NAME="onlyoffice-integration-web-jira.jar"
source /app/common/check_parameters.sh ${@}
install_jira(){
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d --restart=always --name onlyoffice-document-server -p 3000:80 onlyoffice/documentserver
  docker run -i -t -d --restart=always --name jira -p 8080:8080 atlassian/jira-software:${SERVICE_TAG}
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
check_launch_jira(){
  echo -e "\e[0;32m Waiting for the launch of Jira \e[0m"
  for i in {1..30}; do
    echo "Getting the Jira status: $i"
    docker logs jira | grep -w "Jira is ready to serve"
    if [ $? -ne 0 ]; then
      if [[ "$i" == '29' ]]; then
        echo -e "\e[0;31m I didn't wait for the launch of Jira. Check the container logs using the command: sudo docker logs -f Jira \e[0m"
        exit 1
      else
        sleep 5
      fi
    else
      echo -e "\e[0;32m Jira works \e[0m"
      break
    fi
  done
}
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  chown -R 2001:2001 /connectors/
}
add_connector_to_container(){
  docker cp /connectors/${CONNECTOR_NAME} jira:/var/atlassian/application-data/jira/plugins/installed-plugins/
  docker exec jira bash -c 'test -e /var/atlassian/application-data/jira/plugins/installed-plugins/${CONNECTOR_NAME}'
  if [ $? -ne 0 ]; then
    echo -e "\e[0;31m The connector under test was not added to the container in the /var/atlassian/application-data/jira/plugins directory \e[0m"
    exit 1
  else
    echo -e "\e[0;32m The connector was successfully added to liferay. Ready to go \e[0m"
  fi
}
complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}
install_jira
check_launch_jira
prepare_connector
add_connector_to_container
complete_installation
