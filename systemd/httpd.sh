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
