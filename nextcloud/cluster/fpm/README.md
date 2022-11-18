# Nextcloud multiple-instance docker compose stand: 

Values in `.env` fille that you can castomize before deploy:

- **NEXTCLOUD_ADMIN_USER**:  The variable allows you to set the name of admin user for access to nextcloud admin account. By default: `admin` 
- **NEXTCLOUD_ADMIN_PASSWORD**: The variable allows you to set the password for admin user for access to nextcloud admin account. By defaullt: `admin`
- **POSTGRES_PASSWORD**: The variable allows you to set the password for postgresql database. By default: `nextcloud`

⚠ Before deploy is recommended to change the values of the variables `NEXTCLOUD_ADMIN_USER` and `NEXTCLOUD_ADMIN_PASSWORD` ⚠ 

## How to deploy

The first initialization must be run through the run script `run.sh`. This script will be run two nextcloud instances. Also this scriptwill reconfigure the container logs so that they are written to separate files. 

```bash
bash run.sh
```
### Store logs

First nextcloud instance work on `8081` port and write logs in `logs/nextcloud8081.log`

Second nextcloud instance work on `8082` port and write logs in `logs/nextcloud8082.log`

Also you can erase all logs with the simple erase logs srcipt.

```bash
bash erase-logs.sh
```

### Recreate all new installation

With srtipt `recreate.sh` you can make all new compose deploy

```bash
bash recreate.sh
```
