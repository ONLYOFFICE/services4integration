#!/usr/bin/env bash
#
# Prepare a stand with strapi with a dependent service Onlyoffice Document Server and add a connector

SERVICE_TAG=""
IP=$(hostname -I)
IP_ARR=($IP)

source /app/common/error.sh
source /app/common/check_parameters.sh

#############################################################################################
# Install the necessary dependencies on the host and install strapi and dependent service
# Globals:
#   SERVICE_TAG
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
install_strapi() {
source /app/common/install_dependencies.sh
install_dependencies
export DEBIAN_FRONTEND=noninteractive ; apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
apt install sqlite aptitude expect -y
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install nodejs -y
aptitude install npm -y
npm install pm2 -g

expect -c 'set timeout -1;
spawn npx create-strapi-app@latest my-project --quickstart --no-run;
expect "Ok to proceed? (y)";
send -- "y\r";
expect eof'

sed -i 's!.*strapi::security.*!{\n  name: "strapi::security",\n  config: {\n    contentSecurityPolicy: {\n      useDefaults: true,\n      directives: {\n        "script-src": ["'self'", "https:", "http:"],\n        "frame-src": ["'self'", "https:", "http:"],\n      },\n    },\n  },\n},!' my-project/config/middlewares.js
cd my-project
if [ "$SERVICE_TAG" != "" ]; then
  SERVICE_TAG=@$SERVICE_TAG
fi
npm install onlyoffice-strapi$SERVICE_TAG --save
npm run build
pm2 start "npm run develop"
docker run -i -t -d -p 3000:80 -e JWT_SECRET=mysecret --restart=always onlyoffice/documentserver
}

#############################################################################################
# Check strapi startup and status
# Globals:
#   IP_ARR
# Outputs:
#   Writes a startup message to stdout
# Returns
#   0, if the start is successful, non-zero on error
#############################################################################################
check_strapi() {
  echo -e "\e[0;32m Waiting for the launch of strapi \e[0m"  
  for i in {1..30}; do
    echo "Getting the strapi status: ${i}"
    OUTPUT="$(curl -Is http://${IP_ARR[0]}:1337 | head -1 | awk '{ print $2 }')"
    if [ "${OUTPUT}" == "200" ]; then
      echo -e "\e[0;32m strapi is ready to serve \e[0m"
      local STRAPI_READY
      STRAPI_READY='yes'
      break
    else  
      sleep 10
    fi
  done
  if [[ "${STRAPI_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of strapi \e[0m"
    exit 1
  fi
}

complete_installation() {
  echo -e "\e[0;32m The script is finished \e[0m"
  echo -e "\e[0;32m Now you can go to the Strapi web interface at http://${IP_ARR[0]}:1337/ and follow a few configuration steps \e[0m"
}

main() {
install_strapi
check_strapi
complete_installation
}

main
