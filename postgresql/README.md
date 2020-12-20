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

1. Check barman configs
    ```bash
    vagrant ssh backup -c 'sudo barman check master.local'
    ```

1. Create test database
    ```bash
    vagrant ssh master
    sudo su postgres
    psql
    CREATE DATABASE "test";
    \c test
    CREATE TABLE users (id serial PRIMARY KEY, name VARCHAR (255) UNIQUE NOT NULL);
    INSERT INTO users (name) values ('john');
    ```
