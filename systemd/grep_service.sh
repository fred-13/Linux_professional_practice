#!/bin/bash

setenforce 0

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
