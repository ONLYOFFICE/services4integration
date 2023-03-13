#!/bin/bash

SERVICE_TAG=""
BRANCH="main"

while [ "$1" != "" ]; do
   case $1 in
      -st | --service-tag )
      if [ "$2" != "" ]; then
         SERVICE_TAG=$2
         shift
      fi
      ;;
      -b | --branch )
      if [ "$2" != "" ]; then
         BRANCH=$2
         shift
      fi
      ;;
   esac
   shift
done

install_discourse() {
   source /app/common/install_dependencies.sh
   install_dependencies

   curl -sSL https://raw.githubusercontent.com/bitnami/containers/main/bitnami/discourse/docker-compose.yml > docker-compose.yml

   if [ "$SERVICE_TAG" != "" ]; then
      sed -i "s/docker.io\/bitnami\/discourse:.*/docker.io\/bitnami\/discourse:${SERVICE_TAG}/g" docker-compose.yml
   fi

   git clone https://github.com/ONLYOFFICE/onlyoffice-discourse.git -b ${BRANCH}

   # add discourse plugin to discourse service
   sed -i '/^  discourse:$/!b;n;n;n;n;a\      - '\''./onlyoffice-discourse:/bitnami/discourse/plugins/onlyoffice'\''' docker-compose.yml

   docker-compose up -d
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
   install_discourse
   complete_installation
}

main