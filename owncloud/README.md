# Stand for testing the connector to owncloud

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - bash /app/owncloud/install.sh -st owncloud_tag -cu connector_url
```

Where:
 - `owncloud_tag` - owncloud version. The available versions of owncloud can be viewed [here](https://hub.docker.com/r/owncloud/server/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-owncloud/releases)

For example:
```
/app/owncloud/install.sh -st latest -cu https://github.com/ONLYOFFICE/onlyoffice-owncloud/releases/download/v7.1.1/onlyoffice.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the owncloud web interface at: `http://IP-SERVER/` and check the connector operation.
```
log: owncloud
pass: owncloud
```
