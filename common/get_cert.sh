#########################################
# Getting a certificate from letsencrypt
# Globals:
#   FQDN
#########################################
get_cert() {
  docker run --rm --name certbot -p 80:80 -v "/etc/letsencrypt:/etc/letsencrypt" -v "/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot certonly --standalone -n -m example@gmail.com -d "${FQDN}" --agree-tos
  mkdir /etc/nginx/ssl/
  cp /etc/letsencrypt/live/${FQDN}/fullchain.pem /etc/nginx/ssl/
  cp /etc/letsencrypt/live/${FQDN}/privkey.pem /etc/nginx/ssl/
  if [ ! -f "/etc/nginx/ssl/fullchain.pem" ]; then
    echo -e "\e[0;31m Certificate was not received \e[0m"
    exit 1
  fi
}
