#!/bin/bash

wget --no-check-certificate --no-verbose -O otus_task3.file 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'
zfs receive otus/task3 < otus_task3.file
echo ""
echo "############## Secret message ##############"
cat $(find /otus/task3/ -name secret_message)
