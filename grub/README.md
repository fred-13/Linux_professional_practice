## Important!!! Please install plugin vagrant-reload:
```
vagrant plugin install vagrant-reload
```

## First provisioning script grub_rename_vgs.sh on VM.
## Renamed volume group:
```
vgrename VolGroup00 OtusRoot
```

## We replace the old everywhere new name:
```
for file_config in /etc/fstab /etc/default/grub /boot/grub2/grub.cfg;
    do
        sed -i 's/VolGroup00/OtusRoot/g' $file_config;
    done
```

## Recreate initrd image:
```
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```

## Second provisioning script grub_change_module.sh on VM.
## Created dir for scripts modules and created the scripts on this dir:
```
mkdir /usr/lib/dracut/modules.d/01test

cat <<'EOF' > /usr/lib/dracut/modules.d/01test/module-setup.sh
#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/test.sh"
}
EOF

cat <<'EOF' > /usr/lib/dracut/modules.d/01test/test.sh
#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
 ___________________
< I'm dracut module >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
EOF

chmod +x /usr/lib/dracut/modules.d/01test/*
```

## Recreate initrd image then turn off rghb and quiet options:
```
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
sed -i 's/ rhgb quiet//g' /boot/grub2/grub.cfg
```
