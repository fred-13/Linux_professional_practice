# Vagrant DNS Lab

A Bind's DNS lab with Vagrant and Ansible, based on CentOS 7.

# Playground

<code>
    vagrant ssh client
</code>

  * zones: dns.lab, reverse dns.lab and ddns.lab
  * ns01 (192.168.50.10)
    * master, recursive, allows update to ddns.lab
  * ns02 (192.168.50.11)
    * slave, recursive
  * client (192.168.50.15)
    * used to test the env, runs rndc and nsupdate
  * zone transfer: TSIG key


## Task
### Configure split-dns. Take a booth https://github.com/erlong15/vagrant-bind. Add another server client2. Create in the dns.lab zone names web1 - looks at client1 web2 looks at client2. Create another zone newdns.lab make a record in it www - looks at both clients. Configure split-dns: client1 - sees both zones, but only web1 in the dns.lab zone. Client2 only sees dns.lab.

## Check Solution
### Run the command "vagrant up", then go to host "client1" to check the dns permission of client1 / client2:
```
$ vagrant up
$ vagrant ssh client1

$ dig web1.dns.lab
$ dig web2.dns.lab
$ dig www.newdns.lab
$ dig -x 192.168.50.16
$ dig @192.168.50.11 web1.dns.lab
$ dig @192.168.50.11 web2.dns.lab
$ dig @192.168.50.11 www.newdns.lab
$ dig @192.168.50.11 -x 192.168.50.16
```
