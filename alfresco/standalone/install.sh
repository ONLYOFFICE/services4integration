#!/usr/bin/env bash  
CONTENT_REPO_TAG=""
SHARE_TAG=""
CONNECTOR_REPO_NAME=onlyoffice-integration-repo.jar
CONNECTOR_SHARE_NAME=onlyoffice-integration-share.jar
CONNECTOR_REPO_URL=https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/v5.0.1/onlyoffice-integration-repo.jar
CONNECTOR_SHARE_URL=https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/v5.0.1/onlyoffice-integration-share.jar
  
while [ "$1" != "" ]; do
  case $1 in
 
    -ct | --content_repo_tag )
      if [ "$2" != "" ]; then
        CONTENT_REPO_TAG=$2
        shift
      fi
    ;;
 
    -st | --share_tag )
      if [ "$2" != "" ]; then
        SHARE_TAG=$2
        shift
      fi
    ;;

    -cu | --content_repo_url )
      if [ "$2" != "" ]; then
        CONNECTOR_REPO_URL=$2
        shift
      fi
    ;;

    -su | --share_url )
      if [ "$2" != "" ]; then
        CONNECTOR_SHARE_URL=$2
        shift
      fi
    ;;

    * )
      echo "Unknown parameter $1" 1>&2
      exit 0
    ;;
  esac
  shift
done

if [ -z "$CONTENT_REPO_TAG" -a -n "$SHARE_TAG" ] || [ -n "$CONTENT_REPO_TAG" -a -z "$SHARE_TAG" ]; then
  echo "missing CONTENT_REPO_TAG or SHARE_TAG"
    exit 1
fi

get_connector() {
  echo -e "\e[0;32m The connector will now be downloaded to the host \e[0m"
  mkdir /connectors
  wget -O /connectors/${CONNECTOR_REPO_NAME} ${CONNECTOR_REPO_URL}
  wget -O /connectors/${CONNECTOR_SHARE_NAME} ${CONNECTOR_SHARE_URL}
  if [ ! -f "/connectors/${CONNECTOR_REPO_NAME}" ] || [ ! -f "/connectors/${CONNECTOR_SHARE_NAME}" ]; then
    echo -e "\e[0;31m The connector under test was not added to the /connectors directory \e[0m"]
    exit 1
  fi
  CONNECTOR_REPO_SIZE="$(du /connectors/${CONNECTOR_REPO_NAME} | awk '{print $1}')"
  CONNECTOR_SHARE_SIZE="$(du /connectors/${CONNECTOR_SHARE_NAME} | awk '{print $1}')"
  if [ "${CONNECTOR_REPO_SIZE}" == '0' ] || [ "${CONNECTOR_SHARE_SIZE}" == '0' ]; then
    echo -e "\e[0;31m The size of the connector is 0, check that the connector is loaded correctly \e[0m"
    exit 1
  fi
}

configure_compose() {
  git clone https://github.com/Alfresco/acs-deployment.git /opt/alfresco
  str=$(grep -n "  alfresco:" /opt/alfresco/docker-compose/community-docker-compose.yml | cut -d: -f1)
  str=$(($str+1))
  sed -i $str'i\      - /connectors/'${CONNECTOR_REPO_NAME}':/usr/local/tomcat/webapps/alfresco/WEB-INF/lib/'${CONNECTOR_REPO_NAME}'' /opt/alfresco/docker-compose/community-docker-compose.yml
  sed -i $str'i\    volumes:' /opt/alfresco/docker-compose/community-docker-compose.yml
  str=$(grep -n "  share:" /opt/alfresco/docker-compose/community-docker-compose.yml | cut -d: -f1)
  str=$(($str+1))
  sed -i $str'i\      - /connectors/'${CONNECTOR_SHARE_NAME}':/usr/local/tomcat/webapps/share/WEB-INF/lib/'${CONNECTOR_SHARE_NAME}'' /opt/alfresco/docker-compose/community-docker-compose.yml
  sed -i $str'i\    volumes:' /opt/alfresco/docker-compose/community-docker-compose.yml
  sed -i 's/localhost/'${IP_ARR[0]}'/g' /opt/alfresco/docker-compose/community-docker-compose.yml
  sed -i 's/127.0.0.1/'${IP_ARR[0]}'/g' /opt/alfresco/docker-compose/community-docker-compose.yml
  if [ -n "$CONTENT_REPO_TAG" ]; then
    sed -i 's/image: alfresco\/alfresco-content-repository-community:.*/image: alfresco\/alfresco-content-repository-community:'${CONTENT_REPO_TAG}'/' /opt/alfresco/docker-compose/community-docker-compose.yml
    sed -i 's/image: alfresco\/alfresco-share:.*/image: alfresco\/alfresco-share:'${SHARE_TAG}'/' /opt/alfresco/docker-compose/community-docker-compose.yml
  fi
  docker-compose -f /opt/alfresco/docker-compose/community-docker-compose.yml up -d
}

configure_compose_6_X() {
  export HOST="${IP_ARR[0]}"
  export CONTENT_REPO_TAG="${CONTENT_REPO_TAG}"
  export SHARE_TAG="${SHARE_TAG}"
  cd /app/alfresco/standalone
  envsubst < docker-compose.yml | docker-compose -f - up -d
}

install_alfresco() {
  source /app/common/install_dependencies.sh
  install_dependencies
  IP=$(hostname -I)
  IP_ARR=($IP)
  if [ ${CONTENT_REPO_TAG:0:1} == 6 ]; then
    configure_compose_6_X;
  else 
    configure_compose;
  fi
}

install_documentserver() {
  docker run -i -t -d -p 3000:80 --restart=always onlyoffice/documentserver
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
  get_connector
  install_alfresco
  install_documentserver
  complete_installation
}
main
