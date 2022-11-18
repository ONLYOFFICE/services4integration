#!/usr/bin/env bash 
  
CFG_FILE=./nextcloud/config/config.php
EXTERNAL_IP="$(wget -q -O - ifconfig.me/ip)"

function setup_trust_domain() {

  sed -i "s!%external_ip%!${EXTERNAL_IP}!" .env
  echo "DONE: External domain is setup"

}

function setup_logs_permission () {
  chmod 777 ./logs/*
}

function run_nextcloud () {
  
  docker compose up -d
  echo "First run, please wait that config will be created"

  while [ ! -f "${CFG_FILE}" ]; do
          sleep 5
  done

  echo "DONE: Config file is create, wait for full config"

  while ! cat ${CFG_FILE} | grep instanceid; do
          sleep 5
  done

  while ! cat ${CFG_FILE} | grep ${EXTERNAL_IP}; do
    	  sleep 5
  done

  echo "DONE: CFG is complitely make, enable debug mod"
  sed -i '$i"log_type" => "file",\n"logfile" => "/var/log/nextcloud.log",\n"loglevel" => "0",' ${CFG_FILE}
  echo "DONE: DUBUG mod is enabled, loglevel => 0 now logs avaliavable in ./logs/nextcloud<instance_port>.log"

  docker compose restart

}

main () {
   setup_trust_domain
   setup_logs_permission
   run_nextcloud
}

main
