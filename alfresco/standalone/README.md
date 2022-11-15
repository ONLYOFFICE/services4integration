# Stand for testing the connector to Alfresco

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/alfresco/standalone/install.sh -ct content_repo_tag -st share_tag -cu content_repo_url -su share_url <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `content_repo_tag` - alfresco content-repository-community version. The available versions can be viewed [here](https://hub.docker.com/r/alfresco/alfresco-content-repository-community/tags)
 - `share_tag` - alfresco share version. The available versions can be viewed [here](https://hub.docker.com/r/alfresco/alfresco-share/tags)
 - `content_repo_url` and `share_url` - The addresses at which the connectors under test is available. The available versions of the connectors can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

*Note: If you do not assign `content_repo_tag` and `share_tag` parameters, the latest versions of images will be installed.*

For example:
```
/app/alfresco/standalone/install.sh -ct 7.2.1 -st 7.2.1 -cu https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/6.0.0/onlyoffice-integration-repo.jar -su https://github.com/ONLYOFFICE/onlyoffice-alfresco/releases/download/6.0.0/onlyoffice-integration-share.jar -js newsecret
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
```
log: Admin
pass: admin
jwt: mysecret
```

To configure the onlyoffice plugin follow the link: `http://IP-SERVER:8080/alfresco/s/onlyoffice/onlyoffice-config`
