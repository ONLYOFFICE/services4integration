# Stand for testing the connector to Confluence cluster

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/confluence/cluster/install.sh -st confluence_tag <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `confluence_tag` - Confluence version. The available versions of Confluence can be viewed [here](https://hub.docker.com/r/atlassian/confluence/tags)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/confluence/cluster/install.sh -st 7.13
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```

After that you need to go to the Confluence web interface at `http://IP-SERVER/` and follow a few steps of Confluence Setup Wizard.

*Note: Connection to the Postgresql database is already configured. There is no need to change anything at the `Choose your deployment type` step, just click `Create cluster`.*

After completing all the "setup wizard" steps, go to the menu: `General Configuration > Clustering` and make sure that the first node of the cluster has been successfully added.

Next, add the second node "Confluence" to the cluster. To do this, run the following command on the VM:
```
sudo /app/confluence/cluster/add_node.sh
```

After these steps, you need to add the connector via the web interface and check the operation of the connector.
