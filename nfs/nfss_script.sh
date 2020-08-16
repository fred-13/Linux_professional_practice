#!/bin/bash

yum install nfs-utils -y
systemctl enable firewalld.service 
systemctl start firewalld.service 
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --reload
mkdir -p /data/nfs_share
chown -R nfsnobody:nfsnobody /data/nfs_share/
chmod -R 777 /data/nfs_share/
echo "/data/nfs_share/           192.168.50.11(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server
exportfs -r && exportfs
