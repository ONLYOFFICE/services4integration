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
