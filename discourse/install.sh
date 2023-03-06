#!/bin/bash

HOSTNAME=""
EMAIL=""
SMTP_HOST=""
SMTP_USER=""
SMTP_PASSWORD=""
SMTP_PORT="25"

while getopts "h:e:s:u:p:t:" opt; do
   case $opt in
      h) HOSTNAME=${OPTARG};;
      e) EMAIL=${OPTARG};;
      s) SMTP_HOST=${OPTARG};;
      u) SMTP_USER=${OPTARG};;
      p) SMTP_PASSWORD=${OPTARG};;
      t) SMTP_PORT=${OPTARG};;
      \?) echo "Invalid option -$OPTARG" >&2;;
   esac
done

source /app/common/install_dependencies.sh
install_dependencies

# Install discourse
mkdir /var/discourse
git clone https://github.com/discourse/discourse_docker.git /var/discourse
cd /var/discourse
./discourse-setup <<< "${HOSTNAME}
   ${EMAIL}
   ${SMTP_HOST}
   ${SMTP_USER}
   ${SMTP_PASSWORD}
   ${SMTP_PORT}
   "