#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-owncloud/releases/download/v7.1.1/onlyoffice.tar.gz"
CONNECTOR_NAME="onlyoffice.tar.gz"
source /app/common/check_parameters.sh ${@}
install_owncloud_with_onlyoffice(){
  source /app/common/install_dependencies.sh
  install_dependencies
  git clone https://github.com/ONLYOFFICE/docker-onlyoffice-owncloud /apps
  prepare_connector
  prepare_files
  docker-compose -f /apps/docker-compose.yml up -d 
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
prepare_connector(){
  source /app/common/get_connector.sh
  get_connector
  tar -C /apps -xvf /connectors/${CONNECTOR_NAME}
}
prepare_files() {
  sed -i -e  "s!owncloud/server!owncloud/server:${SERVICE_TAG}!g" /apps/docker-compose.yml
}
check_ready() {
apt install jq -y
IP_DS=$(docker inspect onlyoffice-document-server | jq .[].NetworkSettings.Networks.apps_onlyoffice.IPAddress | tr -d '"')

echo -e "\e[0;32m Waiting for the launch of owncloud \e[0m"
for i in {1..30}; do
  if [[ "$(curl --connect-timeout 2 -L -s -o /dev/null -w ''%{http_code}'' http://localhost)" != "200" ]]; then
	echo -e "\e[0;32m Waiting for the launch of owncloud \e[0m"
      sleep 10
    else
      echo -e "\e[0;32m owncloud works \e[0m"
      break
  fi
  if [[ "$i" == '29' ]]; then
	echo -e "\e[0;31m I didn't wait for the launch of owncloud. \e[0m"
	exit 1
  fi
done

echo -e "\e[0;32m Waiting for the launch of document-server \e[0m"
for i in {1..30}; do
  if [[ "$(curl --connect-timeout 2 -L -s -o /dev/null -w ''%{http_code}'' http://$IP_DS)" != "200" ]]; then
	echo -e "\e[0;32m Waiting for the launch of document-server \e[0m"
      sleep 10
    else
      echo -e "\e[0;32m document-server is running \e[0m"
      break
  fi
  if [[ "$i" == '29' ]]; then
	echo -e "\e[0;31m Document server did not start. Check the container logs using the command: sudo docker logs -f document-server \e[0m"
	exit 1
  fi
done
}
complete_installation(){
  EXT_IP=`wget -q -O - ifconfig.me/ip`
  echo -e "\e[0;32m Then you can go to the owncloud web interface at: http://$EXT_IP and check the connector operation. \e[0m"
  echo -e "\e[0;32m The script is finished \e[0m"
}
install_owncloud_with_onlyoffice
check_ready
complete_installation
