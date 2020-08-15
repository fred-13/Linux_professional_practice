## After running "vagrant up" provisionering first script create lvm for backup / dir (lvm_migration.sh):
```
yum install xfsdump -y

pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/ <<"EOT"
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
sed -i 's!rd.lvm.lv=VolGroup00/LogVol00!rd.lvm.lv=vg_root/lv_root!' /boot/grub2/grub.cfg
EOT
```

## Second provisionering script delete old lvm then create new for / dir sized 8gb and create mirror lvm for /var dir (new_lvm.sh):
```
yes | lvremove /dev/VolGroup00/LogVol00
yes | lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/ <<"EOT" 
grub2-mkconfig -o /boot/grub2/grub.cfg 
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
pvcreate /dev/sdc /dev/sdd
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
umount /mnt
mount /dev/vg_var/lv_var /var
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
sed -i 's!rd.lvm.lv=vg_root/lv_root!rd.lvm.lv=VolGroup00/LogVol00!' /boot/grub2/grub.cfg
EOT
```

## Third provisionering script create lvm and snapshot for /home dir (lvm_home.sh):
```
yes | lvremove /dev/vg_root/lv_root
yes | vgremove /dev/vg_root
pvremove /dev/sdb

lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
touch /home/file{1..20}
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
rm -f /home/file{11..20}
umount -l /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
```
