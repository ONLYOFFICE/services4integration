#!/bin/bash
liferay_tag=${1:-"7.4.0-ga1"}
install_liferay(){
  apt-get update && apt-get install -y apt-transport-https curl wget ca-certificates software-properties-common gnupg2 ntp
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update
  apt install -y docker-ce=5:19.03.11* docker-ce-cli=5:19.03.11*
  curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  docker run -i -t -d --restart=always --name onlyoffice-document-server -p 3000:80 onlyoffice/documentserver
  docker run -i -t -d --restart=always --name liferay -p 80:8080 liferay/portal:${liferay_tag}
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
check_launch_liferay(){
  echo -e "\e[0;32m Waiting for the launch of liferay \e[0m"
  for i in {1..29}; do
    echo "Getting the liferay status: $i"
    docker ps | grep liferay | grep -w healthy
    if [ $? -ne 0 ]; then
      if [[ "$i" == '25' ]]; then
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
check_existence_connector(){
  echo -e "\e[0;32m The connector will now be added to the container \e[0m"
  ssh -o StrictHostKeyChecking=no onlyoffice@37.61.218.148 "test -e /connectors/liferay/onlyoffice.integration.web*"
  if [ $? -ne 0 ]; then
    echo -e "\e[0;31m The liferay connector was not added to the host 37.61.218.148 in the /connectors/liferay directory \e[0m"
    exit 1
  fi
  scp -o StrictHostKeyChecking=no onlyoffice@37.61.218.148:/connectors/liferay/onlyoffice.integration.web* /connectors/liferay/
  chown -R 1000:1000 /connectors/liferay/
}
add_connector_to_container(){
  docker cp /connectors/liferay/onlyoffice.integration.web* liferay:/opt/liferay/deploy/
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
  rm -rf /connectors/liferay/onlyoffice.integration.web*
  ssh -o StrictHostKeyChecking=no onlyoffice@37.61.218.148 "rm -rf /connectors/liferay/onlyoffice.integration.web*"
  echo -e "\e[0;32m The script is finished \e[0m"
}
install_liferay
check_launch_liferay
check_existence_connector
add_connector_to_container
complete_installation
