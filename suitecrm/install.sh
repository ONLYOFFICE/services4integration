#!/bin/bash
#
# Prepare a stand with suitecrm with a dependent service Onlyoffice Document Server and add a connector

IP=$(hostname -I)
IP_ARR=($IP)
SERVICE_TAG=""
JWT_ENABLED=""
JWT_SECRET=mysecret
source /app/common/error.sh
source /app/common/check_parameters.sh
source /app/common/jwt_configuration.sh

#############################################################################################
# Install the necessary dependencies on the host and install suitecrm and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_suitecrm() {
   source /app/common/install_dependencies.sh
   install_dependencies

   curl -sSL https://raw.githubusercontent.com/bitnami/containers/main/bitnami/suitecrm/docker-compose.yml > docker-compose.yml

   if [ "$SERVICE_TAG" != "" ]; then
      sed -i "s/docker.io\/bitnami\/suitecrm:.*/docker.io\/bitnami\/suitecrm:$SERVICE_TAG/g" docker-compose.yml
   fi

   docker-compose up -d
}

install_documentserver() {
  jwt_configuration
  docker run -i -t -d -p 3000:80 -e $JWT_ENV --restart=always onlyoffice/documentserver
}

#############################################################################################
# Check the status of the services
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Status of the services
#############################################################################################
readiness_check() {
   for i in {1..10}; do
      SCRM_STATUS_CODE=$(curl -sL -o /dev/null -w "%{http_code}" http://localhost:80)
      DS_STATUS_CODE=$(curl -sL -o /dev/null -w "%{http_code}" http://localhost:3000)
      sleep 10
   done

   if [ "$SCRM_STATUS_CODE" != "200" ] && [ "$DS_STATUS_CODE" != "200" ]; then
      echo -e "\e[0;31m The services are not ready \e[0m"
      return
   elif [ "$SCRM_STATUS_CODE" != "200" ]; then
      echo -e "\e[0;31m SuiteCRM is not ready \e[0m"
      return
   elif [ "$DS_STATUS_CODE" != "200" ]; then
      echo -e "\e[0;31m Onlyoffice Document Server is not ready \e[0m"
      return
   else
      echo -e "\e[0;32m The services are ready \e[0m"
   fi
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
   check_parameters
   install_suitecrm
   install_documentserver
   readiness_check
   complete_installation
}

main