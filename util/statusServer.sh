#!/bin/bash
HOSTNAME=`hostname`
HOSTIP=`hostname -I | sed -r 's/(\S+) (\S+)/\1, \2/g'`
UPTIME=`uptime`
DISK=`df -hT /`
MEMORY=`free -h`
QTYCONNECTIONS=`netstat -nt | grep :80 | wc -l`
QTYESTABLISHED=`netstat -ant | grep ESTABLISHED | grep :80 | wc -l`

echo "SERVER:"
echo ${HOSTNAME} "-"  ${HOSTIP}
echo ""
echo "${UPTIME}"
echo ""
echo "${DISK}"
echo ""
echo "${MEMORY}"
echo ""
echo "TotalConexiones" ${QTYCONNECTIONS}
echo ""
echo "TotalConexionesEstablecidas" ${QTYCONNECTIONS}
echo ""
