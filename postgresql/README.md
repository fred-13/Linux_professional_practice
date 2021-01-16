## PostgreSQL Replication

### Task
Configure replication:
- Configure hot_standby replication using slots
- Configure the correct backup

We send postgresql.conf, pg_hba.conf and recovery.conf for change. As well as the barman config, or the backup script.

### Getting Started
1. Setup environment
    ```bash
    vagrant up
    ```

### Check solution

1. Check streaming
    ```bash
    vagrant ssh backup -c 'sudo barman switch-wal --force --archive master.local'
    ```
    Command output:
    ```
    The WAL file 000000010000000000000003 has been closed on server 'master.local'
    Waiting for the WAL file 000000010000000000000003 from server 'master.local' (max: 30 seconds)
    Processing xlog segments from streaming for master.local
        000000010000000000000003
    Connection to 127.0.0.1 closed.
    ```

1. Check barman configs
    ```bash
    vagrant ssh backup -c 'sudo barman check master.local'
    ```
    Command output:
    ```
    Server master.local:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (no last_backup_maximum_age provided)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 0 backups, expected at least 0)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
    Connection to 127.0.0.1 closed.
    ```

1. Check replication status
    ```bash
    vagrant ssh master
    sudo -H -u postgres sh -c 'psql -c "select usename,application_name,client_addr,backend_start,state,sync_state from pg_stat_replication;"'
    ```
    Command output:
    ```
     usename      |  application_name  | client_addr |         backend_start         |   state   | sync_state
    ------------------+--------------------+-------------+-------------------------------+-----------+------------
    streaming_barman | walreceiver        | 10.0.10.3   | 2021-01-16 11:49:42.752518+00 | streaming | async
    streaming_barman | barman_receive_wal | 10.0.10.4   | 2021-01-16 11:51:03.647834+00 | streaming | async
    (2 rows)
    ```

1. Create test database on master host
    ```bash
    vagrant ssh master
    sudo su postgres
    psql
    CREATE DATABASE "test";
    \c test
    CREATE TABLE users (id serial PRIMARY KEY, name VARCHAR (255) UNIQUE NOT NULL);
    INSERT INTO users (name) values ('john');
    \l test
    ```
    Command output:
    ```
                             List of databases
    Name |  Owner   | Encoding |   Collate   |    Ctype    | Access privileges
    ------+----------+----------+-------------+-------------+-------------------
    test | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    (1 row)
    ```

1. Check database on slave host
    ```bash
    vagrant ssh slave
    sudo -H -u postgres sh -c 'psql -c "\l test"'
    ```
    Command output:
    ```
                             List of databases
    Name |  Owner   | Encoding |   Collate   |    Ctype    | Access privileges
    ------+----------+----------+-------------+-------------+-------------------
    test | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    (1 row)
    ```
