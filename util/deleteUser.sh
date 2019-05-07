#!/usr/bin/env bash
clear

if [[ $1 && $2 ]]; then
    userdel -f -r "$1"
    rm -fR /etc/php/7.2/fpm/pool.d/"$1".conf
    rm -fR /etc/nginx/sites/"$2".conf
    service nginx restart
    service php7.2-fpm restart
else
    echo "deleteUser {user} {domain}"
fi
