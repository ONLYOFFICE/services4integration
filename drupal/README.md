# Stand for testing the connector to Drupal

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/drupal/install.sh -st drupal_tag <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `drupal_tag` - Drupal version. The available versions of Drupal can be viewed [here](https://hub.docker.com/r/bitnami/drupal/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-drupal/releases/)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/drupal/install.sh -st 8 -cu https://github.com/ONLYOFFICE/onlyoffice-drupal/releases/download/v1.0.5/onlyoffice-drupal-1.0.5.zip
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Drupal web interface at: `http://IP-SERVER/` and check the connector operation. 
```
log: user
pass: bitnami
jwt: mysecret
```
