## After starting vagrant then scripts are run.

## First script create service, which will monitor the log for the presence of a keyword every 30 seconds (grep_service.sh):
```
cat <<'EOF' > /etc/sysconfig/grep
LOG_FILE=/var/log/messages
WORD=kernel
EOF

cat <<'EOF' > /etc/systemd/system/grep.service
[Unit]
Description=Service for grep log file

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/grep
ExecStart=/usr/bin/grep $WORD $LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/systemd/system/grep.timer
[Unit]
Description=Timer for grep.service

[Timer]
OnCalendar=*:*:0,30
Unit=grep.service

[Install]
WantedBy=timers.target
EOF

chmod +x /etc/systemd/system/grep.*
systemctl enable grep.timer && systemctl start grep.timer

```

## Second script rewrites init script to unit file (spawn_fcgi.sh):
```
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
```

## The third script makes it possible to run two httpd instanses (httpd.sh):
```
#!/bin/bash

yum install -y httpd
sed -i '/Listen 80/d' /etc/httpd/conf/httpd.conf

cat <<'EOF' > /etc/systemd/system/httpd@.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/httpd/conf.d/template.conf
Listen ${PORT}
PidFile ${PID_FILE}
EOF

cat <<'EOF' > /etc/sysconfig/httpd1
PORT=8001
PID_FILE=/etc/httpd/run/httpd1.pid
EOF

cat <<'EOF' > /etc/sysconfig/httpd2
PORT=8002
PID_FILE=/etc/httpd/run/httpd1.pid
EOF

systemctl enable --now httpd@httpd1.service
systemctl enable --now httpd@httpd2.service
ss -ntplu | grep -E '(8001|8002)'
```
