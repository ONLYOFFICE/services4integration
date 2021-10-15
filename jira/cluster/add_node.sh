#!/usr/bin/env bash
JIRA_NODES=(jira-node-2 jira-node-1)
add_second_node(){
  docker cp jira-node-1:/var/atlassian/application-data/jira/dbconfig.xml /tmp/ 
  docker cp jira-node-1:/opt/atlassian/jira/conf/server.xml /tmp/
  chown -R 2001:2001 /tmp/dbconfig.xml
  chown -R 2001:2001 /tmp/server.xml
  docker cp /tmp/dbconfig.xml jira-node-2:/var/atlassian/application-data/jira/dbconfig.xml
  docker cp /tmp/server.xml jira-node-2:/opt/atlassian/jira/conf/server.xml
  docker restart jira-node-2
}
check_cluster_readiness(){
  echo -e "\e[0;32m Wait until the Jira cluster nodes are ready \e[0m"
  for name in "${JIRA_NODES[@]}"; do
    for i in {1..50}; do
      echo "Waiting for $name to be ready: $i"
      docker logs ${name} | grep -w "Plugins upgrades completed successfully"
      if [ $? -ne 0 ]; then
        if [[ "$i" == '49' ]]; then
          echo -e "\e[0;31m I didn't wait for the launch of $name. Check the container logs using the command: sudo docker logs -f $name \e[0m"
          exit 1
        else
          sleep 5
        fi
      else
        echo -e "\e[0;32m Node $name is ready \e[0m"
        if [[ "$name" == "jira-node-2" ]]; then
          docker restart jira-node-1
        fi
        break
      fi
    done
  done
}
complete_cluster_construction(){
  echo -e "\e[0;32m Cluster nodes have been added and are ready to work. In the System - Clustering menu, you can check their status \e[0m"
}
add_second_node
check_cluster_readiness
complete_cluster_construction
