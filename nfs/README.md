## When run "vagrant up" first started NFS-Server and provisioning script nfss_script.sh on him.
## Installed utils:
```
yum install nfs-utils -y
```
## Configuration firewall:
```
systemctl enable firewalld.service 
systemctl start firewalld.service 
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --reload
```
## Create and taked permissions for share dir:
```
mkdir -p /data/nfs_share
chown -R nfsnobody:nfsnobody /data/nfs_share/
chmod -R 777 /data/nfs_share/
echo "/data/nfs_share/           192.168.50.11(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
```
## Add rpcbind and nfs services to startup and start them:
```
systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server
exportfs -r && exportfs
```

## Second started NFS-Client and provisioning script nfsc_script.sh on him.
## Installed utils:
```
yum install nfs-utils -y
```
## Started firewall:
```
systemctl enable firewalld.service
systemctl start firewalld.service
```
## Add rpcbind to startup and start them:
```
systemctl enable rpcbind
systemctl start rpcbind
```
## Created dir and mount for him share from NFS-Server used NFS_V3:
```
mkdir -p /nfs/share
mount -t nfs 192.168.50.10:/data/nfs_share /nfs/share/ -o rw,noatime,noauto,x-systemd.automount,nosuid,noexec,proto=udp,vers=3
echo "192.168.50.10:/data/nfs_share /nfs/share	nfs	rw,noatime,noauto,x-systemd.automount,nosuid,noexec,proto=udp,vers=3	0 0" >> /etc/fstab
```
