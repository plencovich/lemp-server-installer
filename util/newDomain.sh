#!/bin/bash
clear
read -p "Ingrese el nombre de usuario:, (ej. dplenco):" USER;
read -p "Ingrese el host del dominio:, (ej. google.com):" DOMAIN;

groupadd $USER
useradd -g $USER -G nginx -m -k /root/skel_folder/ -s /bin/bash $USER

touch $USER.conf

echo "[$USER]
user = $USER
group = nginx
listen = /run/php/php7.2-fpm-$USER.sock
listen.owner = nginx
listen.group = nginx
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 40
pm.start_servers = 15
pm.min_spare_servers = 15
pm.max_spare_servers = 25
pm.process_idle_timeout = 10s
chdir = /" >> $USER.conf

mv $USER.conf /etc/php/7.2/fpm/pool.d/

touch $DOMAIN.conf

echo "server {
    listen 80;
    #listen 443 ssl http2;
    #listen [::]:443 ssl http2;

    server_name $DOMAIN www.$DOMAIN;

    if (\$http_host = $DOMAIN) {
        return 301 http://www.\$host\$request_uri;
    }

    root /home/$USER/public_html;
    index index.php index.html index.htm;

    #ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    #ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    #include /etc/nginx/config/ssl/ssl.conf;
    #include /etc/nginx/config/ssl/resolver.conf;
    include /etc/nginx/config/snippets/common.conf;
    include /etc/nginx/config/snippets/xss.conf;
    #include /etc/nginx/config/snippets/pagespeed.conf;

    access_log off;
    error_log /home/$USER/logs/error.log warn;

    location ~ \.php$ {
        try_files \$uri \$uri/ /index.php?;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.2-fpm-$USER.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include /etc/nginx/config/php/fastcgi_params;
    }

    location = /webmail {
        return 301 https://webmail.$DOMAIN;
    }
}
#
#server {
#    listen 80;
#    listen [::]:80;
#    server_name $DOMAIN www.$DOMAIN;
#
#    return 301 https://\$host\$request_uri;
#}
" >> $DOMAIN.conf

mv $DOMAIN.conf /etc/nginx/sites/

systemctl restart php7.2-fpm
systemctl restart nginx
echo
echo "El dominio $DOMAIN ha sido creado ok."
echo
