# Stand for testing the connector to Nexcloud

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /bin/bash /app/nextcloud/install.sh -dn domain_name -st nextcloud_tag -cu connector_url <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `domain_name` - Domain name. must be specified if you need an https connection. If not specified - only http connection will be available
 - `nextcloud_tag` - Nextcloud version. The available versions of Nextcloud can be viewed [here](https://hub.docker.com/_/nextcloud?tab=tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/nextcloud/install.sh -dn example.domain.com -st 22.0 -cu https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v7.5.4/onlyoffice.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Nextcloud web interface at: `http(s)://IP-SERVER/` and check the connector operation.
```
log: admin
jwt: mysecret
```
