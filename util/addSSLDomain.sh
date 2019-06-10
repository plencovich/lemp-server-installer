#!/bin/bash
clear
read -p "Ingrese el nombre de usuario:, (ej. dplenco):" USER;
read -p "Ingrese el host del dominio:, (ej. google.com):" DOMAIN;

touch $DOMAIN.conf

echo "server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name $DOMAIN www.$DOMAIN;

    if (\$http_host = $DOMAIN) {
        return 301 https://www.\$host\$request_uri;
    }

    root /home/$USER/public_html;
    index index.php index.html index.htm;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    include /etc/nginx/config/ssl/ssl.conf;
    include /etc/nginx/config/ssl/resolver.conf;
    include /etc/nginx/config/snippets/common.conf;
    include /etc/nginx/config/snippets/xss.conf;
    #include /etc/nginx/config/snippets/pagespeed.conf;

    access_log off;
    error_log /home/$USER/logs/error.log warn;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.2-fpm-$USER.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include /etc/nginx/config/php/fastcgi_params;
    }

    location ~ \.php$ {
        return 404;
    }

    location = /webmail {
        return 301 https://webmail.\$host;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;

    return 301 https://\$host\$request_uri;
}
" >> $DOMAIN.conf

rm -f /etc/nginx/sites/$DOMAIN.conf
mv $DOMAIN.conf /etc/nginx/sites/

systemctl restart php7.2-fpm
systemctl restart nginx
echo
echo "El dominio $DOMAIN ha sido activado con SSL."
echo
