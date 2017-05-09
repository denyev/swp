#! /usr/bin/env bash

sudo apt update && \
sudo apt install nginx && \
sudo rm -v /etc/nginx/sites-enabled/default && \
mkdir -vp $HOME/web/{public,public/{img,css,js},uploads,etc} && \
cat > $HOME/web/etc/nginx.conf <<_EOF
# http://eax.me/nginx/
server {
  listen 80 *;
  listen [::]:80 * ipv6only=on;
  limit_rate 512k;
  server_tokens off;
  error_page 404 https://stepik.org/somepage;

  root /home/box/web/public;
  index index.html index.htm;

  # Make site accessible from http://localhost/
  server_name *;
  
  location ~* ^.+\.\w{3,4}$  {
    # https://regex101.com/r/4sXIve/1
    root /home/box/web/public;
  }
  
  location ^~ /uploads/ {
    root /home/box/web/;
  }
  
  location /  {
    return 404;
  }
}
_EOF
sudo ln -sv $HOME/web/etc/nginx.conf /etc/nginx/sites-enabled/test.conf && \
sudo service nginx reload
