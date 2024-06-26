# Stand for testing the connector to Odoo

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/odoo/install.sh -dn domain_name -st odoo_tag -dt documentserver_tag <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `domain_name` - Domain name. must be specified if you need an https connection. If not specified - only http connection will be available
 - `odoo_tag` - Odoo version. The available versions of odoo can be viewed [here](https://hub.docker.com/_/odoo/tags)
 - `documentserver_tag` - Documentserver version. The available versions of Documentserver can be viewed [here](https://hub.docker.com/r/onlyoffice/documentserver/tags)
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/odoo/install.sh -st latest
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
```
The script is finished
```
Then you can go to the Odoo web interface at: `http://IP-SERVER/` and check the connector operation.

