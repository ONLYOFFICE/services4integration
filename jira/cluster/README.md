# Stand for testing the connector to Jira cluster

Pass the following `cloud-init` directives to the instance with `user data`:
```
runcmd:
 - git clone --depth=1 https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/jira/cluster/install.sh -st jira_tag -cu connector_url
```

Where:
 - `jira_tag` - Jira version. The available versions of Jira can be viewed [here](https://hub.docker.com/r/atlassian/jira-software/tags?page=1&ordering=last_updated)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-jira/releases)

For example:
```
/app/jira/cluster/install.sh -st 8.19.0 -cu https://github.com/ONLYOFFICE/onlyoffice-jira/releases/download/v1.0.0/onlyoffice-jira-app-1.0.0.jar
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```

After that you need to go to the Jira web interface at `http://IP-SERVER/` and follow a few configuration steps. Read more about it [here](https://confluence.atlassian.com/adminjiraserver/running-the-setup-wizard-938846872.html#Runningthesetupwizard-manual) (Note. You need to select the Production and testing setup).

DB connection parameters:
 - 'Database Type: PostgreSQL'
 - 'Hostname: postgresql'
 - 'Port: 5432'
 - 'Database: postgres'
 - 'Username: postgres'
 - 'Password: my-secret'
 - 'Schema: public'

After completing all the "setup wizard" steps, go to the menu: `System - Clustering` and make sure that there is a green dot next to the line `jira-node-1`.

Next, add the second node "Jira" to the cluster. To do this, run the following command on the VM:
```
sudo /app/jira/cluster/add_node.sh
```
After executing the script in the Jira web interface, a line with `jira-node-2` should be added to the `System - Clustering` menu. In this case, the green dot should remain on the line with `jira-node-1`.

After these steps, you can proceed to checking the operation of the connector.

To check the connector operation on the second node of the Jira cluster, run the following commands:
```
sudo sed -i 's/[^.]*server s1/#   server s1/g;s/[^.]*server s2/   server s2/g' /jira/haproxy/haproxy.cfg
sudo docker restart haproxy
```
After that, in the `System - Clustering` menu, the green dot should be next to the line `jira-node-2`.

Next, you can check the operation of the connector.
