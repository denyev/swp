#! /usr/bin/env bash

which nginx
INSTALLED=$?

if [[ ${INSTALLED} != 0 ]]; then
    sudo apt update && \
    sudo apt install nginx
fi

DEFAULT_NGINX_CONF="/etc/nginx/sites-enabled/default"

if [ -f ${DEFAULT_NGINX_CONF} ]; then
    sudo rm -iv /etc/nginx/sites-enabled/default 
fi

mkdir -vp ${HOME}/web/{logs,public,public/{img,css,js},uploads,etc} && \
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

NGINX_CONF="/etc/nginx/sites-enabled/test.conf"

if [ ! -f ${NGINX_CONF} ]; then
    sudo ln -sv ${HOME}/web/etc/nginx.conf ${NGINX_CONF}
fi


sudo /etc/init.d/nginx start
