# Stand for testing the connector to Nexcloud

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://USERNAME:ACCESSKEY@github.com/ONLYOFFICE/services4integration.git /app
 - /bin/bash /app/nextcloud/install.sh -st nextcloud_tag -cu connector_url
```

Where:
 - `nextcloud_tag` - Nextcloud version. The available versions of Nextcloud can be viewed [here](https://hub.docker.com/_/nextcloud?tab=tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/)

For example:
```
/app/nextcloud/install.sh -st 22.0 -cu https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v7.1.2/onlyoffice.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Nextcloud web interface at: `http://IP-SERVER:8080/` and check the connector operation.
```
log: admin
pass: admin
```
