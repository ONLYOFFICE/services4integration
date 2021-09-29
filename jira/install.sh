#!/usr/bin/env bash
SERVICE_TAG="latest"
if [ "$1" == "" ]; then
  echo -e "\e[0;33m Warning: Basic parameters are missing. The default values will be used \e[0m"
fi
while [ "$1" != "" ]; do
  case $1 in
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
install_jira(){
  source /app/common/install_dependencies.sh
  install_dependencies
  docker run -i -t -d --restart=always --name jira -p 8080:8080 atlassian/jira-software:${SERVICE_TAG}
  echo OK > /opt/run
  echo -e "\e[0;32m Installation is complete \e[0m"
}
complete_installation(){
  echo -e "\e[0;32m The script is finished \e[0m"
}
install_jira
complete_installation
