# Discourse installation, method 1

## Run install.sh

## Required parameters

- Hostname (Domain name): e.g. discourse.onlyoffice.com
- Email address (for admin): e.g. admin@onlyoffice.com
- SMTP server address: e.g. smtp.onlyoffice.com
- SMTP username: e.g. smtp-admin
- SMTP server port: e.g. 25
- SMTP password: e.g. smtp-strong-password

```bash
./install.sh -h {hostname} -e {email} -s {smtp server} -u {smtp username} -p {smtp password} -t {smtp port}
```

## Visit the hostname in browser

## Click the "Register" button to register Admin account

## Provide Email address you used in installation

# Discourse installation, method 2

## Run install-d.sh

## No parameters required

```bash
./install-d.sh
```

## For more information, visit [Bitnami Discourse](https://hub.docker.com/r/bitnami/discourse)