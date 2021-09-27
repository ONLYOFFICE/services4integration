# Stand for testing the connector to Liferay

Before creating a VM in oVirt, upload the tested connector to a resource available via the Internet.

After loading the connector, create a VM in oVirt, at the same time, in the `Initial Run` tab, in the `Custom Script` field, enter the following commands:
```
runcmd:
 - wget -O /connectors/liferay/onlyoffice-integration-web-liferay.jar https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v2.0.0/onlyoffice.integration.web-2.0.0-CE7.4GA1.jar
 - git clone https://username:password@github.com/ONLYOFFICE/services4integration.git /app
 - /app/liferay/install_liferay.sh <liferay_tag> 
```

Where:
 - `https://github.com/ONLYOFFICE/onlyoffice-liferay/releases/download/v2.0.0/onlyoffice.integration.web-2.0.0-CE7.4GA1.jar` - The address at which the connector under test is available
 - `liferay_tag` - liferay version 

If you do not specify the tag, version `7.4.0-ga1` will be installed by default.

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the Liferay web interface at: `http://IP-SERVER/` and check the connector operation.
