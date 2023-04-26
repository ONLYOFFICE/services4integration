# Stand for testing Discourse

Pass the following `cloud-init` directives to the instance with `user data`:

```bash
#cloud-config
runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/discourse/install.sh -st discourse_tag -bn plugin_branch <-je jwt_enabled | -js jwt_secret>
```

Where:

- `discourse_tag` - Discourse version. The available versions of Discourse can be viewed [here](https://hub.docker.com/r/bitnami/discourse)
- `plugin_branch` - [ONLYOFFICE/onlyoffice-discourse](https://github.com/ONLYOFFICE/onlyoffice-discourse) repository branch (master by default)
- `jwt_enabled` - jwt is enabled by default. if you need to disable it - pass this parameter with a value of false
- `jwt_secret` - the default value is mysecret. if you need to change the secret - pass this parameter with the value of the secret

For example:

```bash
/app/discourse/install.sh
/app/discourse/install.sh -st 3.0.1 -bn develop -js newsecret
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:

```bash
The script is finished
```

Then you can go to the SuiteCRM web interface at: `http://IP-SERVER/` and check the connector operation.
Default login credentials:

- Login: `user`
- Password: `bitnami123`
