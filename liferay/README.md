# Stand for testing the connector to Liferay

When creating a VM in oVirt, in the `Initial Run` contribution, enter the following commands in the `Custom Script` field:
```
runcmd:
 - git clone https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/liferay/install_liferay.sh -lt liferay_tag -cu connector_url
```

Where:
 - `liferay_tag` - liferay version
 - `connector_url` - The address at which the connector under test is available

For example:
```
/app/liferay/install_liferay.sh -lt 7.4.0-ga1 -cu https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v2.0.0/onlyoffice.integration.web-2.0.0-CE7.4GA1.jar
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
