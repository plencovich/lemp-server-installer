#!/bin/bash
clear
read -p "Ingrese el host del dominio:, (ej. google.com):" DOMAIN;

touch $DOMAIN.conf

echo "server {
    listen 80;

    server_name $DOMAIN;

    root /home/cloud/public_html;
    index index.php index.html index.htm;

    access_log off;
    error_log off;
}
" >> $DOMAIN.conf

mv $DOMAIN.conf /etc/nginx/sites/

systemctl restart php7.2-fpm
systemctl restart nginx
echo
echo "El dominio $DOMAIN ha sido creado ok."
echo
certbot certonly --webroot --agree-tos --no-eff-email --email user@gmail.com -w /home/cloud/public_html -d $DOMAIN
