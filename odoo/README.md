# Stand for testing the connector to Odoo

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/odoo/install.sh -st odoo_tag
```

Where:
 - `odoo_tag` - Odoo version. The available versions of odoo can be viewed [here](https://hub.docker.com/_/odoo/tags)

For example:
```
/app/odoo/install.sh -st latest
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
```
The script is finished
```
Then you can go to the Odoo web interface at: `http://IP-SERVER:8069/` and check the connector operation.
```

