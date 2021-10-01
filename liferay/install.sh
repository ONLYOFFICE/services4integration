#!/usr/bin/env bash
SERVICE_TAG="7.4.0-ga1"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v2.0.0/onlyoffice.integration.web-2.0.0-CE7.4GA1.jar"
CONNECTOR_NAME="onlyoffice-integration-web-liferay.jar"
source /app/common/check_parameters.sh ${@}
install_liferay(){
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d --restart=always --name onlyoffice-document-server -p 3000:80 onlyoffice/documentserver
  docker run -i -t -d --restart=always --name liferay -p 80:8080 liferay/portal:${SERVICE_TAG}
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
check_launch_liferay(){
  echo -e "\e[0;32m Waiting for the launch of liferay \e[0m"
  for i in {1..30}; do
    echo "Getting the liferay status: $i"
    docker ps | grep liferay | grep -w healthy
    if [ $? -ne 0 ]; then
      if [[ "$i" == '29' ]]; then
        echo -e "\e[0;31m I didn't wait for the launch of liferay. Check the container logs using the command: sudo docker logs -f liferay \e[0m"
        exit 1
      else
        sleep 5
      fi
    else
      echo -e "\e[0;32m liferay works \e[0m"
      break
    fi
  done
}
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  chown -R 1000:1000 /connectors/
}
add_connector_to_container(){
  docker cp /connectors/${CONNECTOR_NAME} liferay:/opt/liferay/deploy/
  for i in {1..19}; do
    echo "Checking whether the connector is loaded into the container: $i"
    docker logs liferay | grep -i "STARTED onlyoffice.integration.web"
    if [ $? -ne 0 ]; then
      if [[ "$i" == '15' ]]; then
        echo -e "\e[0;31m An error occurred when adding a connector to liferay. Check the container logs using the command: sudo docker logs -f liferay \e[0m"
        exit 1
      else
        sleep 5
      fi
    else
      echo -e "\e[0;32m The connector was successfully added to liferay. Ready to go \e[0m"
      break
    fi
  done
}
complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}
install_liferay
check_launch_liferay
prepare_connector
add_connector_to_container
complete_installation
