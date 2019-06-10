#!/bin/bash
sudo du -shc --exclude={/home/ubuntu,/home/nginx} /home/* > ~/listado-usuarios.txt
perl -pi -e "s[/home/][-> ]g" ~/listado-usuarios.txt

HOSTNAME=`hostname`
HOSTIP=`hostname -I | sed -r 's/(\S+) (\S+)/\1, \2/g'`
USERLIST=`cat ~/listado-usuarios.txt`

echo "SERVER:"
echo ${HOSTNAME} "-" ${HOSTIP}
echo ""
echo "Listado de Usuarios:"
echo "${USERLIST}"
rm -f ~/listado-usuarios.txt
