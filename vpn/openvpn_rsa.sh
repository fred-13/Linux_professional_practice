#!/bin/bash

cp -v vagrant_files/Vagrantfile_ras Vagrantfile
vagrant up;

vagrant scp vpnServer:/etc/openvpn/client.key ./openvpn_rsa
vagrant scp vpnServer:/etc/openvpn/client.crt ./openvpn_rsa
vagrant scp vpnServer:/etc/openvpn/ca.crt ./openvpn_rsa
