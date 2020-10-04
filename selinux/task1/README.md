## Provision script shows two methods to fix port resolution problem in selinux.
## 1. with the setsebool switch and adding the configurable port to the existing type:
```
sed -i 's/80 default_server/8585 default_server/g' /etc/nginx/nginx.conf
setsebool -P httpd_can_network_connect 1
semanage port -a -t http_port_t -p tcp 8585
systemctl restart nginx.service
ss -ntplu | grep 8585
```
## Example:
```
[root@selinux vagrant]# ss -ntplu | grep 8585
tcp    LISTEN     0      128       *:8585                  *:*                   users:(("nginx",pid=3384,fd=6),("nginx",pid=3383,fd=6))
tcp    LISTEN     0      128    [::]:8585               [::]:*                   users:(("nginx",pid=3384,fd=7),("nginx",pid=3383,fd=7))
```

## 2. with building and installing the SELinux module:
```
sed -i 's/8585/8181/g' /etc/nginx/nginx.conf
systemctl restart nginx.service
cd /etc/nginx/
grep nginx /var/log/audit/audit.log | grep denied | audit2allow -m nginx_semodule > nginx_semodule.te
grep nginx /var/log/audit/audit.log | grep denied | audit2allow -M nginx_semodule
semodule -i nginx_semodule.pp
systemctl restart nginx.service
ss -ntplu | grep 8181
```
## Example:
```
[root@selinux vagrant]# ss -ntplu | grep 8181
tcp    LISTEN     0      128       *:8181                  *:*                   users:(("nginx",pid=3384,fd=6),("nginx",pid=3383,fd=6))
tcp    LISTEN     0      128    [::]:8181               [::]:*                   users:(("nginx",pid=3384,fd=7),("nginx",pid=3383,fd=7))
```
