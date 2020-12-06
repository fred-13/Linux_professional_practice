#!/bin/bash

if [[ $1 == up ]]
    then
        cp -v vagrant_files/Vagrantfile_tuntap Vagrantfile
        vagrant up
    elif [[ $1 == test ]]
        then
            cp -v vagrant_files/Vagrantfile_tuntap_test Vagrantfile
            vagrant up --provision
fi
