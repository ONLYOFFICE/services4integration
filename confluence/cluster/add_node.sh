#!/usr/bin/env bash
#
# Add a second Confluence node to the cluster

CONFLUENCE_NODES=(cluster-confluence-node-2 cluster-confluence-node-1)
SERVICE_TAG="$(docker ps | grep -i ${CONFLUENCE_NODES[1]} | awk '{print$2}' | sed 's/[^:]*://')"
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}
source /app/common/error.sh

###############################################################################
# Add a second Confluence node to the cluster using docker-compose scaling
# Globals:
#   SERVICE_TAG
#   IP_PROXY
# Arguments:
#   None
# Returns:
#   0, if the scaling was successful, non-zero on error
###############################################################################
add_second_node() {
  export SERVICE_TAG="${SERVICE_TAG}"
  export IP_PROXY="${IP_PROXY}"
  cd /app/confluence/cluster/
  envsubst < docker-compose.yml | docker-compose -f - up -d --scale confluence-node=2 --no-recreate
}

###############################################################################
# Check the launch and status of the second node of the Confluence cluster
# Globals:
#   CONFLUENCE_NODES
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
###############################################################################
check_cluster_readiness() {
  echo -e "\e[0;32m Wait until the Confluence cluster nodes are ready \e[0m"
  sleep 5
  IP_NODE_2="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONFLUENCE_NODES[0]})"
  echo "${IP_NODE_2}"
  for ((i=1 ; i <= 100 ; i++)); do
    echo "Waiting for ${CONFLUENCE_NODES[0]} to be ready: ${i}"
    CODE="$(curl -m 3 -s -o /dev/null -w '%{http_code}' ${IP_NODE_2}:8090/status)"
    if [[ "${CODE}" != '200' ]]; then
      sleep 5
    else
      echo -e "\e[0;32m Confluence Node ${CONFLUENCE_NODES[0]} works \e[0m"
      local NODE_READY
      NODE_READY='yes'
      break
    fi
  done
  if [[ "${NODE_READY}" != 'yes' ]]; then
    err "\e[0;31m I didn't wait for the launch of ${CONFLUENCE_NODES[0]}. Check the container logs using the command: sudo docker logs -f ${CONFLUENCE_NODES} \e[0m"
    exit 1
  fi
}

complete_cluster_construction() {
  echo -e "\e[0;32m Cluster nodes have been added and are ready to work. In the General Configuration > Clustering, you can check their status \e[0m"
}

main() {
add_second_node
check_cluster_readiness
complete_cluster_construction
}

main
