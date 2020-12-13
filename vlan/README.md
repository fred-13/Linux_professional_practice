## Task.
### We build bonds and vlans in Office1, a server with additional interfaces and addresses appears on the test subnet in the internal testLAN network
- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1 - 10.10.10.1
- testServer2 - 10.10.10.1
### Bring vlans
- testClient1 <-> testServer1
- testClient2 <-> testServer2
### Between centralRouter and inetRouter "forward" 2 links (common inernal network) and combine them into a bond check work with disabling interfaces
### For surrender - vagrant file of the desired configuration. The configuration should be expanded through ansible.

## Solution.
### When the project is started with the "vagrant up" command, a playbook will be launched to configure the interfaces on the servers and client hosts.
### Checking what happened on the output. Test BOND on severs centralRouter and inetRouter:
```
$ ip a
    ...

3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:0d:15:43 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:e7:88:49 brd ff:ff:ff:ff:ff:ff
5: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:0d:15:43 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe0d:1543/64 scope link
       valid_lft forever preferred_lft forever

$ cat /proc/net/bonding/bond0
    ...

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

    ...

$ ip link set dev eth1 down
$ ip a
    ...

3: eth1: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master bond0 state DOWN group default qlen 1000
    link/ether 08:00:27:0d:15:43 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:e7:88:49 brd ff:ff:ff:ff:ff:ff
5: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:e7:88:49 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe0d:1543/64 scope link
       valid_lft forever preferred_lft forever

$ cat /proc/net/bonding/bond0
    ...

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

    ...
```

### Checking the availability of the channel from the centralRouter server to inetRouter at this moment:
```
$ ping -c 30 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
64 bytes from 192.168.255.1: icmp_seq=1 ttl=64 time=1.57 ms
64 bytes from 192.168.255.1: icmp_seq=2 ttl=64 time=1.66 ms
64 bytes from 192.168.255.1: icmp_seq=3 ttl=64 time=1.78 ms
64 bytes from 192.168.255.1: icmp_seq=4 ttl=64 time=1.80 ms
64 bytes from 192.168.255.1: icmp_seq=5 ttl=64 time=1.65 ms
64 bytes from 192.168.255.1: icmp_seq=6 ttl=64 time=1.79 ms
64 bytes from 192.168.255.1: icmp_seq=7 ttl=64 time=1.77 ms
64 bytes from 192.168.255.1: icmp_seq=8 ttl=64 time=1.84 ms
64 bytes from 192.168.255.1: icmp_seq=9 ttl=64 time=1.86 ms
64 bytes from 192.168.255.1: icmp_seq=10 ttl=64 time=1.83 ms
64 bytes from 192.168.255.1: icmp_seq=11 ttl=64 time=1.75 ms
64 bytes from 192.168.255.1: icmp_seq=12 ttl=64 time=1.60 ms
64 bytes from 192.168.255.1: icmp_seq=13 ttl=64 time=1.84 ms
64 bytes from 192.168.255.1: icmp_seq=14 ttl=64 time=1.72 ms
64 bytes from 192.168.255.1: icmp_seq=15 ttl=64 time=1.53 ms
64 bytes from 192.168.255.1: icmp_seq=16 ttl=64 time=1.64 ms
64 bytes from 192.168.255.1: icmp_seq=17 ttl=64 time=1.80 ms
64 bytes from 192.168.255.1: icmp_seq=18 ttl=64 time=1.80 ms
64 bytes from 192.168.255.1: icmp_seq=19 ttl=64 time=1.75 ms
64 bytes from 192.168.255.1: icmp_seq=20 ttl=64 time=1.75 ms
64 bytes from 192.168.255.1: icmp_seq=21 ttl=64 time=1.58 ms
64 bytes from 192.168.255.1: icmp_seq=22 ttl=64 time=1.75 ms
64 bytes from 192.168.255.1: icmp_seq=23 ttl=64 time=1.73 ms
64 bytes from 192.168.255.1: icmp_seq=24 ttl=64 time=1.69 ms
64 bytes from 192.168.255.1: icmp_seq=25 ttl=64 time=1.67 ms
64 bytes from 192.168.255.1: icmp_seq=26 ttl=64 time=1.75 ms
64 bytes from 192.168.255.1: icmp_seq=27 ttl=64 time=1.67 ms
64 bytes from 192.168.255.1: icmp_seq=28 ttl=64 time=1.73 ms
64 bytes from 192.168.255.1: icmp_seq=29 ttl=64 time=1.68 ms
64 bytes from 192.168.255.1: icmp_seq=30 ttl=64 time=1.93 ms

--- 192.168.255.1 ping statistics ---
30 packets transmitted, 30 received, 0% packet loss, time 29069ms
rtt min/avg/max/mdev = 1.538/1.735/1.932/0.093 ms
```
