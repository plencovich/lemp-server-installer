#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin NGINX Auto-Installer for Ubuntu
#+----------------------------------------------------------------------------+
#+ Author:      Diego Plenco
#+ Copyright:   2018 Plen.co
#+ GitHub:      https://github.com/plencovich/lemp-server-installer
#+ Issues:      https://github.com/plencovich/lemp-server-installer/issues
#+ License:     GPL v3.0
#+ OS:          Ubuntu 18.04
#+ Release:     1.0.0
#+ Website:     https://plen.co
#+----------------------------------------------------------------------------+

clear

#+----------------------------------------------------------------------------+
#+ Comprobación de usuario root
#+----------------------------------------------------------------------------+
if [ "${EUID}" != 0 ];
then
    echo "ServerAdmin NGINX Auto-Installer debe ejecutarse como usuario root."
    exit
fi

#+----------------------------------------------------------------------------+
#+ Configuración de Versiones
#+----------------------------------------------------------------------------+
cpuCount=$(nproc --all)
currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dhparamBits="4096"
nginxUser="nginx"
openSslVers="1.0.2r"
pagespeedVers="1.13.35.2"
pcreVers="8.43"
zlibVers="1.2.11"

#+----------------------------------------------------------------------------+
#+ Setup
#+----------------------------------------------------------------------------+
nginxSetup()
{
    #+------------------------------------------------------------------------+
    #+ Actualización de repositorios e instalación de los paquetes necesarios.
    #+------------------------------------------------------------------------+
    apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install autoconf automake gcc bc bison build-essential ccache cmake curl dh-systemd flex gcc geoip-bin google-perftools g++ haveged icu-devtools letsencrypt libacl1-dev libbz2-dev libcap-ng-dev libcap-ng-utils libcurl4-openssl-dev libdmalloc-dev libenchant-dev libevent-dev libexpat1-dev libfontconfig1-dev libfreetype6-dev libgd-dev libgeoip-dev libghc-iconv-dev libgmp-dev libgoogle-perftools-dev libice-dev libice6 libicu-dev libjbig-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libluajit-5.1-2 libluajit-5.1-common libluajit-5.1-dev liblzma-dev libmhash-dev libmhash2 libmm-dev libncurses5-dev libnspr4-dev libpam0g-dev libpcre3 libpcre3-dev libperl-dev libpng-dev libpthread-stubs0-dev libreadline-dev libselinux1-dev libsm-dev libsm6 libssl-dev libtidy-dev libtiff5-dev libtiffxx5 libtool libunbound-dev libvpx-dev libwebp-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev libxml2-dev libxpm-dev libxslt1-dev libxt-dev libxt6 make nano perl pkg-config python-dev software-properties-common systemtap-sdt-dev unzip webp wget xtrans-dev zip zlib1g-dev zlibc unzip sysstat auditd uuid-dev

    #+------------------------------------------------------------------------+
    #+ Comprueba si existe un usuario llamado nginx
    #+------------------------------------------------------------------------+
    local nginxUserExists=$(id -u ${nginxUser} > /dev/null 2>&1; echo $?)

    #+------------------------------------------------------------------------+
    #+ Sino existe lo crea asignando un directorio y setea el shell
    #+------------------------------------------------------------------------+
    if [ "${nginxUserExists}" != "0" ];
    then
        useradd -d /etc/nginx -s /bin/false nginx
    fi

    #+------------------------------------------------------------------------+
    #+ Crea directorios para construir Nginx
    #+------------------------------------------------------------------------+
    mkdir -p /home/nginx/htdocs/public \
    && mkdir -p /usr/local/src/{github,packages/{openssl,pcre,zlib}} \
    && mkdir -p /etc/nginx/cache/{client,fastcgi,proxy,uwsgi,scgi} \
    && mkdir -p /etc/nginx/config/{php,proxy,sites,ssl} \
    && mkdir -p /etc/nginx/{lock,logs/{domains,server/{access,error}}} \
    && mkdir -p /etc/nginx/{modules,pid,sites,ssl}

    #+------------------------------------------------------------------------+
    #+ Clona los repositorios requeridos desde GitHub
    #+------------------------------------------------------------------------+
    #+ 1). NGINX
    #+ 2). NGINX Dev. Kit (Module)
    #+ 3). NGINX Headers More (Module)
    #+ 4). NGINX VTS (Module)
    #+ 5). Brotli (for Brotli Compression)
    #+ 6). LibBrotli
    #+ 7). NGINX Brotli (Module)
    #+ 8). NAXSI (Module)
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github \
    && git clone https://github.com/nginx/nginx.git \
    && git clone https://github.com/simpl/ngx_devel_kit.git \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && git clone https://github.com/google/brotli.git \
    && git clone https://github.com/bagder/libbrotli \
    && git clone https://github.com/google/ngx_brotli \
    && git clone https://github.com/nbs-system/naxsi.git \
    && git clone https://github.com/openresty/set-misc-nginx-module.git

    #+------------------------------------------------------------------------+
    #+ Google Pagespeed for NGINX
    #+ https://modpagespeed.com/doc/build_ngx_pagespeed_from_source
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github \
    && wget https://github.com/pagespeed/ngx_pagespeed/archive/v${pagespeedVers}-stable.zip \
    && unzip v${pagespeedVers}-stable.zip \
    && cd incubator-pagespeed-ngx-${pagespeedVers}-stable \
    && export psol_url=https://dl.google.com/dl/page-speed/psol/${pagespeedVers}-x64.tar.gz \
    && [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) \
    && wget ${psol_url} \
    && tar -xzvf $(basename ${psol_url})

    #+------------------------------------------------------------------------+
    #+ Instala Brotli
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/brotli \
    && python setup.py install

    #+------------------------------------------------------------------------+
    #+ Configura & Crea LibBrotli
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/libbrotli \
    && ./autogen.sh \
    && ./configure \
    && make -j ${cpuCount} \
    && make install

    #+------------------------------------------------------------------------+
    #+ Inicializa el módulo NGINX Brotli
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/ngx_brotli \
    && git submodule update --init

    #+------------------------------------------------------------------------+
    #+ Descarga y descomprime PCRE, OpenSSL y ZLIB para compilar NGINX
    #+------------------------------------------------------------------------+
    cd /usr/local/src/packages \
    && wget https://www.openssl.org/source/openssl-${openSslVers}.tar.gz \
    && wget https://ftp.pcre.org/pub/pcre/pcre-${pcreVers}.tar.gz \
    && wget http://www.zlib.net/zlib-${zlibVers}.tar.gz \
    && tar xvf openssl-${openSslVers}.tar.gz --strip-components=1 -C /usr/local/src/packages/openssl \
    && tar xvf pcre-${pcreVers}.tar.gz --strip-components=1 -C /usr/local/src/packages/pcre \
    && tar xvf zlib-${zlibVers}.tar.gz --strip-components=1 -C /usr/local/src/packages/zlib

    #+------------------------------------------------------------------------+
    #+ Genera dhparam.pem y lo guarda en /etc/nginx/ssl
    #+------------------------------------------------------------------------+
    #+ Paciencia, este proceso puede durar dependiendo del CPU
    #+------------------------------------------------------------------------+
    openssl dhparam -out /etc/nginx/ssl/dhparam.pem ${dhparamBits}

}

