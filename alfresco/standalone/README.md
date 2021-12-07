# Stand for testing the connector to Alfresco

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/alfresco/standalone/install.sh -ct content_repo_tag -st share_tag -cu content_repo_url -su share_url
```

Where:
 - `content_repo_tag` - alfresco content-repository-community version. The available versions can be viewed [here](https://hub.docker.com/r/alfresco/alfresco-content-repository-community/tags)
 - `content_repo_tag` - alfresco share version. The available versions can be viewed [here](https://hub.docker.com/r/alfresco/alfresco-share/tags)
 If you do not assign these parameters, the latest versions of images will be installed.
 - `content_repo_url` and `share_url` - The addresses at which the connectors under test is available. The available versions of the connectors can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases)

For example:
```
/app/alfresco/standalone/install.sh -ct 7.0.0 -st 7.0.0 -cu https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/v5.0.1/onlyoffice-integration-repo.jar -su https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/v5.0.1/onlyoffice-integration-share.jar
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Alfresco web interface at: `http://IP-SERVER:8080/alfresco` and check the connector operation.
