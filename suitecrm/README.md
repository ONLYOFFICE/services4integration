# Stand for testing SuiteCRM

Pass the following `cloud-init` directives to the instance with `user data`:

```bash
#cloud-config
runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/suitecrm/install.sh -st suitecrm_tag <-je jwt_enabled | -js jwt_secret>
```

Where:

- `suitecrm_tag` - SuiteCRM version. The available versions of SuiteCRM can be viewed [here](https://hub.docker.com/r/bitnami/suitecrm)
- `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of false
- `jwt_secret` - the default value is mysecret. if you need to change the secret - pass this parameter with the value of the secret

For example:

```bash
/app/suitecrm/install.sh
/app/suitecrm/install.sh -st 8.2.4 -js newsecret
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:

```bash
The script is finished
```

Then you can go to the SuiteCRM web interface at: `https://IP-SERVER/` and check the installation operation.
Default login credentials:

- Login: `user`
- Password: `bitnami`

After these steps, you need to add the plugin via the web interface and check the operation of the connector.
