# Stand for testing the connector to Tuleap

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/tuleap/install.sh -dn domain_name -st tuleap_tag <-js jwt_secret>
```

Where:
 - `domain_name` - domain name of your server. This is a required parameter.
 - `tuleap_tag` - Tuleap version. The available versions of Tuleap can be viewed [here](https://hub.docker.com/r/tuleap/tuleap-community-edition/tags)
 - `jwt_secret` - the default value is `MfqqGX16TiFHsKfJwOjdRx6DSL49gbAY`. if you need to change the secret - pass this parameter with the value of the secret. Note: secret must be at least 32 characters long.
 
For example:
```
/app/tuleap/install.sh -dn example.com -st latest
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Tuleap web interface at: `https://domain_name` and check the connector operation. 
```
login and password will be sent to the installation log, they can also be viewed in the file /var/lib/connector_pwd
Document server URL: https://<domain_name>/ds-vpath/
```
