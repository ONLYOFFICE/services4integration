#!/usr/bin/env bash
CONTENT_REPO_TAG=""
SHARE_TAG=""
CONNECTOR_REPO_NAME=onlyoffice-integration-repo.amp
CONNECTOR_SHARE_NAME=onlyoffice-integration-share.amp
CONNECTOR_REPO_URL=https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/v6.1.0/onlyoffice-integration-repo.amp
CONNECTOR_SHARE_URL=https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/v6.1.0/onlyoffice-integration-share.amp
JWT_ENABLED=""
JWT_SECRET=mysecret
source /app/common/jwt_configuration.sh

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

    -je | --jwt_enabled )
      if [ "$2" != "" ]; then
        JWT_ENABLED=$2
        shift
      fi
    ;;

    -js | --jwt_secret )
      if [ "$2" != "" ]; then
        JWT_SECRET=$2
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
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
  git clone https://github.com/Alfresco/acs-deployment.git /opt/alfresco
  sed -i 's/localhost/'${IP_ARR[0]}'/g' /opt/alfresco/docker-compose/community-docker-compose.yml
  sed -i 's/127.0.0.1/'${IP_ARR[0]}'/g' /opt/alfresco/docker-compose/community-docker-compose.yml
  if [ -z "$CONTENT_REPO_TAG" ]; then
    CONTENT_REPO_TAG=$(yq '.services.alfresco.image' /opt/alfresco/docker-compose/community-docker-compose.yml | sed 's/.*://')
    SHARE_TAG=$(yq '.services.share.image' /opt/alfresco/docker-compose/community-docker-compose.yml | sed 's/.*://')
  fi
  conftgure_dockerfile
  yq -i 'del(.services.alfresco.image)' /opt/alfresco/docker-compose/community-docker-compose.yml
  yq -i 'del(.services.share.image)' /opt/alfresco/docker-compose/community-docker-compose.yml
  yq -i '.services.alfresco.build.context = "/opt/alfresco/docker-compose/alfresco"' /opt/alfresco/docker-compose/community-docker-compose.yml
  yq -i '.services.share.build.context = "./share"' /opt/alfresco/docker-compose/community-docker-compose.yml
  cp /connectors/onlyoffice-integration-repo.amp /opt/alfresco/docker-compose/alfresco
  cp /connectors/onlyoffice-integration-share.amp /opt/alfresco/docker-compose/share
  docker-compose -f /opt/alfresco/docker-compose/community-docker-compose.yml up -d
}

conftgure_dockerfile() {
mkdir /opt/alfresco/docker-compose/alfresco
mkdir /opt/alfresco/docker-compose/share
echo 'FROM alfresco/alfresco-content-repository-community:'${CONTENT_REPO_TAG}'

# Customize container: install amps

ARG ALF_GROUP=Alfresco
ARG TOMCAT_DIR=/usr/local/tomcat

USER root

ADD ./onlyoffice-integration-repo.amp ${TOMCAT_DIR}/amps/

RUN java -jar ${TOMCAT_DIR}/alfresco-mmt/alfresco-mmt*.jar install \
    ${TOMCAT_DIR}/amps ${TOMCAT_DIR}/webapps/alfresco -directory -nobackup -verbose -force

# Restore permissions
RUN chgrp -R ${ALF_GROUP} ${TOMCAT_DIR}/webapps && \
    find ${TOMCAT_DIR}/webapps -type d -exec chmod 0750 {} \; && \
    find ${TOMCAT_DIR}/webapps -type f -exec chmod 0640 {} \; && \
    find ${TOMCAT_DIR}/shared -type d -exec chmod 0750 {} \; && \
    find ${TOMCAT_DIR}/shared -type f -exec chmod 0640 {} \; && \
    chmod -R g+r ${TOMCAT_DIR}/webapps && \
    chgrp -R ${ALF_GROUP} ${TOMCAT_DIR}

USER alfresco
' > /opt/alfresco/docker-compose/alfresco/Dockerfile
echo 'FROM alfresco/alfresco-share:'${SHARE_TAG}'

ARG TOMCAT_DIR=/usr/local/tomcat

ADD ./onlyoffice-integration-share.amp ${TOMCAT_DIR}/amps_share/

RUN java -jar ${TOMCAT_DIR}/alfresco-mmt/alfresco-mmt*.jar install \
    ${TOMCAT_DIR}/amps_share ${TOMCAT_DIR}/webapps/share -directory -nobackup -verbose -force
' > /opt/alfresco/docker-compose/share/Dockerfile

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
  jwt_configuration
  docker run -i -t -d -p 3000:80 -e $JWT_ENV --restart=always onlyoffice/documentserver
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
