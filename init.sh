#! /usr/bin/env bash

mkdir -vp ${HOME}/web/{logs,public,public/{img,css,js},uploads,etc} 

check_install() {
    which ${1}
    INSTALLED=$?

    if [[ ${INSTALLED} != 0 ]]; then
        sudo apt update && \
        sudo apt install ${1}
    fi
}

create_conf() {
    CONF_LOCAL_FILE=${1}
    CONF_FILE=${2}

    if [ ! -f ${CONF_FILE} ]; then
        sudo ln -sv ${HOME}/${CONF_LOCAL_FILE} ${CONF_FILE}
    fi
}

# config nginx

check_install nginx

DEFAULT_NGINX_CONF="/etc/nginx/sites-enabled/default"

if [ -f ${DEFAULT_NGINX_CONF} ]; then
    sudo rm -iv /etc/nginx/sites-enabled/default 
fi

cat > ${HOME}/web/etc/nginx.conf <<_EOF
# http://eax.me/nginx/
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  limit_rate 512k;
  server_tokens off;
  access_log   ${HOME}/web/logs/nginx.access_log;
  error_log  ${HOME}/web/logs/nginx.error_log  debug;  

  root ${HOME}/web/public;
  index index.html index.htm;

  # Make site accessible from http://localhost/
  server_name default_server;
  
  location ~* ^.+\.\w+$  {
    # https://regex101.com/r/4sXIve/1
    root ${HOME}/web/public;
  }
  
  location ^~ /uploads/ {
    root ${HOME}/web/;
  }
  
  location /+  {
    return 404;
  }
}
_EOF

create_conf "web/etc/nginx.conf" "/etc/nginx/sites-enabled/test.conf"

sudo /etc/init.d/nginx start

# config gunicorn

check_install gunicorn

