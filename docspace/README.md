# Stand for testing DocSpace pure installation

Pass the following `cloud-init` directives to the instance with `user data`:
```
#cloud-config

runcmd:
 - git clone --depth=1 https://github.com/ONLYOFFICE/services4integration.git /app
 - /bin/bash /app/docspace/install.sh 
```

Where:
 - `gitbranch` - Branch of the DocSpace repo from which the scripts will be taken (default value develop).
 - `docker` - Docker installation (true|false). If you select false, the package supply will be installed.
 - `docker_username` - Dockerhub username.
 - `docker_password` - Dockerhub password.
 - `docker_status` - DocSpace status. As an example - 4testing.
 - `docker_tag` - DocSpace version. The available versions of DocSpace can be viewed [here](https://hub.docker.com/repository/docker/onlyoffice/4testing-docspace-proxy/tags).
 - `docker_external_port` - External DocSpace port (default value 80).
 - `docker_documentserver_image` - Document server image name. Format - orgs/repo:tag.
 - `mysql_database` - Mysql database name.
 - `mysql_user` - Mysql database user.
 - `mysql_password` - Mysql database password.
 - `mysql_root_password` - Mysql root password.
 - `mysql_host` - Mysql server host.

For example:
```
Docker supply: /app/docspace/install.sh -gb gitbranch -d true -un docker_username -p docker_password -s docker_status -tag docker_tag -ep docker_external_port -di docker_documentserver_image 
Package supply: /app/docspace/install.sh -gb gitbranch -d false -mysqld mysql_database -mysqlu mysql_user -mysqlp mysql_password -mysqlrp mysql_root_password -mysqlh mysql_host
```

After that, you can connect via SSH to the VM and check the progress of the script using the following command:
```
sudo tail -f /var/log/cloud-init-output.log
```

If successful, the following line will appear:
``` 
The script is finished
```
Then you can go to the DocSpace web interface at: `http://IP-SERVER/` and test funcionality.
