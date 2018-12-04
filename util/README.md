![Plen.co](https://plen.co/assets/images/logo.png)

## Instalación Server Linux LEMP

### Configuración de un nuevo dominio

Realizar los siguientes pasos:

Se debe utilizar el archivo `./newDomain.sh` que previamente debe ser configurado como ejecutable con `chmod +x newDOmain.sh`

Este script se utiliza para crear el archivo `dominio.com.ar.conf` en `/etc/nginx/sites`, crea también la usuario con su carpeta `public_html` copiando la estructura que esta en [skel_folder](skel_folder) con una página de bievenida; también configura el socket de php-fpm en `/etc/php/7.2/fpm/pool.d/`

Archivo .conf para NGINX
(las lineas comentadas son para luego de activar el ssl)


```
server {
    listen 80;
    #listen 443 ssl http2;
    #listen [::]:443 ssl http2;

    server_name dominio.com.ar www.dominio.com.ar;

    if (\$http_host = dominio.com.ar) {
        return 301 http://www.\$host\$request_uri;
    }

    root /home/dominio/public_html;
    index index.php index.html index.htm;

    #ssl_certificate /etc/letsencrypt/live/dominio.com.ar/fullchain.pem;
    #ssl_certificate_key /etc/letsencrypt/live/dominio.com.ar/privkey.pem;

    #include /etc/nginx/config/ssl/ssl.conf;
    #include /etc/nginx/config/ssl/resolver.conf;
    include /etc/nginx/config/snippets/common.conf;
    include /etc/nginx/config/snippets/xss.conf;
    #include /etc/nginx/config/snippets/pagespeed.conf;

    access_log off;
    error_log /home/dominio/logs/error.log warn;

    location ~ \.php$ {
        try_files \$uri \$uri/ /index.php?;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.2-fpm-dominio.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include /etc/nginx/config/php/fastcgi_params;
    }

    location = /webmail {
        return 301 https://webmail.dominio.com.ar;
    }
}
#
#server {
#    listen 80;
#    listen [::]:80;
#    server_name dominio.com.ar www.dominio.com.ar;
#
#    return 301 https://\$host\$request_uri;
#}
```

Archivo .conf para PHP-FPM

```
[dominio]
user = dominio
group = nginx
listen = /run/php/php7.2-fpm-dominio.sock
listen.owner = nginx
listen.group = nginx
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 80
pm.start_servers = 8
pm.min_spare_servers = 4
pm.max_spare_servers = 8
pm.process_idle_timeout = 10s
chdir = /
```

### Listar Usuarios

Para listar todos los usuarios con el tamaño que ocupa cada carpeta, puede ejecutar: `./listUsers.sh`

### Estado del Servidor

Para conocer el estado del servidor: `./statusServer.sh`

## Si encontró un problema o desea realizar una sugerencia

- LEMP Server Installer [Issues](https://github.com/plencovich/lemp-server-installer/issues)
