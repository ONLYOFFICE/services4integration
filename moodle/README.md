# Stand for testing the connector to Moodle

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - bash /app/moodle/install.sh -dn domain_name -st moodle_tag -cu connector_url -du docspace_connector_url <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `domain_name` - Domain name. must be specified if you need an https connection. If not specified - only http connection will be available
 - `moodle_tag` - moodle version. The available versions of moodle can be viewed [here](https://hub.docker.com/r/bitnami/moodle/tags)
 - `connector_url` - The address at which the connector for documentserver under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-moodle/releases)
 - `docspace_connector_url`  - The address at which the connector for docspace under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-moodle/releases)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
bash /app/moodle/install.sh -st latest -cu https://github.com/ONLYOFFICE/moodle-mod_onlyofficeeditor/archive/refs/tags/v3.0.0.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the moodle web interface at: `http://IP-SERVER/` and check the connector operation.
``` 
log: user
jwt: mysecret
```
