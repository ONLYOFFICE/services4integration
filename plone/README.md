# Stand for testing the connector to Plone

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - bash /app/plone/install.sh -st plone_tag -cu connector_url
```

Where:
 - `plone_tag` - plone version. The available versions of plone can be viewed [here](https://hub.docker.com/_/plone?tab=tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-plone/releases)

For example:
```
/app/plone/install.sh -st latest -cu https://github.com/ONLYOFFICE/onlyoffice-plone/archive/refs/tags/v1.0.0.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the plone web interface at: `http://IP-SERVER/` and check the connector operation.
