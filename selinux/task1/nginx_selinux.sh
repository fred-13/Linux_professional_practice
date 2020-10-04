#!/bin/bash

yum install epel-release -y
yum install nginx policycoreutils-python -y
systemctl enable nginx.service
systemctl start nginx.service
sed -i 's/80 default_server/8585 default_server/g' /etc/nginx/nginx.conf
setsebool -P httpd_can_network_connect 1
semanage port -a -t http_port_t -p tcp 8585
systemctl restart nginx.service
ss -ntplu | grep 8585
sed -i 's/8585/8181/g' /etc/nginx/nginx.conf
systemctl restart nginx.service
cd /etc/nginx/
grep nginx /var/log/audit/audit.log | grep denied | audit2allow -m nginx_semodule > nginx_semodule.te
grep nginx /var/log/audit/audit.log | grep denied | audit2allow -M nginx_semodule
semodule -i nginx_semodule.pp
systemctl restart nginx.service
ss -ntplu | grep 8181
