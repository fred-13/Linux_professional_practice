## Task 1. Raise vpn between the two virtual machines in tun and tap modes. Experience the difference.

### So that raise vpn between four virtual machines in modes tun and tap run this command:
```
$ ./taptun.sh up
```
### Then privision ansible playbook for all hosts: disabled SeLinux, installs openvpn and iperf, coped config files, run systemd services.

### For the order to check the difference between these two modes run next command:
```
$ ./taptun.sh test
```
### after which you should get the following at the output:
```
    ...

    tapClient: --------------------------------
    tapClient: Testing connect to tapServer
    tapClient: --------------------------------
    tapClient: PING 10.1.1.1 (10.1.1.1) 56(84) bytes of data.
    tapClient: 64 bytes from 10.1.1.1: icmp_seq=1 ttl=64 time=1.15 ms
    tapClient: 64 bytes from 10.1.1.1: icmp_seq=2 ttl=64 time=2.60 ms
    tapClient: 64 bytes from 10.1.1.1: icmp_seq=3 ttl=64 time=2.56 ms
    tapClient: 64 bytes from 10.1.1.1: icmp_seq=4 ttl=64 time=2.20 ms
    tapClient: 64 bytes from 10.1.1.1: icmp_seq=5 ttl=64 time=2.58 ms
    tapClient:
    tapClient: --- 10.1.1.1 ping statistics ---
    tapClient: 5 packets transmitted, 5 received, 0% packet loss, time 4008ms
    tapClient: rtt min/avg/max/mdev = 1.154/2.222/2.607/0.555 ms
    tapClient: --------------------------------
    tapClient: Speed testing on tap interface
    tapClient: --------------------------------
    tapClient: ------------------------------------------------------------
    tapClient: Client connecting to 10.1.1.1, TCP port 5001
    tapClient: TCP window size:  126 KByte (default)
    tapClient: ------------------------------------------------------------
    tapClient: [  3] local 10.1.1.2 port 59278 connected with 10.1.1.1 port 5001
    tapClient: [ ID] Interval       Transfer     Bandwidth
    tapClient: [  3]  0.0- 5.0 sec   176 MBytes   296 Mbits/sec
    tapClient: [  3]  5.0-10.0 sec   165 MBytes   277 Mbits/sec
    tapClient: [  3] 10.0-15.0 sec   166 MBytes   279 Mbits/sec
    tapClient: [  3] 15.0-20.0 sec   168 MBytes   282 Mbits/sec
    tapClient: [  3]  0.0-20.0 sec   676 MBytes   284 Mbits/sec
    tapClient: --------------------------------

    ...

    tunClient: --------------------------------
    tunClient: Testing connect to tunServer
    tunClient: --------------------------------
    tunClient: PING 10.2.2.1 (10.2.2.1) 56(84) bytes of data.
    tunClient: 64 bytes from 10.2.2.1: icmp_seq=1 ttl=64 time=0.771 ms
    tunClient: 64 bytes from 10.2.2.1: icmp_seq=2 ttl=64 time=2.66 ms
    tunClient: 64 bytes from 10.2.2.1: icmp_seq=3 ttl=64 time=2.56 ms
    tunClient: 64 bytes from 10.2.2.1: icmp_seq=4 ttl=64 time=2.53 ms
    tunClient: 64 bytes from 10.2.2.1: icmp_seq=5 ttl=64 time=2.56 ms
    tunClient:
    tunClient: --- 10.2.2.1 ping statistics ---
    tunClient: 5 packets transmitted, 5 received, 0% packet loss, time 4009ms
    tunClient: rtt min/avg/max/mdev = 0.771/2.219/2.666/0.728 ms
    tunClient: --------------------------------
    tunClient: Speed testing on tap interface
    tunClient: --------------------------------
    tunClient: ------------------------------------------------------------
    tunClient: Client connecting to 10.2.2.1, TCP port 5001
    tunClient: TCP window size: 94.5 KByte (default)
    tunClient: ------------------------------------------------------------
    tunClient: [  3] local 10.2.2.2 port 52026 connected with 10.2.2.1 port 5001
    tunClient: [ ID] Interval       Transfer     Bandwidth
    tunClient: [  3]  0.0- 5.0 sec   170 MBytes   284 Mbits/sec
    tunClient: [  3]  5.0-10.0 sec   171 MBytes   286 Mbits/sec
    tunClient: [  3] 10.0-15.0 sec   172 MBytes   289 Mbits/sec
    tunClient: [  3] 15.0-20.0 sec   168 MBytes   283 Mbits/sec
    tunClient: [  3]  0.0-20.0 sec   681 MBytes   286 Mbits/sec
    tunClient: --------------------------------

    ...
```
### as a result of testing, it turns out that the transmission speed on tun is higher than on tap. Please don't forget to delete the project:
```
$ vagrant destroy -f
```

## Task 2. Raise RAS based on OpenVPN with client certificates, connect from the local machine to the virtual machine.

### NOTE!!! First install the scp plugin in your vagrant with the following command:
```
vagrant plugin install vagrant-scp
```
### this is necessary for automatic collection of client certificates.

### Then run next command for up OpenVPN Server:
```
$ ./openvpn_rsa.sh
```
### During startup, vagrant will ask you to select an interface for the bridge. Select the required:
```
    ...
==> vpnServer: Available bridged network interfaces:
1) wlo1
2) virbr0
3) docker0
==> vpnServer: When choosing an interface, it is usually the one that is
==> vpnServer: being used to connect to the internet.
==> vpnServer:
    vpnServer: Which interface should the network bridge to? 1
    ...
```

### Then take configuration file (client.conf) and certificates (client.key, client.crt, ca.crt) from openvpn_rsa dir. And import configuration file in your host. Replace {{ IP REMOTE SERVER }} with your ip from the server.

### After running the OpenVPN client on your host, you should get the following on verification:
```
$ ping -c 5 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=2.09 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=2.14 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=2.26 ms
64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=1.95 ms
64 bytes from 10.10.10.1: icmp_seq=5 ttl=64 time=2.47 ms

--- 10.10.10.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4005ms
rtt min/avg/max/mdev = 1.945/2.179/2.471/0.176 ms

$ ssh vagrant@10.10.10.1
The authenticity of host '10.10.10.1 (10.10.10.1)' can't be established.
ECDSA key fingerprint is SHA256:BfpBnmH4kULg6pVI47bxTj26ahOl6hGGdJuPgmKNOZQ.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.10.1' (ECDSA) to the list of known hosts.
vagrant@10.10.10.1's password:
Last login: Sun Dec  6 15:18:42 2020 from 10.0.2.2
[vagrant@vpnServer ~]$ exit
logout
Connection to 10.10.10.1 closed.
```
