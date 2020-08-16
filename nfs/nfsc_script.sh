#!/bin/bash

yum install nfs-utils -y
systemctl enable firewalld.service
systemctl start firewalld.service
systemctl start rpcbind
systemctl enable rpcbind
mkdir -p /nfs/share
mount -t nfs 192.168.50.10:/data/nfs_share /nfs/share/ -o rw,noatime,noauto,x-systemd.automount,nosuid,noexec,proto=udp,vers=3
echo "192.168.50.10:/data/nfs_share /nfs/share	nfs	rw,noatime,noauto,x-systemd.automount,nosuid,noexec,proto=udp,vers=3	0 0" >> /etc/fstab
