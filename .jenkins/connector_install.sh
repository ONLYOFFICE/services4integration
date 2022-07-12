#!/usr/bin/env bash

default_url=$1
cu=$2
connector_path=$3
st=$4
Connector=$5
port=$6
OUTPUT=".jenkins/output.json"
ip_address=""
droplet_name=""

function droplet_status() {
  for ((i=0; i<=15 ; i++))
  do
    status=$(curl -X GET -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${DO_TOKEN}" \
      "https://api.digitalocean.com/v2/droplets/$1/actions" | jq .actions[].status | cut -f 2 -d'"') 

    echo "$i attempt has status ${status}."
    if [[ ${status} == "completed" ]]; then
      return
    else
      sleep 20
      continue
    fi
  done
  
  echo "Error! Droplet was not created during 5 minuts."
  exit 1 
}

function create_vm() {
  if [[ ${cu} == "from_pipeline" ]]; then
    connector_url=${default_url}
  else
    connector_url=${cu}
  fi

  if [ -f "$OUTPUT" ]; then
	  touch $OUTPUT;
  fi

  date=$(date '+%Y%m%d%H%M');

  # prepare user_data
  cp .jenkins/user-data.yml .jenkins/user-data.yml.tmp
  tmp_path=".jenkins/user-data.yml.tmp"

  sed -i "s,%connector_url%,${connector_url},g" ${tmp_path}
  sed -i "s,%path%,${connector_path},g" ${tmp_path}
  sed -i "s,%tag%,${st},g" ${tmp_path}
  sed -i "s,%space%, ,g" ${tmp_path}

  echo "# ${vm_size} #"
  exit 0
  
  # create droplet
  (curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DO_TOKEN}" \
  -d '{
    "name":"'${Connector}-${date}'",
    "region":"nyc3",
    "size":"'${vm_size}'",
    "image":"ubuntu-20-04-x64",
    "ssh_keys":[30223004,29633232,29102049,28963692,30876815,35168967,30296916],
    "backups":false,
    "ipv6":false,
    "user_data":"'" $(cat .jenkins/user-data.yml.tmp) "'",
    "private_networking":null,
    "volumes": null,
    "tags":["connectors"]}' \
  "https://api.digitalocean.com/v2/droplets" ) > ${OUTPUT}

  # wait for os to start
  droplet_name=$(jq ".droplet.name" $OUTPUT | cut -f 2 -d'"')
  droplet_id=$(jq ".droplet.id" $OUTPUT | cut -f 2 -d'"')
  droplet_status ${droplet_id}

  echo "Droplet was created."
}

function check_vm_condition() {
  # get droplets list with tag_name=connectors
  (curl -X GET -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DO_TOKEN}" \
  "https://api.digitalocean.com/v2/droplets?tag_name=connectors") > $OUTPUT

  # search droplet`s ip
  for ((i=0; i<=30 ; i++))
  do
    NAME=$(jq ".droplets[$i].name" $OUTPUT | cut -f 2 -d'"')
    IP=$(jq ".droplets[$i].networks.v4[0].ip_address" $OUTPUT | cut -f 2 -d'"')
    TYPE=$(jq ".droplets[$i].networks.v4[0].type" $OUTPUT | cut -f 2 -d'"')

    # get public ip address
    if [[ ${TYPE} == "private" ]]; then
      IP=$(jq ".droplets[$i].networks.v4[1].ip_address" $OUTPUT | cut -f 2 -d'"')
    fi

    if [[ ${NAME} == ${droplet_name} ]]; then
      break
    fi
	done

  ip_address=${IP}
}

function check_web_status() {
  for ((i=0; i<=60 ; i++))
  do
    web_status=$(curl -s -o /dev/null -L -w ''%{http_code}'' ${1})

    if [[ ${web_status} = 200 ]]; then
      return
    else
      echo "$i attempt. web site ${1} has status ${web_status}."
      sleep 20
      continue
    fi
  done 
  
  echo "Error! Droplet was not created during 20 minuts."
  exit 1
}

function main() {
  create_vm
  check_vm_condition
  check_web_status "http://${ip_address}:${port}"
}

main
