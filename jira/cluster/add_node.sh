#!/usr/bin/env bash
#
# Add a second Jira node to the cluster

JIRA_NODES=(cluster-jira-node-2 cluster-jira-node-1)
SERVICE_TAG="$(docker ps | grep -i ${JIRA_NODES[1]} | awk '{print$2}' | sed 's/[^:]*://')"
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}
source /app/common/error.sh

#########################################################################
# Add a second Jira node to the cluster using docker-compose scaling
# Globals:
#   SERVICE_TAG
#   IP_PROXY
#   JIRA_NODE_ID
# Arguments:
#   None
# Returns:
#   0, if the scaling was successful, non-zero on error
#########################################################################
add_second_node() {
  export SERVICE_TAG="${SERVICE_TAG}"
  export IP_PROXY="${IP_PROXY}"
  export JIRA_NODE_ID=jira_node_2
  cd /app/jira/cluster/
  envsubst < docker-compose.yml | docker-compose -f - up -d --scale jira-node=2 --no-recreate
}

#########################################################################
# Check the launch and status of the second node of the Jira cluster
# Globals:
#   JIRA_NODES
# Arguments:
#   None
# Outputs:
#   Writes a startup message to stdout
# Returns:
#   0, if the start is successful, non-zero on error
#########################################################################
check_cluster_readiness() {
  echo -e "\e[0;32m Wait until the Jira cluster nodes are ready \e[0m"
  for node in "${JIRA_NODES[@]}"; do
    for ((i=1 ; i <= 100 ; i++)); do
      echo "Waiting for ${node} to be ready: ${i}"
      docker logs ${node} | grep -w "Warmed cache(s)"
      if [[ "$?" -ne 0 ]]; then
        sleep 5
      else
        echo -e "\e[0;32m Node ${node} is ready \e[0m"
        if [[ "${node}" == "${JIRA_NODES[0]}" ]]; then
          docker restart "${JIRA_NODES[1]}"
        fi
        local NODE_READY
        NODE_READY='yes'
        break
      fi
    done
    if [[ "${NODE_READY}" != 'yes' ]]; then
      err "\e[0;31m I didn't wait for the launch of ${node}. Check the container logs using the command: sudo docker logs -f ${node} \e[0m"
      exit 1
    fi
  done
}

complete_cluster_construction() {
  echo -e "\e[0;32m Cluster nodes have been added and are ready to work. In the System - Clustering menu, you can check their status \e[0m"
}

main() {
add_second_node
check_cluster_readiness
complete_cluster_construction
}

main
