# Stand for testing the connector to Chamilo

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/chamilo/install.sh -st chamilo_tag -cu connector_url
```

Where:
 - `chamilo_tag` - Chamilo version. The available versions of Chamilo can be viewed [here](https://github.com/chamilo/chamilo-lms/releases)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-chamilo/releases)

For example:
```
/app/chamilo/install.sh -st 1.11.16 -cu https://github.com/ONLYOFFICE/onlyoffice-chamilo/releases/download/v1.1.2/onlyoffice.zip
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Chamilo web interface at: `http://IP-SERVER/` and check the connector operation. Access to the database: login:chamilouser  password:jx7bqzRo
