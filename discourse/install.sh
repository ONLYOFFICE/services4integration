#!/bin/bash
#
# Prepare a stand with suitecrm with a dependent service Onlyoffice Document Server and add a connector

IP=$(hostname -I)
IP_ARR=($IP)
SERVICE_TAG=""
JWT_ENABLED=""
JWT_SECRET=mysecret
BRANCH_NAME="main"
source /app/common/error.sh
source /app/common/check_parameters.sh
source /app/common/jwt_configuration.sh

while [ "$1" != "" ]; do
   case $1 in
      -bn | --branch )
      if [ "$2" != "" ]; then
         BRANCH_NAME=$2
         shift
      fi
      ;;
   esac
   shift
done

#############################################################################################
# Install the necessary dependencies on the host and install discourse and dependent service
# Globals:
#   SERVICE_TAG
#   BRANCH_NAME
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_discourse() {
   source /app/common/install_dependencies.sh
   install_dependencies
   curl -sSL https://raw.githubusercontent.com/bitnami/containers/main/bitnami/discourse/docker-compose.yml > docker-compose.yml
   
   if [ "$SERVICE_TAG" != "" ]; then
      sed -i "s/docker.io\/bitnami\/discourse:.*/docker.io\/bitnami\/discourse:${SERVICE_TAG}/g" docker-compose.yml
   fi

   # add onlyoffice plugin to discourse service
   git clone https://github.com/ONLYOFFICE/onlyoffice-discourse.git -b ${BRANCH_NAME}
   sed -i '/^  discourse:$/!b;n;n;n;n;a\      - '\''./onlyoffice-discourse:/bitnami/discourse/plugins/onlyoffice'\''' docker-compose.yml
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
   for i in {1..20}; do
      DISCOURSE_STATUS_CODE=$(curl -sL -o /dev/null -w "%{http_code}" http://localhost:80)
      DS_STATUS=$(curl -sL http://localhost:3000/healthcheck)

      if [ "$DISCOURSE_STATUS_CODE" == "200" ] && [ "$DS_STATUS" == "true" ]; then
         echo -e "\e[0;32m The services are ready \e[0m"
         break
      elif [ "$DISCOURSE_STATUS_CODE" != "200" ] && [ "$DS_STATUS" != "true" ]; then
         echo -e "\e[0;31m The services are not ready \e[0m"
      elif [ "$DISCOURSE_STATUS_CODE" != "200" ]; then
         echo -e "\e[0;31m The discourse service is not ready \e[0m"
      elif [ "$DS_STATUS" != "true" ]; then
         echo -e "\e[0;31m The Onlyoffice Document Server service is not ready \e[0m"
      fi

      sleep 10
   done

}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
   install_discourse
   install_documentserver
   readiness_check
   complete_installation
}

main