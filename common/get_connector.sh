##############################################################
# Get a connector
# Globals:
#   CONNECTOR_NAME
#   CONNECTOR_URL
#   BRANCH
#   CONNECTOR_REPO
# Arguments:
#   None
# Outputs:
#   Write the status of receiving the connector to stdout
# Returns:
#   0 if thing was received, non-zero on error
##############################################################
get_connector() {
  echo -e "\e[0;32m The connector will now be downloaded to the host \e[0m"
  rm -rf /connectors
  mkdir /connectors
  if [[ -n ${BRANCH} ]]; then
    git clone --branch=${BRANCH} ${CONNECTOR_REPO} /connectors/onlyoffice
  elif [[ -n ${CONNECTOR_URL} ]]; then
    CONNECTOR_NAME=${CONNECTOR_URL##*/}
    wget -O /connectors/${CONNECTOR_NAME} ${CONNECTOR_URL}
    if [ ! -f "/connectors/${CONNECTOR_NAME}" ]; then
        echo -e "\e[0;31m The connector under test was not added to the /connectors directory \e[0m"
        exit 1
    fi
    CONNECTOR_SIZE="$(du /connectors/${CONNECTOR_NAME} | awk '{print $1}')"
    echo "${CONNECTOR_SIZE}"
    if [[ "${CONNECTOR_SIZE}" == '0' ]]; then
        echo -e "\e[0;31m The size of the connector is 0, check that the connector is loaded correctly \e[0m"
        exit 1
    fi
    if [[ ${CONNECTOR_URL##*.} == "zip" ]]; then
      apt install unzip -y
      unzip /connectors/${CONNECTOR_NAME} -d /connectors    
    elif [[ ${CONNECTOR_URL##*.} == "gz" ]]; then
      tar -C /connectors -xvf /connectors/${CONNECTOR_NAME}
    fi
    mv $(ls -d /connectors/*/) /connectors/onlyoffice
  fi
}
