docs_ready_check() {
  echo -e "\e[0;32m Waiting for the launch of DocumentServer... \e[0m"
  local DS_READY
  for i in {1..30}; do
    echo "Getting the DocumentServer status: ${i}"
    OUTPUT="$(curl -f -s ${DS_ADDRESS})"
    if [ "${OUTPUT}" == "true" ]; then
      echo -e "\e[0;32m DocumentServer is ready \e[0m"
      DS_READY='yes'
      break
    else
      sleep 10
    fi
  done
  if [[ "${DS_READY}" != 'yes' ]]; then
    err "\e[0;31m Something goes wrong documentserver does not started, check logs with command --> docker logs -f onlyoffice-document-server \e[0m"
    exit 1
  fi
}
