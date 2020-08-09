## Write disks in Vagrantfile for mount on VM:
```
    :sata1 => {
            :dfile => './sata1.vdi',
            :size => 250,
            :port => 1
    },
    :sata2 => {
            :dfile => './sata2.vdi',
            :size => 250,
            :port => 2
    },
    :sata3 => {
            :dfile => './sata3.vdi',
            :size => 250,
            :port => 3
    },
    :sata4 => {
            :dfile => './sata4.vdi',
            :size => 250,
            :port => 4
    },
    :sata5 => {
            :dfile => './sata5.vdi',
            :size => 250,
            :port => 5
    },
    :sata6 => {
            :dfile => './sata6.vdi',
            :size => 250,
            :port => 6
    },
    :sata7 => {
            :dfile => './sata7.vdi',
            :size => 250,
            :port => 7
    },
    :sata8 => {
            :dfile => './sata8.vdi',
            :size => 250,
            :port => 8
    }
```

## Run VM:
```
$ vagrant up
```

## After running VM provisionering script:
```
config.vm.provision "shell", path: "raid_create.sh"
```

## First installing tools for create and configure RAID:
```
$ yum install -y mdadm smartmontools hdparm gdisk
```

## We'll zero in on superblocks
```
$ mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g,h,i}
```

## Create RAID-0, then create a GPT partition, five partitions and mount them to disk:
```
$ mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sd{b,c}
$ parted -s /dev/md0 mklabel gpt
$ parted /dev/md0 mkpart primary ext4 0% 20%
$ parted /dev/md0 mkpart primary ext4 20% 40%
$ parted /dev/md0 mkpart primary ext4 40% 60%
$ parted /dev/md0 mkpart primary ext4 60% 80%
$ parted /dev/md0 mkpart primary ext4 80% 100%
$ for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
$ mkdir -p /raid0/part{1,2,3,4,5}
$ for i in $(seq 1 5); do mount /dev/md0p$i /raid0/part$i; done
```

## Create RAID-1 and mount disk for /raid-1 dir
```
$ yes | mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{d,e}
$ mkdir /raid-1
$ mkfs.ext4 /dev/md1
$ mount /dev/md1 /raid-1
```

## Create RAID-10 and mount disk for /raid-10 dir
```
$ mdadm --create --verbose /dev/md10 --force -l 10 -n 4 /dev/sd{f,g,h,i}
$ mkdir /raid-10
$ mkfs.ext4 /dev/md10
$ mount /dev/md10 /raid-10
```

## Create configuration file mdadm.conf:
```
$ echo "DEVICE partitions" > /usr/lib/tmpfiles.d/mdadm.conf 
$ mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /usr/lib/tmpfiles.d/mdadm.conf
```
