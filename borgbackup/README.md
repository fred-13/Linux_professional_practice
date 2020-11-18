## Vagrant start the borgbackup server and provision script create pv for backup files:
```
mkdir /var/backup
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /var/backup
```

## Then prepare a pre-installation script to configure the server:
```
$preinstall = <<SCRIPT
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ""
ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -P ""
yum install sshpass wget -y
wget https://github.com/borgbackup/borg/releases/download/1.1.14/borg-linux64
cp borg-linux64 /usr/local/bin/borg
chown root:root /usr/local/bin/borg
chmod 755 /usr/local/bin/borg
alias borg="/usr/local/bin/borg"
echo "alias borg=/usr/local/bin/borg" >> /root/.bashrc
SCRIPT
```

## Second scenario vagrant started borgbackup client vm and provision pre-installation script. The following script started initializing the backup directory on the vm borgbackup server with passphrase:
```
client.vm.provision "shell", inline: <<-EOC
echo "192.168.11.100 server" >> /etc/hosts
sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no root@server
sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no vagrant@server
printf "123456\n123456\n\ny" | /usr/local/bin/borg init --encryption=repokey root@server:/var/backup/$(hostname)-etc
EOC
```

## And the third script sets up a systemd timer to create a backup every 5 minutes:
```
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
```

## The systemd backup.service startup script creates a backup and configures the rotation of this backups:
```
export BORG_PASSPHRASE=123456
REPOSITORY=root@server:/var/backup/$(hostname)-etc

info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM
info "Starting backup"

/usr/local/bin/borg create -v --stats --progress $REPOSITORY::"{now:%Y-%m-%d-%H-%M}" /etc

backup_exit=$?
info "Pruning repository"

/usr/local/bin/borg prune -v --show-rc --list $REPOSITORY --keep-within=90d --keep-monthly=-1 --keep-yearly=-1

prune_exit=$?
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi
exit ${global_exit}
```

