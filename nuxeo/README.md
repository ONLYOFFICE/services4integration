# Stand for testing the connector to Nuxeo

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/nuxeo/install.sh -st nuxeo_tag -cu connector_url <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `nuxeo_tag` - Nuxeo version. The available versions of Nuxeo can be viewed [here](https://hub.docker.com/_/nuxeo/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-nuxeo/releases)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/wordpress/install.sh -st latest -cu https://github.com/ONLYOFFICE/onlyoffice-nuxeo/releases/download/v2.0.0/onlyoffice-nuxeo-package-2.0.0.zip
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
```
The script is finished
```
Then you can go to the Nuxeo web interface at: `http://IP-SERVER:8080/` and check the connector operation.
```
login: Administrator
password: Administrator
JWT: mysecret
```

