#!/bin/bash

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker
systemctl start docker
usermod -aG docker petya
runuser -l petya -c 'docker version'
echo 'petya ALL=(ALL) NOPASSWD: /bin/systemctl restart docker.service' >> /etc/sudoers
sleep 5
echo 'Petya restarted Docker Service:'
echo '----------------------------------------------------------------------'
sudo -H -u petya bash -c 'sudo systemctl restart docker.service && systemctl status docker.service | grep ago'
echo '----------------------------------------------------------------------'
