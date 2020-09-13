#!/bin/bash

yum install -y epel-release
yum install -y gcc fcgi-devel spawn-fcgi nginx

cat <<'EOF' > test-web.c
#include "fcgi_stdio.h"
#include <stdlib.h>

int main(void)
{
    int count = 0;
    while (FCGI_Accept() >= 0)
        printf("HTTP/1.1 200 OK\r\n"
               "Content-type: text/html\r\n"
               "\r\n"
               "<title>FastCGI Hello!</title>\n"
               "<h1>FastCGI Hello!</h1>\n"
               "Request number %d\n",
               ++count);

    return 0;
}
EOF

gcc -o /usr/bin/test-web test-web.c -lfcgi

cat <<'EOF' > /etc/sysconfig/spawn-fcgi
OPTIONS="-a 127.0.0.1 -p 9000 -f /usr/bin/test-web"
EOF

cat <<'EOF' > /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=The service for running fcgi programm
After=network.target
Documentation=man:spawn-fcgi(1)

[Service]
Type=forking
ExecStart=/usr/bin/spawn-fcgi $OPTIONS
ExecReload=/usr/bin/spawn-fcgi $OPTIONS
EnvironmentFile=/etc/sysconfig/spawn-fcgi

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now spawn-fcgi.service

cat <<'EOF' > /etc/nginx/nginx.conf
events { }

http {
    server {
        listen 80;
        server_name _;

        location / {
            fastcgi_pass 127.0.0.1:9000;
        }
    }
}
EOF

systemctl enable --now nginx.service
curl localhost
