# Stand for testing the connector to Nexcloud

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://USERNAME:ACCESSKEY@github.com/ONLYOFFICE/services4integration.git /app
 - /bin/bash /app/nextcloud/install.sh
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Nextcloud web interface at: `http://IP-SERVER:8080/` and check the connector operation.
