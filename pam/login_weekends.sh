#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
groupadd admin
useradd -G admin vasya
echo 12345678 | passwd vasya --stdin
useradd petya
echo 12345678 | passwd petya --stdin
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
chmod +x /etc/pam_script
systemctl restart sshd
