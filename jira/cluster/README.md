# Stand for testing the connector to Jira cluster

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/jira/cluster/install.sh -st jira_tag -cu connector_url <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `jira_tag` - Jira version. The available versions of Jira can be viewed [here](https://hub.docker.com/r/atlassian/jira-software/tags?page=1&ordering=last_updated)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-jira/releases)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/jira/cluster/install.sh -st 8.20.0 -cu https://github.com/ONLYOFFICE/onlyoffice-jira/releases/download/v1.0.1/onlyoffice-jira-app-1.0.1.jar
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```

After that you need to go to the Jira web interface at `http://IP-SERVER/` and follow a few configuration steps. Read more about it [here](https://confluence.atlassian.com/adminjiraserver/running-the-setup-wizard-938846872.html#Runningthesetupwizard-manual) (Note. You need to select the Production and testing setup. Connection to the Postgresql database is already configured).

After completing all the "setup wizard" steps, go to the menu: `System - Clustering` and make sure that there is a green dot next to the line `jira_node_1`.

Next, add the second node "Jira" to the cluster. To do this, run the following command on the VM:
```
sudo /app/jira/cluster/add_node.sh
```

After these steps, you can proceed to checking the operation of the connector.
