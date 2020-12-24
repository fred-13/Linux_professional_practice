# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.define "flask" do |subconfig|
    subconfig.vm.box = "centos/7"
    subconfig.vm.hostname="flask"
    subconfig.vm.network "forwarded_port", guest: 80, host: 8080
    subconfig.vm.network :private_network, ip: "192.168.13.13"
    config.ssh.forward_agent = true
    subconfig.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yaml"
  end

end
