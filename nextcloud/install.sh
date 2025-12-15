#!/usr/bin/env bash
SERVICE_TAG="latest"
CONNECTOR_URL=""https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v9.11.0/onlyoffice.tar.gz
CONNECTOR_NAME="onlyoffice.tar.gz"
JWT_SECRET='mysecret'
NGINX_CONF='nginx.conf'
SCHEME='http'
source /app/common/check_parameters.sh "${@}"
source /app/common/error.sh
source /app/common/jwt_configuration.sh

install_nextcloud() {
  source /app/common/install_dependencies.sh
  source /app/common/get_connector.sh
  source /app/common/docs_ready_check.sh
  source /app/common/gen_password.sh
  jwt_configuration
  export SERVICE_TAG="$(echo "$SERVICE_TAG")"
  export APP_ADDR="$(wget -q -O - ifconfig.me/ip)"
  export JWT_ENV="$(echo "$JWT_ENV")"
  install_dependencies
  if [ "${DOMAIN_NAME}" ]; then
    source /app/common/get_cert.sh
    #get_cert
    NGINX_CONF='nginx_https.conf'
    APP_ADDR=${DOMAIN_NAME}
    SCHEME='https'
  fi
  gen_password
  DB_PASSWORD="${PASSWORD}"
  gen_password

  echo 'JWT_ENV='${JWT_ENV}'
SERVICE_TAG='${SERVICE_TAG}'
NEXTCLOUD_ADMIN_PASSWORD='${PASSWORD}'
MYSQL_PASSWORD='${DB_PASSWORD}'
NEXTCLOUD_TRUSTED_DOMAINS='${DOMAIN_NAME}'
NGINX_CONF='${NGINX_CONF}'
TRUSTED_PROXIES=172.25.0.0/16
' > /app/nextcloud/.env
  cd /app/nextcloud/
  docker-compose up -d
}

install_connector() {
  get_connector
  cd /connectors
  tar -xzf "$CONNECTOR_NAME" && rm -f "$CONNECTOR_NAME"
  docker cp /connectors/onlyoffice nextcloud:/var/www/html/apps
  docker exec -d nextcloud sh -c "chown -R www-data:www-data apps/onlyoffice"
}

check_ready() {
for ((i=30; i>0 ; i--)); do
  if [[ "$(curl --connect-timeout 2 -L -s -o /dev/null -w ''%{http_code}'' ${SCHEME}://${APP_ADDR})" != "200" ]]; then
    echo "Waiting to ready"
    sleep 10
  else
    echo "Nextcloud is up on"
    echo "${SCHEME}://${APP_ADDR}"
    echo "Login to server: admin"
    echo "Password: ${PASSWORD}"
    return 1
  fi
done
  echo "Nextcloud is unavailable"
  exit 1
}

#main
install_nextcloud
check_ready
install_connector

