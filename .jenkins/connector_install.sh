#!/usr/bin/env bash

SSH_KEY="/root/.ssh/ connector_install.pem"
Connector=$1
connector_url=$2


function create_vm() {
  date=$(date '+%Y%m%d%H%M');

  curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DO_TOKEN}" \
  -d '{"name":"'${Connector}-${date}'","region":"fra1","size":"s-2vcpu-4gb","image":"ubuntu-20-04-x64","ssh_keys":[30223004,29633232,29102049,28963692,30876815,35168967],"backups":false,"ipv6":false,"user_data":null,"private_networking":null,"volumes": null,"tags":["connectors"]}' \
  "https://api.digitalocean.com/v2/droplets"
}

function check_vm_condition() {

}

function main() {
  create_vm
  check_vm_condition
  install_connector
  check_connector
}
# main

create_vm
