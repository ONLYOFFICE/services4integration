# Stand for test integrations EduSoho + Docs

## How it work:

First of all, you need to change the value in the field `<ext_ip>` in the nginx configuration file that name `edusoho.conf`

After that you can build your own Docker container image, do it with command:

```
docker build -t onlyoffice/edusoho:latest .
```

After the image is built, run it with the command:

```
docker run -i -t -d -p 80:80 onlyoffice/edusoho:latest
```

Wait couple of minutes that container is gonna be ready. After that y can get access to EduSoho on your instance external ip.
