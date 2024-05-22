# Stand for testing the connector to Plone

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - bash /app/plone/install.sh -dn domain_name st plone_tag <-cu connector_url | -b branch_name>  <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `domain_name` - Domain name. must be specified if you need an https connection. If not specified - only http connection will be available
 - `plone_tag` - plone version. The available versions of plone can be viewed [here](https://hub.docker.com/_/plone?tab=tags)
 - `branch_name` - branch name in the connector github repository
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-plone/releases)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/plone/install.sh -st latest -cu https://github.com/ONLYOFFICE/onlyoffice-plone/archive/refs/tags/v2.1.0.tar.gz
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
``` 
log: admin
pass: admin
jwt: mysecret
```
