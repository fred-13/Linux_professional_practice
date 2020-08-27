#!/bin/bash

vgrename VolGroup00 OtusRoot
for file_config in /etc/fstab /etc/default/grub /boot/grub2/grub.cfg;
    do
        sed -i 's/VolGroup00/OtusRoot/g' $file_config;
    done
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
shutdown -h now
