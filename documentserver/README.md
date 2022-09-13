# Stand for testing DocumentServer pure installation

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /bin/bash /app/documentserver/install.sh -st ds_docker_tag
```

Where:
 - `ds_docker_tag` - DocumentServer version. The available versions of DocumentServer can be viewed [here](https://hub.docker.com/r/onlyoffice/documentserver/tags)

For example:
```
/app/documentserver/install.sh -st 7.1.1
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the DocumentServer web interface at: `http://IP-SERVER/` and test funcionality.
