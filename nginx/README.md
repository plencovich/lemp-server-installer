![Plen.co](https://plen.co/assets/images/logo.png)

## Instalación Server Linux LEMP

### Instalar NGINX - Opción A:

`apt install nginx`

### Instalar NGINX - Opción B:

Se puede utilizar el siguiente script para compilar Nginx [installer.sh](installer.sh)

`chmod +x installer.sh && ./installer.sh`

### Modificar limites

Estos limites son los utilizados según la configuración utilizada en este repositorio. Cada uno debe evalular de acuerdo a la memoria y cpu que tiene en el servidor.

Modificar `nano /etc/security/limits.conf` y agregar al final

```
*   soft    nproc   260000
*   hard    nproc   260000
*   soft    nofile  260000
*   hard    nofile  260000
```

### Si encontró un problema o desea realizar una sugerencia

- LEMP Server Installer [Issues](https://github.com/plencovich/lemp-server-installer/issues)
