#!/usr/bin/env bash

default_url=$1
cu=$2
connector_path=$3
st=$4
Connector=$5

function create_vm() {
  if [[ ${cu} == "from_pipeline" ]]; then
    connector_url=${default_url}
  else
    connector_url=${cu}
  fi
    
  date=$(date '+%Y%m%d%H%M');

  sed -i "s,%connector_url%,${connector_url},g" .jenkins/user-data.yml
  sed -i "s,%path%,${connector_path},g" .jenkins/user-data.yml
  sed -i "s,%tag%,${st},g" .jenkins/user-data.yml

  curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DO_TOKEN}" \
  -d '{
    "name":"'${Connector}-${date}'",
    "region":"nyc3",
    "size":"s-2vcpu-4gb",
    "image":"ubuntu-20-04-x64",
    "ssh_keys":[30223004,29633232,29102049,28963692,30876815,35168967],
    "backups":false,
    "ipv6":false,
    "user_data":"'" $(cat .jenkins/user-data.yml) "'",
    "private_networking":null,
    "volumes": null,
    "tags":["connectors"]}' \
  "https://api.digitalocean.com/v2/droplets" 

  echo "Connector ${Connector} was created."
}

function check_vm_condition() {
  echo "vm was run."
}

function main() {

  create_vm
  # check_vm_condition
}

main
