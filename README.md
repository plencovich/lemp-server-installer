![Plen.co](https://plen.co/assets/images/logo.png)

## Instalación Server Linux LEMP

Es una guia instructiva que sirve de ayuda memoria para el paso a paso de la instalación de LEMP (Linux Nginx MariaDB PHP7) sobre Ubuntu 18.04

### Configurar Hostname

`hostnamectl set-hostname hostname.domain.tld`

### Actualizar Linux

`apt update && apt upgrade`

### Instalar NGINX

Para la instalación automática y personalizada de Nginx, ver en [NGINX Información](nginx/README.md)

### Instalar MariaDB / MySQL

Para la instalación del servidor de base de datos [MariaDB Información](mariadb/README.md)

### Instalación de PHP

`apt install php-cli php-dev php-fpm php-bcmath php-bz2 php-common php-curl php-gd php-gmp php-imap php-intl php-json php-mbstring php-mysql php-readline php-recode php-soap php-sqlite3 php-xml php-xmlrpc php-zip php-opcache php-xsl`

`sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.2/fpm/php.ini`

Editar configuración PHP FPM

`nano /etc/php/7.2/fpm/php-fpm.conf`

y agregar los siguientes valores:

```
emergency_restart_threshold 10
emergency_restart_interval 1m
process_control_timeout 10s
```

### Instalar Let's Encrypt

Para la instalación de un certificado SSL de Let's Encrypt, ejecutar:

`certbot certonly --rsa-key-size 4096 --webroot --agree-tos --no-eff-email --email tu-email@gmail.com -w /home/dominio/public_html -d dominio.com.ar -d www.dominio.com.ar`

### Cambiar puerto SSH

Cambiar puerto SSH default 22 por custom ej: `3344`, editar `nano /etc/ssh/sshd_config`

### Configurar UFW Firewall

Si utiliza UFW deberá crear las reglas para que funcione

Habilitar puertos para NGINX 80 y 443 `sudo ufw allow 'Nginx Full'`

Habilitar puerto para ssh custom `ufw allow 3344`

Activar firewall `ufw enable`

Más info de configuración [UFW](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)

### Script Util

Una serie de scripts para la administración de dominios y servidor [Util Información](util/README.md)

### Información Adicional

- Este repositorio es parte de un fork de [Serveradminsh Installers](https://github.com/serveradminsh/installers)

- Crear dominios en NGINX desde la consola [add_vhost.sh](https://gist.github.com/plencovich/155f01e22bcd5844149a6818080f83ae)

- Listar dominios y espacio que ocupan sus archivos [list_domain.sh](https://gist.github.com/plencovich/2882f9deb352ce5a19bae477308206d7)

- How to Fix NGINX error “Failed to read PID from file" [fix read PID NGINX](https://gist.github.com/plencovich/e38e7a3d2ff977089fc4e06be1e738ed)

- Guia de instalación LEMP en Digital Ocean [LEMP Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-ubuntu-18-04)

- Guia de instalación LEMP en Linode [LEMP Ubuntu 18.04](https://www.linode.com/docs/web-servers/lemp/how-to-install-a-lemp-server-on-ubuntu-18-04/)

- Guia de instalación LEMP en TecMint [LEMP Ubuntu 18.04](https://www.tecmint.com/install-nginx-mariadb-php-in-ubuntu-18-04/)

### Si encontró un problema o desea realizar una sugerencia

- LEMP Server Installer [Issues](https://github.com/plencovich/lemp-server-installer/issues)
