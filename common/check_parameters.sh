###############################################################################################
# Check the passed parameters and their values and assign the received values to variables
# Arguments:
#   Application version, path to the connector under test
# Outputs:
#   If there are no parameters, writes a message to stdout
###############################################################################################
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
    -je | --jwt_enabled )
      if [ "$2" != "" ]; then
        JWT_ENABLED=$2
        shift
      fi
    ;;

    -js | --jwt_secret )
      if [ "$2" != "" ]; then
        JWT_SECRET=$2
        shift
      fi
    ;;
    -dn | --domain_name )
      if [ "$2" != "" ]; then
        DOMAIN_NAME=$2
        shift
      fi
    ;;
    -dt | --docs_tag )
      if [ "$2" != "" ]; then
        DS_TAG=$2
        shift
      fi
    ;;
    -b | --branch )
      if [ "$2" != "" ]; then
        BRANCH=$2
        shift
      fi
    ;;
esac
  shift
done
