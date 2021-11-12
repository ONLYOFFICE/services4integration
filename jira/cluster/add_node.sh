#!/usr/bin/env bash
JIRA_NODES=(cluster-jira-node-2 cluster-jira-node-1)
SERVICE_TAG=$(docker ps | grep -i ${JIRA_NODES[1]} | awk '{print$2}' | sed 's/[^:]*://')
ALLIPADDR="$(hostname -I)"
declare -a IPADDR=($ALLIPADDR)
IP_PROXY=${IPADDR[0]}

add_second_node() {
  export SERVICE_TAG="${SERVICE_TAG}"
  export IP_PROXY="${IP_PROXY}"
  export JIRA_NODE_ID=jira_node_2
  cd /app/jira/cluster/
  envsubst < docker-compose.yml | docker-compose -f - up -d --scale jira-node=2 --no-recreate
}

check_cluster_readiness() {
  echo -e "\e[0;32m Wait until the Jira cluster nodes are ready \e[0m"
  for name in "${JIRA_NODES[@]}"; do
    for ((i=1 ; i <= 100 ; i++)); do
      echo "Waiting for $name to be ready: $i"
      docker logs ${name} | grep -w "Warmed cache(s)"
      if [ $? -ne 0 ]; then
        sleep 5
      else
        echo -e "\e[0;32m Node $name is ready \e[0m"
        if [[ "$name" == "${JIRA_NODES[0]}" ]]; then
          docker restart ${JIRA_NODES[1]}
        fi
        NODE_READY="yes"
        break
      fi
    done
    if [[ "$NODE_READY" != "yes" ]]; then
      echo -e "\e[0;31m I didn't wait for the launch of $name. Check the container logs using the command: sudo docker logs -f $name \e[0m"
      exit 1
    fi
  done
}

complete_cluster_construction() {
  echo -e "\e[0;32m Cluster nodes have been added and are ready to work. In the System - Clustering menu, you can check their status \e[0m"
}

add_second_node
check_cluster_readiness
complete_cluster_construction
