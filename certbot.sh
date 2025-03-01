#!/bin/bash
path=$(pwd)
tput setaf 3 bold ;read -p "enter init to create first time certs
         update to update the expired certs (init/update)" entry
         tput sgr0
         sudo mkdir -p $path/letsencrypt/letsencrypt-site
         cd letsencrypt
         touch docker-compose.yml nginx.conf index.html
tput setaf 3 smso ;   echo "enter the server name that you want certs to generate"
tput sgr0
read server
 echo "server {
    listen 80;
    listen [::]:80;
    server_name $server;

    location ~ /.well-known/acme-challenge {
        allow all;
        root /usr/share/nginx/html;
    }

    root /usr/share/nginx/html;
    index index.html;
}
" > nginx.conf
echo "<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Let's Encrypt First Time Cert Issue Site</title>
</head>
<body>
    <h1>Oh, hai there!</h1>
    <p>
        This is the temporary site that will only be used for the very first time SSL certificates are issued by Let's Encrypt's
        certbot.
    </p>
</body>
</html>
" > index.html
sudo mv index.html letsencrypt-site/.
echo "version: '3.1'

services:
  letsencrypt-nginx-container:
    container_name: 'letsencrypt-nginx-container'
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./letsencrypt-site:/usr/share/nginx/html
    networks:
      - docker-network
networks:
  docker-network:
    driver: bridge

" > docker-compose.yml
sudo docker-compose up -d


tput setaf 7 smso ;read -p "Do you want to add an extra email for notification (yes/no)? \
(Already added: raviteja.panugundla@gmail.com): " yn
if [ "$yn" = "yes" ]; then
  read -p "Enter the email(s) you want to add (separate multiple emails with comma ','): " entry
  emails="--email raviteja.panugundla@gmail.com,$entry"
else
  emails="--email raviteja.panugundla@gmail.com"
fi
sudo docker run -it --rm \
  -v $path/certbot/etc/letsencrypt:/etc/letsencrypt \
  -v $path/certbot/var/lib/letsencrypt:/var/lib/letsencrypt \
  -v $path/letsencrypt/letsencrypt-site:/data/letsencrypt \
  -v "$path/certbot/var/log/letsencrypt:/var/log/letsencrypt" \
  certbot/certbot \
  certonly --webroot \
  $emails --agree-tos --no-eff-email \
  --webroot-path=/data/letsencrypt \
  -d $server
sudo docker-compose down
echo "
        certs generated :)
     "
tput setaf 3 bold ;echo "example paths to store the certs"
ls -d -- "$PWD"/*/*
echo "enter the folder to store the certs without '/' at end"
read nginxpath
certificatepath="$path/certbot/etc/letsencrypt/live/$server"
tput setaf 5 smso ;echo "enter the folder you want to store the certs "
sudo cat $certificatepath/fullchain.pem > $nginxpath/$server.crt
sudo cat $certificatepath/privkey.pem > $nginxpath/$server.key
