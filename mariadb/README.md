![Plen.co](https://plen.co/assets/images/logo.png)

## Instalación Server Linux LEMP

### Instalación de Base de Datos - MariaDB

Realizar los siguientes pasos:

`apt install mariadb-server`

`mysql -u root`

Escribir las siguientes query, reemplace `user_new` por su nombre de usuario y `password` por su contraseña:

```
SELECT user,host,authentication_string,plugin FROM mysql.user;
CREATE USER 'user_new'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'user_new'@'localhost' WITH GRANT OPTION;
quit
```

`mysql_secure_installation`

>Enter current password for root (enter for none): <-- presione enter

>Set root password? [Y/n] <-- y

>New password: <-- Escriba el nuevo passowrd

>Re-enter new password: <-- Repita el password ingresado

>Remove anonymous users? [Y/n] <-- y

>Disallow root login remotely? [Y/n] <-- y

>Reload privilege tables now? [Y/n] <-- y

Luego compiar el archivo [my.cnf](config/my.cnf) a la carpeta `/etc/mysql/conf.d/`


### Instalación de phpMyAdmin - opcional

`apt-get install phpmyadmin`

>Web server to configure automatically: <-- Dejar en blanco

>Configure database for phpmyadmin with dbconfig-common? <-- Yes

>MySQL application password for phpmyadmin: <-- Ingrese una contraseña o presione enter para crear una random

Cambiar url default por una personalizada:

`ln -s /usr/share/phpmyadmin /home/nginx/htdocs/public/{nombre_link}`

### Agregar seguridad al acceder via web:

`phpenmod mcrypt`

`systemctl restart php7.2-fpm`

Generar una contaseña `openssl passwd`

Editar `nano /etc/nginx/pma_pass` y guardar el usuario y contraseña generado anteriormente, con el formato `user:password`

Editar la configuración del dominio por `default` o bien realizarlo sobre el dominio sobre el cual quiere acceder a `phpMyAdmin`

`nano /etc/nginx/sites-available/default`

Y pegar el siguiente código dentro del bloque `server { .... }`

```
location /{nombre_link} {
	auth_basic "Acceso DB Login";
	auth_basic_user_file /etc/nginx/pma_pass;
}
```

### Si encontró un problema o desea realizar una sugerencia

- LEMP Server Installer [Issues](https://github.com/plencovich/lemp-server-installer/issues)
