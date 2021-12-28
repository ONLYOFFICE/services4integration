# Stand for testing the connector to Liferay

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/liferay/install.sh -st liferay_tag -cu connector_url
```

Where:
 - `liferay_tag` - liferay version. The available versions of Liferay can be viewed [here](https://hub.docker.com/r/liferay/portal/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-liferay/releases)

For example:
```
/app/liferay/install.sh -st 7.4.0-ga1 -cu https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v2.0.0/onlyoffice.integration.web-2.0.0-CE7.4GA1.jar
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Liferay web interface at: `http://IP-SERVER/` and check the connector operation.
