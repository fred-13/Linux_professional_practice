
## Moving nginx.spec file for custom build nginx package:
```
config.vm.provision "file", source: "./nginx.spec", destination: "$HOME/nginx.spec"
```
## Provisioning script rpm_create.sh.
## installing dependencies:
```
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc openssl-devel zlib-devel pcre-devel
```
## Download the SRPM package NGINX and install:
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm;
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```
## Download and unzip the latest source for openssl:
```
wget https://www.openssl.org/source/latest.tar.gz;
tar -xvf latest.tar.gz
```
## Install dependencies:
```
yum-builddep /root/rpmbuild/SPECS/nginx.spec
```
## Modify spec file and start building RPM package:
```
mv -r nginx.spec /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec;
```
## Install package nginx and start:
```
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm;
systemctl start nginx
systemctl status nginx
```
## Create your repository and place Nginx, Percona packages there:
```
mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/
```
## Set up Nginx for new repository and check:
```
cat > /etc/nginx/conf.d/default.conf << EOF
server {
    listen       80;
    server_name  _;

    location / {
	    autoindex on;
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;

    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
nginx -s reload
curl -a http://localhost/repo/
```
## Test this repository (install percona from it):
```
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
yum list | grep otus
yum repolist enabled | grep otus
yum install percona-release -y
```
## To get to the repository open this link:
## [http://localhost:8888/repo/](http://localhost:8888/repo/)
