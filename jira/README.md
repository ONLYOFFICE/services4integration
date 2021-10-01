# Stand for testing the connector to Jira

Pass the following `cloud-init` directives to the instance with `user data`:
```
runcmd:
 - git clone --depth=1 https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/jira/install.sh -st jira_tag -cu connector_url
```

Where:
 - `jira_tag` - Jira version. The available versions of Jira can be viewed [here](https://hub.docker.com/r/atlassian/jira-software/tags?page=1&ordering=last_updated)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-jira)

For example:
```
/app/jira/install.sh -st 8.18.0 -cu https://github.com/ONLYOFFICE/onlyoffice-jira
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```

After that, go to the Jira web interface at `http://IP-SERVER:8080/` and follow a few configuration steps. Read more about it [here](https://confluence.atlassian.com/adminjiraserver/running-the-setup-wizard-938846872.html#Runningthesetupwizard-express) (Note. You need to select the Evaluation and demonstration setup).
After these steps, you can proceed to checking the operation of the connector.