# Stand for testing the connector to HumHub

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - bash /app/humhub/install.sh -st humhub_tag -cu connector_url <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `humhub_tag` - humhub version. The available versions of humhub can be viewed [here](https://hub.docker.com/r/mriedmann/humhub/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-humhub/releases)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/humhub/install.sh -st stable -cu https://github.com/ONLYOFFICE/onlyoffice-humhub/releases/download/v2.4.0/onlyoffice.zip
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the humhub web interface at: `http://IP-SERVER/` and check the connector operation.
```
log: admin
pass: test
jwt: mysecret
```