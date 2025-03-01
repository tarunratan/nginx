#!/bin/bash

#taking all the various inputs needed for the nginx conf file
echo "enter number of nginx conf files to generate"
read count
for ((i = 0; i< count ; i++)); do
tput setaf 2 smso ; echo "enter upstream-name"
tput sgr0
read upstream
tput setaf 2 bold ;echo "enter server-ip and port application is running"
tput sgr0
read ip
tput setaf 3 smso ;echo "enter sub-domain-name"
tput sgr0
read subdomain
tput sgr0
tput setaf 5 smso ;echo "enter cert name stored in ssl folder
{ensure certname and keyname is same except the .externsion} "
tput sgr0
read cert
path=$(pwd)

#condition check to add the ui comming soon page in the below code

tput bold;  echo "Do you want to add the error page block for maintenance mode [y for UI]? (y/n)"
tput sgr0
  read add_error_page

  if [ "$add_error_page" == "y" ]; then
    error_page_block="error_page 404 500 502 503 504 @maintenance;
  }
    location @maintenance
    {
    root /var/www/html/comingsoon;
    try_files \$uri /coming-soon.html =503;
    "
  else
    error_page_block=""
  fi
cat <<- END_OF_TEXT > $path/proxy/conf.d/$upstream.conf
upstream $upstream {
    server $ip ;
}
server {
  listen        80;
  listen        443 ssl;
  server_name   $subdomain;
    add_header Strict-Transport-Security    "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options              SAMEORIGIN;
    add_header X-Content-Type-Options       nosniff;
    add_header X-XSS-Protection             "1; mode=block";

    ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;
    ssl_ecdh_curve              secp384r1;
    ssl_ciphers                 "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers   on;
    #ssl_dhparam                 /etc/nginx/cert/dhparams.pem;
    ssl_certificate             /etc/ssl/certs/$cert.crt;
    ssl_certificate_key         /etc/ssl/certs/$cert.key;
    ssl_session_timeout         10m;
    ssl_session_cache           shared:SSL:10m;
    ssl_session_tickets         off;
    ssl_stapling                on;
    ssl_stapling_verify         on;

  client_max_body_size 4G;
  location / {
    proxy_pass  http://$upstream;
    proxy_set_header    X-Real-IP           \$remote_addr;
    proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-Proto   \$scheme;
    proxy_set_header    Host                \$host;
    proxy_set_header    X-Forwarded-Host    \$host;
    proxy_set_header    X-Forwarded-Port    \$server_port;
    proxy_set_header    Upgrade             \$http_upgrade;
    proxy_set_header    Connection          "Upgrade";
    proxy_http_version  1.1;
    proxy_connect_timeout       605;
    proxy_send_timeout          605;
    proxy_read_timeout          605;
    send_timeout                605;
    keepalive_timeout           605;
    $error_page_block
  }
 }
END_OF_TEXT
tput setaf 7 smso ; echo "Configuration file saved @ $path/proxy/conf.d/$upstream.conf path"
done
tput setaf 6 bold ;echo "Great You did it :) Total $count nginx conf files stored "
