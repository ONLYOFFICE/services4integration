# Stand for testing the connector to Redmine

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/redmine/install.sh -st redmine_tag -cu connector_url
```

Where:
 - `redmine_tag` - redmine version. The available versions of Redmine can be viewed [here](https://hub.docker.com/_/redmine?tab=tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-redmine/releases)

For example:
```
/app/redmine/install.sh -st 4.2 -cu https://github.com/ONLYOFFICE/onlyoffice-redmine/releases/download/v1.1.0/onlyoffice-redmine.zip
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Redmine web interface at: `http://IP-SERVER:3000/` and check the connector operation. 
```
log: Admin 
pass: admin
jwt: mysecret
```
