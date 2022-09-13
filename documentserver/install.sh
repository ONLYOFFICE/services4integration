#!/usr/bin/env bash
  
# Prepare a pure documentserver standalone stand without any connectors.

SERVICE_TAG="latest"
IP_ADDR_INT="$(hostname -I | awk '{print $1}')"
IP_ADDR_EXT="$(wget -q -O - ifconfig.me/ip)"

install_onlyoffice_documentserver() {
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d -p 80:80 --restart=always onlyoffice/documentserver:${SERVICE_TAG}
}

ready_check() {
  echo -e "\e[0;32m Waiting for the launch of DocumentServer... \e[0m"  
  for i in {1..30}; do
    echo "Getting the DocumentServer status: ${i}"
    OUTPUT="$(curl -Is http://localhost/healthcheck/ | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m DocumentServer is ready \e[0m"
      break
    else
      sleep 10
    fi
  done
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
