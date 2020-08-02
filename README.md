# Use packer tool create custom image CentOS 7.8 with update kernel:
```
$ cd packer/
$ packer build centos.json
$ vagrant box add --name fred-13/centos-7-5 centos-7.8.2003-kernel-5-x86_64-Minimal.box
```

# Run VM with new image "fred-13/centos-7-5":
```
$ cd ..
$ vagrant up
```

# If it is ok then push this image on Vagrant Cloud:
```
$ vagrant cloud auth login
$ vagrant cloud publish --release fred-13/centos-7-5 1.0 virtualbox packer/centos-7.8.2003-kernel-5-x86_64-Minimal.box
```

# Link for public image on Vagrant Cloud
https://app.vagrantup.com/fred-13/boxes/centos-7-5