# NOTE: The entire course of work should be viewed in a detailed log on vagrant output.

## If running command "vagrant up" then starting provisioning inline script for install zfs and dependens utils:
```
$installzfs = <<SCRIPT
yum install -y epel-release yum-utils wget
yum -y install http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum repolist | grep zfs && echo ZFS repo enabled
yum install -y zfs && /sbin/modprobe zfs
SCRIPT
    ...

config.vm.provision "shell", inline: $installzfs
```

## Then provisioning script for firts task:
```
diskzfs=$(fdisk -l | grep "Disk \/dev\/sd[a-z]: 10" | cut -d ":" -f 1 | awk '{print $2}')
wget -O War_and_Peace.txt https://www.litres.ru/leo-tolstoy/war-and-peace/?lfrom=509222890
zpool create pool0 $diskzfs
for i in $(seq 1 4);do zfs create pool0/data$i; done
zfs set compression=lzjb pool0/data1
zfs set compression=gzip-9 pool0/data2
zfs set compression=zle pool0/data3
zfs set compression=lz4 pool0/data4
for i in $(seq 1 4);do cp -vr War_and_Peace.txt /pool0/data$i; done
sleep 5
echo ""
echo "############ Size Files #############"
du -sh /pool0/data{1..4}/War_and_Peace.txt
echo ""
echo "###### Compression type and ratio #######"
zfs get compression,compressratio
```

## As a result of the output, we see that the best compression algorithm is "gzip-9":
```
    zfs: ############ Size Files #############
    zfs: 78K    /pool0/data1/War_and_Peace.txt
    zfs: 36K    /pool0/data2/War_and_Peace.txt
    zfs: 139K   /pool0/data3/War_and_Peace.txt
    zfs: 51K    /pool0/data4/War_and_Peace.txt

    zfs: ###### Compression type and ratio #######
    zfs: pool0/data1  compression    lzjb      local
    zfs: pool0/data2  compression    gzip-9    local
    zfs: pool0/data3  compression    zle       local
    zfs: pool0/data4  compression    lz4       local
```

## Then provisioning script for second task:
```
echo "############# Check zfs version #############"
zfs version
wget --no-check-certificate --no-verbose -O file.tar.gz 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
tar -xvf file.tar.gz && cd zpoolexport/
mkdir /otus && zpool import -d ./ otus
echo ""
echo "############# Check sum #############"
zfs get checksum | grep otus
echo ""
echo "############# Size recordsize #############"
zfs get recordsize /otus
echo ""
echo "############# Compression type and ratio #############"
zfs get compression,compressratio | grep otus
echo ""
echo "############# Pool information #############"
zpool status -v otus
echo ""
echo "############# Available space #############"
zpool list otus
```

## Then provisioning script for third task:
```
wget --no-check-certificate --no-verbose -O otus_task3.file 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'
zfs receive otus/task3 < otus_task3.file
echo ""
echo "############## Secret message ##############"
cat $(find /otus/task3/ -name secret_message)
```
