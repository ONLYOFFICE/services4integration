# Stand for testing the connector to Drupal

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/drupal/install.sh -st drupal_tag
```

Where:
 - `drupal_tag` - Drupal version. The available versions of Drupal can be viewed [here](https://hub.docker.com/r/bitnami/drupal/tags)

For example:
```
/app/drupal/install.sh -st 8
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Drupal web interface at: `http://IP-SERVER/` and check the connector operation. Default login: user password: bitnami
