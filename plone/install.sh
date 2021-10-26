#!/usr/bin/env bash

install_plone(){
  source /app/common/install_dependencies.sh
  install_dependencies
}

complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}

install_plone
complete_installation
