#!/bin/bash

yum install -y mdadm smartmontools hdparm gdisk

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g,h,i}

mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sd{b,c}
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid0/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid0/part$i; done

yes | mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{d,e}
mkdir /raid-1
mkfs.ext4 /dev/md1
mount /dev/md1 /raid-1

mdadm --create --verbose /dev/md10 --force -l 10 -n 4 /dev/sd{f,g,h,i}
mkdir /raid-10
mkfs.ext4 /dev/md10
mount /dev/md10 /raid-10

echo "DEVICE partitions" > /usr/lib/tmpfiles.d/mdadm.conf 
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /usr/lib/tmpfiles.d/mdadm.conf

cat <<EOF >> /etc/fstab
# RAID-0
/dev/md0p1	/raid0/part1	ext4	defaults	0 0
/dev/md0p2	/raid0/part2	ext4	defaults	0 0
/dev/md0p3	/raid0/part3	ext4	defaults	0 0
/dev/md0p4	/raid0/part4	ext4	defaults	0 0
/dev/md0p5	/raid0/part5	ext4	defaults	0 0
# RAID-1
/dev/md1	/raid-1		ext4	defaults	0 0
# RAID-10
/dev/md10	/raid-10	ext4	defaults	0 0
EOF
