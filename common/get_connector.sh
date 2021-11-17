##############################################################
# Get a connector
# Globals:
#   CONNECTOR_NAME
#   CONNECTOR_URL
# Arguments:
#   None
# Outputs:
#   Write the status of receiving the connector to stdout
# Returns:
#   0 if thing was received, non-zero on error
##############################################################
get_connector() {
  echo -e "\e[0;32m The connector will now be downloaded to the host \e[0m"
  mkdir /connectors
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
}