nginxCompile()
{
    #+------------------------------------------------------------------------+
    #+ Configura y Compila NGINX
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/nginx \
    && ./auto/configure --prefix=/etc/nginx \
                        --sbin-path=/usr/sbin/nginx \
                        --conf-path=/etc/nginx/config/nginx.conf \
                        --lock-path=/etc/nginx/lock/nginx.lock \
                        --pid-path=/etc/nginx/pid/nginx.pid \
                        --error-log-path=/etc/nginx/logs/error.log \
                        --http-log-path=/etc/nginx/logs/access.log \
                        --http-client-body-temp-path=/etc/nginx/cache/client \
                        --http-proxy-temp-path=/etc/nginx/cache/proxy \
                        --http-fastcgi-temp-path=/etc/nginx/cache/fastcgi \
                        --http-uwsgi-temp-path=/etc/nginx/cache/uwsgi \
                        --http-scgi-temp-path=/etc/nginx/cache/scgi \
                        --user=nginx \
                        --group=nginx \
                        --with-poll_module \
                        --with-threads \
                        --with-file-aio \
                        --with-http_ssl_module \
                        --with-http_v2_module \
                        --with-http_realip_module \
                        --with-http_addition_module \
                        --with-http_xslt_module \
                        --with-http_image_filter_module \
                        --with-http_sub_module \
                        --with-http_dav_module \
                        --with-http_flv_module \
                        --with-http_mp4_module \
                        --with-http_gunzip_module \
                        --with-http_gzip_static_module \
                        --with-http_auth_request_module \
                        --with-http_random_index_module \
                        --with-http_secure_link_module \
                        --with-http_degradation_module \
                        --with-http_slice_module \
                        --with-http_stub_status_module \
                        --with-stream \
                        --with-stream_ssl_module \
                        --with-stream_realip_module \
                        --with-stream_geoip_module \
                        --with-stream_ssl_preread_module \
                        --with-google_perftools_module \
                        --with-pcre=/usr/local/src/packages/pcre \
                        --with-pcre-jit \
                        --with-zlib=/usr/local/src/packages/zlib \
                        --with-openssl=/usr/local/src/packages/openssl \
                        --add-module=/usr/local/src/github/naxsi/naxsi_src \
                        --add-module=/usr/local/src/github/ngx_devel_kit \
                        --add-module=/usr/local/src/github/nginx-module-vts \
                        --add-module=/usr/local/src/github/ngx_brotli \
                        --add-module=/usr/local/src/github/headers-more-nginx-module \
                        --add-module=/usr/local/src/github/set-misc-nginx-module \
                        --add-module=/usr/local/src/github/incubator-pagespeed-ngx-${pagespeedVers}-stable \
    && make -j ${cpuCount} \
    && make install
}

