#!/usr/bin/env bash
#
# Prepare a stand with tuleap with a dependent service Onlyoffice Document Server and add a connector

APP='tuleap'
SERVICE_TAG='latest'
TULEAP_SYS_DBPASSWD='yYNgQ1'
SITE_ADMINISTRATOR_PASSWORD='yYNgQ1'
MYSQL_ROOT_PASSWORD='yYNgQ1'
JWT_SECRET='MfqqGX16TiFHsKfJwOjdRx6DSL49gbAY'

###############################################################################################
# Check the passed parameters and their values and assign the received values to variables
# Arguments:
#   Domain mane, application version, path to the connector under test
# Outputs:
#   If there are no parameters, writes a message to stdout
###############################################################################################
if [ "$1" == "" ]; then
  echo -e "\e[0;33m Warning: Basic parameters are missing. The default values will be used \e[0m"
fi
while [ "$1" != "" ]; do
  case $1 in
    -dn | --domain_name )
      if [ "$2" != "" ]; then
        TULEAP_FQDN=$2
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

if [ "$TULEAP_FQDN" == "" ]; then
  echo "Empty domain name"
  exit 1
fi

#########################################
# Getting a certificate from letsencrypt
#########################################
get_cert() {
  docker run --rm --name certbot -p 80:80 -v "/etc/letsencrypt:/etc/letsencrypt" -v "/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot certonly --standalone -n -m example@gmail.com -d "${TULEAP_FQDN}" --agree-tos
  mkdir -p /etc/nginx/ssl
  cp /etc/letsencrypt/live/${TULEAP_FQDN}/fullchain.pem /etc/nginx/ssl
  cp /etc/letsencrypt/live/${TULEAP_FQDN}/privkey.pem /etc/nginx/ssl
}

#############################################################################################
# Install the necessary dependencies on the host and install nuxeo and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_app() {
  source /app/common/install_dependencies.sh
  source /app/common/jwt_configuration.sh
  install_dependencies
  jwt_configuration
  export SERVICE_TAG="${SERVICE_TAG}"
  export TULEAP_FQDN="${TULEAP_FQDN}"
  export TULEAP_SYS_DBPASSWD="${TULEAP_SYS_DBPASSWD}"
  export SITE_ADMINISTRATOR_PASSWORD="${SITE_ADMINISTRATOR_PASSWORD}"
  export MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"
  export JWT_ENV='JWT_SECRET='$JWT_SECRET
  cd /app/tuleap
  envsubst < docker-compose.yml | docker-compose -f - up -d
  docs_ready_check
  docker exec -it onlyoffice-document-server /var/www/onlyoffice/documentserver/npm/json -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.requestDefaults.rejectUnauthorized=false'
  docker exec -it onlyoffice-document-server supervisorctl restart all
}

docs_ready_check() {
  echo -e "\e[0;32m Waiting for the launch of DocumentServer... \e[0m"
  for i in {1..30}; do
    echo "Getting the DocumentServer status: ${i}"
    OUTPUT="$(curl -Is https://$TULEAP_FQDN/ds-vpath/healthcheck/ | head -1 | awk '{ print $2 }')"
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
    err "\e[0;31m Something goes wrong documentserver does not started, check logs with command --> docker logs -f onlyoffice-document-server \e[0m"
    exit 1
  fi
}

check_app() {
  echo -e "\e[0;32m Waiting for the launch of $APP \e[0m"
  for i in {1..30}; do
    echo "Getting the $APP status: ${i}"
    OUTPUT="$(curl -Is https://${TULEAP_FQDN} | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m $APP is ready to serve \e[0m"
      local APP_READY
      APP_READY='yes'
      break
    else
      sleep 30
    fi
  done
  if [[ "${APP_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of $APP \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the $APP web interface at https://${TULEAP_FQDN} and follow a few configuration steps \e[0m"
}

main() {
  install_app
  check_app
  complete_installation
}

main

