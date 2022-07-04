# Stand for testing the connector to Moodle

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - bash /app/moodle/install.sh -st moodle_tag -cu connector_url
```

Where:
 - `moodle_tag` - moodle version. The available versions of moodle can be viewed [here](https://hub.docker.com/r/bitnami/moodle/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-moodle/releases)

For example:
```
bash /app/moodle/install.sh -st latest -cu https://github.com/ONLYOFFICE/moodle-mod_onlyofficeeditor/archive/refs/tags/v2.1.0.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the moodle web interface at: `http://IP-SERVER/` and check the connector operation.
``` 
log: user
pass: bitnami
```
