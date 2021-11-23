# Stand for testing the connector to Mattermost

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/mattermost/install.sh -dn domain_name -st mattermost_tag -cu connector_url
```

Where:
 - `domain_name` - domain name of your server. This is a required parameter.
 - `lmattermost_tag` - mattermost version. The available versions of mattermost can be viewed [here](https://hub.docker.com/r/mattermost/mattermost-enterprise-edition/tags)
 - `connector_url` - The address at which the connector under test is available. The available versions of the connector can be viewed [here](https://github.com/ONLYOFFICE/onlyoffice-mattermost/releases)

For example:
```
/app/mattermost/install.sh -dn example.domain.com -st 6.1 -cu https://github.com/ONLYOFFICE/onlyoffice-mattermost/releases/download/v1.0.0/com.onlyoffice.mattermost-1.0.0.tar.gz
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Mattermost web interface at: `https://domain_name/` and check the connector operation. Stand also has a documenserver. To use it, specify in the plugin settings `https://<domain_name>/ds`