## Output of logs from the backup.service service in 30 minutes:
```
[root@client vagrant]# journalctl -fu backup.service

    ...

Nov 18 11:30:45 client systemd[1]: Started Service for BackUp.
Nov 18 11:35:41 client systemd[1]: Starting Service for BackUp...
Nov 18 11:35:41 client borgbackup.sh[4298]: Wed Nov 18 11:35:41 UTC 2020 Starting backup
Nov 18 11:35:41 client borgbackup.sh[4298]: Using a pure-python msgpack! This will result in lower performance.
Nov 18 11:35:42 client borgbackup.sh[4298]: Remote: Using a pure-python msgpack! This will result in lower performance.
Nov 18 11:35:42 client borgbackup.sh[4298]: Creating archive at "root@server:/var/backup/client-etc::{now:%Y-%m-%d-%H-%M}"
Nov 18 11:35:43 client borgbackup.sh[4298]: [669B blob data]
Nov 18 11:35:43 client borgbackup.sh[4298]: Archive name: 2020-11-18-11-35
Nov 18 11:35:43 client borgbackup.sh[4298]: Archive fingerprint: eb6397d19eb89c72887e00dfab20fd85ee4efbda04124c5e3eb6985dfd64d83e
Nov 18 11:35:43 client borgbackup.sh[4298]: Time (start): Wed, 2020-11-18 11:35:42
Nov 18 11:35:43 client borgbackup.sh[4298]: Time (end):   Wed, 2020-11-18 11:35:43
Nov 18 11:35:43 client borgbackup.sh[4298]: Duration: 0.56 seconds
Nov 18 11:35:43 client borgbackup.sh[4298]: Number of files: 1671
Nov 18 11:35:43 client borgbackup.sh[4298]: Utilization of max. archive size: 0%
Nov 18 11:35:43 client borgbackup.sh[4298]: ------------------------------------------------------------------------------
Nov 18 11:35:43 client borgbackup.sh[4298]: Original size      Compressed size    Deduplicated size
Nov 18 11:35:43 client borgbackup.sh[4298]: This archive:               26.99 MB             12.81 MB                764 B
Nov 18 11:35:43 client borgbackup.sh[4298]: All archives:              215.91 MB            102.46 MB             11.41 MB
Nov 18 11:35:43 client borgbackup.sh[4298]: Unique chunks         Total chunks
Nov 18 11:35:43 client borgbackup.sh[4298]: Chunk index:                    1279                13405
Nov 18 11:35:43 client borgbackup.sh[4298]: ------------------------------------------------------------------------------
Nov 18 11:35:43 client borgbackup.sh[4298]: Wed Nov 18 11:35:43 UTC 2020 Pruning repository
Nov 18 11:35:44 client borgbackup.sh[4298]: Using a pure-python msgpack! This will result in lower performance.
Nov 18 11:35:44 client borgbackup.sh[4298]: Remote: Using a pure-python msgpack! This will result in lower performance.
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-35                     Wed, 2020-11-18 11:35:42 [eb6397d19eb89c72887e00dfab20fd85ee4efbda04124c5e3eb6985dfd64d83e]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-30                     Wed, 2020-11-18 11:30:42 [0e763ac623df0b2aa22c90bc0f4c9a9063eb6598bf11e12d3f7655aa623eb1a5]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-25                     Wed, 2020-11-18 11:25:35 [6a55829f1216c7bead6c0e32154afab986cad181cddca154cb21bf935f7d25ba]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-20                     Wed, 2020-11-18 11:20:42 [65f24e1dd5a98ff7889b7a6c6820aa8922ac5dfa7739e2bcfd926cb30a20776c]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-15                     Wed, 2020-11-18 11:15:42 [99cbd7434b95601f390680a914d7491662e8dc4f4f99a05309e4eb61dbe4a604]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-10                     Wed, 2020-11-18 11:10:35 [9bb11c84c5f147626064f095b4a4e0d270014e10b79e4b83ea695c6ee1f9166e]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-05                     Wed, 2020-11-18 11:05:42 [20a2e03cc798bc47b0224a4dcebebcf6a54609330b7e2e9cee9d1836e2517450]
Nov 18 11:35:45 client borgbackup.sh[4298]: Keeping archive: 2020-11-18-11-00                     Wed, 2020-11-18 11:00:42 [447783b96ecb602fde33322f1dbfec9652cfd21f0b85768e693a0f3206f0402d]
Nov 18 11:35:45 client borgbackup.sh[4298]: terminating with success status, rc 0
Nov 18 11:35:45 client borgbackup.sh[4298]: Wed Nov 18 11:35:45 UTC 2020 Backup and Prune finished successfully
Nov 18 11:35:45 client systemd[1]: Started Service for BackUp.

    ...
```

## Show backups on borgbackup vm server:
```
[root@server vagrant]# export BORG_PASSPHRASE=123456
[root@server vagrant]# borg list /var/backup/client-etc

2020-11-18-11-00                     Wed, 2020-11-18 11:00:42 [447783b96ecb602fde33322f1dbfec9652cfd21f0b85768e693a0f3206f0402d]
2020-11-18-11-05                     Wed, 2020-11-18 11:05:42 [20a2e03cc798bc47b0224a4dcebebcf6a54609330b7e2e9cee9d1836e2517450]
2020-11-18-11-10                     Wed, 2020-11-18 11:10:35 [9bb11c84c5f147626064f095b4a4e0d270014e10b79e4b83ea695c6ee1f9166e]
2020-11-18-11-15                     Wed, 2020-11-18 11:15:42 [99cbd7434b95601f390680a914d7491662e8dc4f4f99a05309e4eb61dbe4a604]
2020-11-18-11-20                     Wed, 2020-11-18 11:20:42 [65f24e1dd5a98ff7889b7a6c6820aa8922ac5dfa7739e2bcfd926cb30a20776c]
2020-11-18-11-25                     Wed, 2020-11-18 11:25:35 [6a55829f1216c7bead6c0e32154afab986cad181cddca154cb21bf935f7d25ba]
2020-11-18-11-30                     Wed, 2020-11-18 11:30:42 [0e763ac623df0b2aa22c90bc0f4c9a9063eb6598bf11e12d3f7655aa623eb1a5]
2020-11-18-11-35                     Wed, 2020-11-18 11:35:42 [eb6397d19eb89c72887e00dfab20fd85ee4efbda04124c5e3eb6985dfd64d83e]

```

## As we see backups created every 5 minutes.
