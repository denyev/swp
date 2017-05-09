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
# https://github.com/benoitc/gunicorn/blob/master/examples/nginx.conf
upstream app_server {
    server unix:/tmp/gunicorn.sock fail_timeout=0;

}

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

    location @proxy_to_app {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://app_server;
    }

}
_EOF

create_conf "web/etc/nginx.conf" "/etc/nginx/sites-enabled/test.conf"

sudo /etc/init.d/nginx start

# config gunicorn

check_install gunicorn

cat > ${HOME}/web/hello.py <<_EOF
def app(environ, start_response):
        data = b"Hello, World!\n"
        start_response("200 OK", [
            ("Content-Type", "text/plain"),
            ("Content-Length", str(len(data)))
        ])
        return iter([data])
_EOF

cat > ${HOME}/etc/hello.py <<_EOF

_EOF

create_conf "web/etc/hello.py" "/etc/gunicorn.d/hello.py"