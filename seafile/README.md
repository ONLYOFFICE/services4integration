# Stand for testing the connector to Seafile

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/seafile/install.sh -dn domain_name -st seafile_tag <-je jwt_enabled | -js jwt_secret>
```

Where:
 - `seafile_tag` - Seafile version. The available versions of Seafile can be viewed [here](https://hub.docker.com/r/seafileltd/seafile-mc/tags)
 - `domain_name` - Domain name. must be specified if you need an https connection. If not specified - only http connection will be available
 - `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of `false`
 - `jwt_secret` - the default value is `mysecret`. if you need to change the secret - pass this parameter with the value of the secret

For example:
```
/app/seafile/install.sh -st latest
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Seafile web interface at: `http://IP-SERVER/` and check the connector operation. 
```
login: me@example.com
pass: secret
jwt: mysecret
```

