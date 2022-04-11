# Stand for testing the connector to Wordpress

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/wordpress/install.sh -st wordpress_tag
```

Where:
 - `wordpress_tag` - Wordpress version. The available versions of Wordpress can be viewed [here](https://hub.docker.com/_/wordpress?tab=tags)

For example:
```
/app/wordpress/install.sh -st latest
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Wordpress web interface at: `http://IP-SERVER/wp-admin/` and check the connector operation. Default login:adm password:Z65uGXkr
