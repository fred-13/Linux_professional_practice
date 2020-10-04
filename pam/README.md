## Task 1: Deny all users, except for the admin group, login on weekends (Saturday and Sunday), excluding holidays.
## If you run "vagrant up", it will run two private scripts. First script created two users (vasya added in admin group):
```
groupadd admin
useradd -G admin vasya
echo 12345678 | passwd vasya --stdin
useradd petya
echo 12345678 | passwd petya --stdin
```

## Then install the pam_script package and create a script to authorize the admin group on weekends:
```
for pkg in epel-release pam_script;
    do
        yum install -y $pkg;
    done
echo "auth  required  pam_script.so" >> /etc/pam.d/sshd
cat <<'EOF' > /etc/pam_script
#!/bin/bash

if [[ `grep "admin.*$(echo $PAM_USER)" /etc/group | awk -F: '{print $1}' | grep -v 'printadmin'` ]]
  then
    exit 0
  else
    exit 1
fi

EOF
```
## For check the pam_script module run the 'ssh vasya@192.168.50.10' or 'ssh petya@192.168.50.10':
```
$ ssh petya@192.168.50.10
petya@192.168.50.10: Permission denied

    ...

$ ssh vasya@192.168.50.10
vasya@192.168.50.10's password:
Last login: Sun Oct  4 14:23:59 2020 from 192.168.50.1
[vasya@pam ~]$
```

## Task 2: Give a specific user permissions the right to work with docker.
## The second script install docker and added petya user for docker group:
```
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y
systemctl status docker && systemctl enable docker && systemctl start docker
usermod -aG docker petya
```

## This command shows the rights of the user petya with docker:
```
runuser -l petya -c 'docker version'
```
