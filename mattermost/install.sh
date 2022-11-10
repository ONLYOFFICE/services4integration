#!/usr/bin/env bash
#
# Deploying a stand for testing Mattermost
DN=""
CONNECTOR_NAME="com.onlyoffice.mattermost.tar.gz"
CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-mattermost/releases/download/v1.0.0/com.onlyoffice.mattermost-1.0.0.tar.gz"
SERVICE_TAG="6.1"
source /app/common/install_dependencies.sh

if [ "$1" == "" ]; then
  echo "Basic parameters are missing. Use: -? | -h | --help"
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    -dn | --domain_name )
      if [ "$2" != "" ]; then
        DN=$2
        shift
      fi
      ;;
    -st | --service_tag )
      if [ "$2" != "" ]; then
        SERVICE_TAG=$2
        shift
      fi
      ;;
    -cu | --connector_url )
      if [ "$2" != "" ]; then
        CONNECTOR_URL=$2
        shift
      fi
      ;;
  esac
  shift
done

#########################################
# Getting a certificate from letsencrypt
#########################################
get_cert() {
  docker run --rm --name certbot -p 80:80 -v "/etc/letsencrypt:/etc/letsencrypt" -v "/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot certonly --standalone -n -m example@gmail.com -d "${DN}" --agree-tos
}
#############################################################################################
# Configure NGINX as a reverse proxy for documentserver
# Globals:
#   arr
#############################################################################################
nginx_configure() {
  arr=($( grep -n "}" /opt/mattermost/nginx/conf.d/default.conf | cut -d: -f1 ))
  for var in ${arr[@]}; do
    if [[ "$(grep -n "location / {" /opt/mattermost/nginx/conf.d/default.conf | cut -d: -f1)" -le "${var}" ]]; then
      var=$(($var+1))
      sed -i $var'i\    include /etc/nginx/conf.d/ds/ds.conf;' /opt/mattermost/nginx/conf.d/default.conf
      break
    fi
  done
  mkdir /opt/mattermost/nginx/conf.d/ds
  cp /app/mattermost/ds.conf /opt/mattermost/nginx/conf.d/ds
}
#############################################################################################
# Deploying and configuring mattermost
# Globals:
#   DN
#   SERVICE_TAG
#   CONNECTOR_NAME
#############################################################################################
install() {
  git clone --depth=1 https://github.com/mattermost/docker /opt/mattermost
  cp /opt/mattermost/env.example /opt/mattermost/.env
  sed -i 's/DOMAIN=.*/DOMAIN='${DN}'/' /opt/mattermost/.env
  sed -i 's/CERT_PATH=.*/CERT_PATH=\/etc\/letsencrypt\/live\/'${DN}'\/fullchain.pem/' /opt/mattermost/.env
  sed -i 's/KEY_PATH=.*/KEY_PATH=\/etc\/letsencrypt\/live\/'${DN}'\/privkey.pem/' /opt/mattermost/.env
  sed -i 's/MATTERMOST_IMAGE_TAG=.*/MATTERMOST_IMAGE_TAG='${SERVICE_TAG}'/' /opt/mattermost/.env
  mkdir -p /opt/mattermost/volumes/app/mattermost/{config,data,logs,plugins,client/plugins}
  chown -R 2000:2000 /opt/mattermost/volumes/app/mattermost
  nginx_configure
  docker-compose -f /opt/mattermost/docker-compose.yml -f /opt/mattermost/docker-compose.nginx.yml up -d
  sed -i 's/"EnableUploads": false,/"EnableUploads": true,/' /opt/mattermost/volumes/app/mattermost/config/config.json
  source /app/common/get_connector.sh
  get_connector
  tar -xf /connectors/$CONNECTOR_NAME -C /opt/mattermost/volumes/app/mattermost/plugins
  docker restart mattermost
  docker run -i -t -d --name documentserver --net mattermost -e JWT_SECRET=mysecret onlyoffice/documentserver
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
}

main() {
  install_dependencies
  get_cert
  install
  complete_installation
}

main
