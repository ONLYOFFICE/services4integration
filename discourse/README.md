# Stand for testing Discourse

Pass the following `cloud-init` directives to the instance with `user data`:

```bash
#cloud-config
runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/discourse/install.sh -st discourse_tag -b plugin_branch
```

Where:

- `discourse_tag` - Discourse version tag
- `plugin_branch` - ONLYOFFICE/onlyoffice-discourse repository branch

For example:

```bash
/app/discourse/install.sh
/app/discourse/install.sh -st 3.0.1 -b develop
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:

```bash
The script is finished
```

Then you can go to the SuiteCRM web interface at: `http://vm-address` and check the installation operation.
Default login credentials:

- Login: `user`
- Password: `bitnami123`

## For more information, visit [Bitnami Discourse](https://hub.docker.com/r/bitnami/discourse)