nginxConfigure()
{
    #+------------------------------------------------------------------------+
    #+ Elimina los archivos *.default de la configuración
    #+------------------------------------------------------------------------+
    rm -rf /etc/nginx/config/*.default

    #+------------------------------------------------------------------------+
    #+ Elimina el archivo de configuración por default de NGINX
    #+------------------------------------------------------------------------+
    rm /etc/nginx/config/nginx.conf

    #+------------------------------------------------------------------------+
    #+ Elimina el archivo de configuración por default de fastcgi_params
    #+------------------------------------------------------------------------+
    rm /etc/nginx/config/fastcgi.conf \
    && rm /etc/nginx/config/fastcgi_params

    #+------------------------------------------------------------------------+
    #+ Copia la nueva configuración.
    #+------------------------------------------------------------------------+
    cp -R ${currentPath}/html/index.html /home/nginx/htdocs/public/index.html \
    && cp -R ${currentPath}/nginx/* /etc/nginx \
    && cp -R ${currentPath}/systemd/nginx.service /lib/systemd/system/nginx.service

    #+------------------------------------------------------------------------+
    #+ Configuración de permisos y dueño
    #+------------------------------------------------------------------------+
    chown -R nginx:nginx /home/nginx

    #+------------------------------------------------------------------------+
    #+ Crea el servicio NGINX y lo incia.
    #+------------------------------------------------------------------------+
    systemctl enable nginx \
    && systemctl start nginx
}

nginxCleanup()
{
    #+------------------------------------------------------------------------+
    #+ Eliminamos las carpetas github y packages
    #+------------------------------------------------------------------------+
    rm -rf /usr/local/src/github \
    && rm -rf /usr/local/src/packages
}

nginxSetup \
&& nginxCompile \
&& nginxConfigure \
&& nginxCleanup
