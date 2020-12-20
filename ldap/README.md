
## Tasks
```
1.   Install FreeIPA. (+)
2.   Write Ansible playbook for client configuration. (+)
3*.  Configure SSH key authentication. (-)
4**. Firewall must be enabled on the server and client. (-)
```

## Solution
### Init server and client:
```
$ vagrant up
```

### Create ldap user:
```
$ vagrant ssh ipaserver -c 'echo password | kinit admin && ipa user-add --first="Ivan" --last="Ivanov" --cn="Ivan Ivanov" --password ivanov --shell="/bin/bash"'

Password for admin@HOME.LOCAL:
Password:
Enter Password again to verify:

  -------------------
  Added user "ivanov"
  -------------------
    User login: ivanov
    First name: Ivan
    Last name: Ivanov
    Full name: Ivan Ivanov
    Display name: Ivan Ivanov
    Initials: II
    Home directory: /home/ivanov
    GECOS: Ivan Ivanov
    Login shell: /bin/bash
    Principal name: ivanov@HOME.LOCAL
    Principal alias: ivanov@HOME.LOCAL
    User password expiration: 20201220101101Z
    Email address: ivanov@home.local
    UID: 1896000001
    GID: 1896000001
    Password: True
    Member of groups: ipausers
    Kerberos keys available: True

Connection to 127.0.0.1 closed.
```

### Check login:
```
$ vagrant ssh client -c 'su -l ivanov'

Password:
Password expired. Change your password now.
Current Password:
New password:
Retype new password:
Creating home directory for ivanov.

[ivanov@client ~] $
```
