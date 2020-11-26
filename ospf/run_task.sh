#!/bin/bash

sed -ir 's!".\/playbooks\/.*.yml"!"./playbooks/'$1'.yml"!g' Vagrantfile
vagrant up --provision
