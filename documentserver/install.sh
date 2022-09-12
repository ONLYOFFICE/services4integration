#!/usr/bin/env bash
  
# Prepare a pure documentserver standalone stand without any connectors.

SERVICE_TAG="7.1.1"
IP_ADDR_INT="$(hostname -I | awk '{print $1}')"
IP_ADDR_EXT="$(wget -q -O - ifconfig.me/ip)"

install_onlyoffice_documentserver() {
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d -p 3000:80 --restart=always onlyoffice/documentserver:${SERVICE_TAG}
  ready_check
}

ready_check () {
  while [ "$STATUS" != "200" ]
    do
    echo "Waiting to ready document-server..."
    STATUS=$(curl -s -o /dev/null -w "%{http_code}\n" http:/localhost:3000/healthcheck/)
    sleep 10
  done
  echo -e "\e[0;32m Document-Server is running \e[0m"
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can get access to DocumentServer at http://${IP_ADDR_INT}/ or http://${IP_ADDR_EXT}/ and start testing functionality \e[0m"
}

main() {
install_onlyoffice_documentserver
ready_check
complete_installation
}

main
