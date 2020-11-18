#!/bin/bash

chmod +x /home/vagrant/borgbackup.sh

cat <<'EOF' > /etc/systemd/system/backup.service
[Unit]
Description=Service for BackUp

[Service]
Type=notify
ExecStart=/home/vagrant/borgbackup.sh

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/systemd/system/backup.timer
[Unit]
Description=Timer for BackUp

[Timer]
OnCalendar=*:0/5
Unit=backup.service

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/backup.*
systemctl enable backup.timer && systemctl start backup.timer
