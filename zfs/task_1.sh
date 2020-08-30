#!/bin/bash

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
