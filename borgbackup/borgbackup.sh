#!/bin/bash

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
