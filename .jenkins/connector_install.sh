#!/usr/bin/env bash

SSH_KEY="/home/jenkins/connector_install_prv.ppk"

function create_vm() {
  Connector=${1}
  connector_url=${2}
  date=$(date '+%Y%m%d%H%M');

  curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DO_TOKEN}" \
  -d '{"name":"'${Connector}-${date}'","region":"nyc3","size":"s-2vcpu-4gb","image":"ubuntu-20-04-x64","ssh_keys":[30223004,29633232,29102049,28963692,30876815,35168967],"backups":false,"ipv6":false,"user_data":null,"private_networking":null,"volumes": null,"tags":["connectors"]}' \
  "https://api.digitalocean.com/v2/droplets"
}

function main() {
  create_vm
  check_vm_condition
  install_connector
  check_connector
}
# main

create_vm
