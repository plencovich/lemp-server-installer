![Plen.co](https://plen.co/assets/images/logo.png)

## Instalación Server Linux LEMP

### Instalación de Base de Datos - MariaDB

Realizar los siguientes pasos:

Actualizar lista de repositorio para versión 10.3.x

1. `apt-get install software-properties-common`

2. `apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8`

3. `add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.ufscar.br/mariadb/repo/10.3/ubuntu bionic main'`

`apt install mariadb-server`

`mysql -u root`

Escribir las siguientes query, reemplace `user_new` por su nombre de usuario y `password` por su contraseña:

```
SELECT user,host,authentication_string,plugin FROM mysql.user;
CREATE USER 'user_new'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'user_new'@'localhost' WITH GRANT OPTION;
quit
```

### Borrar historial de MySQL Consola - opcional

Ejecutar:
- `rm $HOME/.mysql_history`
- `ln -s /dev/null $HOME/.mysql_history`

### MySQL Seguro

`mysql_secure_installation`

>Enter current password for root (enter for none): <-- presione enter

>Set root password? [Y/n] <-- y

>New password: <-- Escriba el nuevo passowrd

>Re-enter new password: <-- Repita el password ingresado

>Remove anonymous users? [Y/n] <-- y

>Disallow root login remotely? [Y/n] <-- y

>Reload privilege tables now? [Y/n] <-- y

Luego copiar el archivo [my.cnf](config/my.cnf) a la carpeta `/etc/mysql/conf.d/`


### Instalación de phpMyAdmin - opcional

`apt --no-install-recommends install phpmyadmin`

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

### Upgrade to MariaDB 10.3.x

Backup de todas las bases de datos: `mysqldump -u {user} -p --all-databases > backup_database.sql`

Parar el servicio: `systemctl stop mysql.service`

Desinstalar la versión instalada: `apt remove mariadb-server`

Actualizar lista de repositorio:

1. `apt-get install software-properties-common`

2. `apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8`

3. `add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.ufscar.br/mariadb/repo/10.3/ubuntu bionic main'`

Actualizar e instalar la nueva versión: `apt-get update && apt-get install mariadb-server`

Upgrade de MySQL: `mysql_upgrade -u {user} -p`

### Si encontró un problema o desea realizar una sugerencia

- LEMP Server Installer [Issues](https://github.com/plencovich/lemp-server-installer/issues)
