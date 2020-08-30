#!/bin/bash

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
