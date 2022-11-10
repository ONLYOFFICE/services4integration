# Stand for testing the connector to Seafile

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/seafile/install.sh -st seafile_tag
```

Where:
 - `seafile_tag` - Seafile version. The available versions of Seafile can be viewed [here](https://hub.docker.com/r/seafileltd/seafile-mc/tags)

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

