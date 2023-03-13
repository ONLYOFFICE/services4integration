#!/bin/bash

SERVICE_TAG=""

while [ "$1" != "" ]; do
   case $1 in
      -st | --service-tag )
      if [ "$2" != "" ]; then
         SERVICE_TAG=$2
      fi
      ;;
   esac
   shift
done

install_suitecrm() {
   source /app/common/install_dependencies.sh
   install_dependencies

   curl -sSL https://raw.githubusercontent.com/bitnami/containers/main/bitnami/suitecrm/docker-compose.yml > docker-compose.yml

   if [ "$SERVICE_TAG" != "" ]; then
      sed -i "s/docker.io\/bitnami\/suitecrm:.*/docker.io\/bitnami\/suitecrm:$SERVICE_TAG/g" docker-compose.yml
   fi

   docker-compose up -d
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
   install_suitecrm
   complete_installation
}

main