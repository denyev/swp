#! /usr/bin/env bash

which nginx
INSTALLED=$?

if [[ $INSTALLED != 0 ]]; then
    sudo apt update && \
    sudo apt install nginx
fi

sudo rm -iv /etc/nginx/sites-enabled/default && \
mkdir -vp $HOME/web/{logs,public,public/{img,css,js},uploads,etc} && \
cat > $HOME/web/etc/nginx.conf <<_EOF
# http://eax.me/nginx/
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  limit_rate 512k;
  server_tokens off;
  access_log   /home/box/web/logs/nginx.access_log  main;
  error_log  /home/box/web/logs/nginx.error_log  debug;  

  root /home/box/web/public;
  index index.html index.htm;

  # Make site accessible from http://localhost/
  server_name default_server;
  
  location ~* ^.+\.\w+$  {
    # https://regex101.com/r/4sXIve/1
    root /home/box/web/public;
  }
  
  location ^~ /uploads/ {
    root /home/box/web/;
  }
  
  location /+  {
    return 404;
  }
}
_EOF
sudo ln -sv $HOME/web/etc/nginx.conf /etc/nginx/sites-enabled/test.conf && \
sudo /etc/init.d/nginx start
