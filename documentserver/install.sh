#!/usr/bin/env bash
  
# Prepare a pure documentserver standalone stand without any connectors.

SERVICE_TAG="latest"
IP_ADDR_INT="$(hostname -I | awk '{print $1}')"
IP_ADDR_EXT="$(wget -q -O - ifconfig.me/ip)"
CONTAINER_NAME=documentserver
source /app/common/check_parameters.sh
source /app/common/error.sh

#############################################################################################
# Install the necessary dependencies on the host and run DocumentServer 
# Globals:
#   SERVICE_TAG CONTAINER_NAME
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_onlyoffice_documentserver() {
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d -p 80:80 --name ${CONTAINER_NAME} --restart=always onlyoffice/documentserver:${SERVICE_TAG}
}

#############################################################################################
# Check DocumentServer startup and status
# Globals:
#   CONTAINER_NAME
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
ready_check() {
  echo -e "\e[0;32m Waiting for the launch of DocumentServer... \e[0m"  
  for i in {1..30}; do
    echo "Getting the DocumentServer status: ${i}"
    OUTPUT="$(curl -Is http://localhost/healthcheck/ | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m DocumentServer is ready \e[0m"
      local DS_READY
      DS_READY='yes'
      break
    else
      sleep 10
    fi
  done
  if [[ "${DS_READY}" != 'yes' ]]; then
    err "\e[0;31m Something goes wrong documentserver does not started, check logs with command --> docker logs -f ${CONTAINER_NAME} \e[0m"
    exit 1
  fi
}

#############################################################################################
# Replace http-common $scheme 
# Globals:
#   CONTAINER_NAME
# Outputs:
#   Nginx restart result message
# Returns
#   None 
#############################################################################################
prepare_nginx() {
  local HTTP_COMMON="/etc/onlyoffice/documentserver/nginx/includes/http-common.conf"
  docker exec ${CONTAINER_NAME} sed -i 's/$scheme/https/' ${HTTP_COMMON}
  docker exec -it ${CONTAINER_NAME} /bin/bash -c "service nginx restart"
}

#############################################################################################
# Run example after ready_check will be passed
# Globals:
#   CONTAINER_NAME
# Outputs:
#   Writes message that ds:example started correct
# Returns
#   None
#############################################################################################
start_example() {
  docker exec -it ${CONTAINER_NAME} /bin/bash -c "supervisorctl start ds:example"
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can get access to DocumentServer at http://${IP_ADDR_INT}/ or http://${IP_ADDR_EXT}/ and start testing functionality \e[0m"
}

main() {
install_onlyoffice_documentserver
ready_check
start_example
complete_installation
}

main
