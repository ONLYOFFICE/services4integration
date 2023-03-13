# Stand for testing SuiteCRM

Pass the following `cloud-init` directives to the instance with `user data`:

```bash
#cloud-config
runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /app/suitecrm/install.sh -st suitecrm_tag
```

Where:

- `suitecrm_tag` - SuiteCRM version tag

For example:

```bash
/app/suitecrm/install.sh
/app/suitecrm/install.sh -st 8.2.4
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:

```bash
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:

```bash
The script is finished
```

Then you can go to the SuiteCRM web interface at: `https://vm-address` and check the installation operation.
Default login credentials:

- Login: `user`
- Password: `bitnami`

For more information, visit [Bitnami SuiteCRM](https://hub.docker.com/r/bitnami/suitecrm)
