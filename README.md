### sqlserver-migrations

## 1. Introduction

The **sqlserver-migrations** is a usefull tool to manage scripts of upgrade and downgrades on SQLServer databases.


### 2. Documentation

### 2.1. Use Case Diagram

* `under construction`

### 2.2. Deployment Diagram

* `under construction`

### 2.3. BPMN Diagram

* `under construction`

### 2.4. Pre-requisites

* **SQLCMD** SQLServer command line tool installed and on machine path
* **POWERSHELL** Windows Powershell

### 2.5. Tutorial

#### Getting command-line help

```bat
C:\..\sqlserver-migrations\src\powershell> powershell -File sqlserver-migrations.ps1 -h
sqlserver-migrations - v.2020.05.17.0125 - SQLServer Database Management Tool for upgrades and downgrades scripts
usage: sqlserver-migrations ( [ -h | help ] | [ -l | list ] | [ -u | upgrade ] | [ -d | downgrade ] | [ -s | setup ] | [ -i | install ] ) [ --cmd-args ] [ cmd-params ]

       -h help      Show usefull command line help
       -l list      List command arguments and parameters
                    --upgrade   List only upgrade scripts
                    --downgrade List only downgrade scripts
                    --setup     List only setup configuration values
       -u upgrade   Upgrade script's executions
       -d downgrade Downgrade script's executions
       -s setup     Setup current installation key/values with arguments and parameters
                    <key>     Key to setup
                    <value>   Value to setup
       -i install   Initialize setup configuration repository
```


#### Installing and configure ready to use

* Install configurations setup key/values

```bat
C:\..\sqlserver-migrations\src\powershell> powershell -File sqlserver-migrations.ps1 install
sqlserver-migrations - v.2020.05.17.0125 - SQLServer Database Management Tool for upgrades and downgrades scripts

SUCCESS: sqlserver-migrations installed!

```

* List configurations setup key/values

```bat
C:\..\sqlserver-migrations\src\powershell> powershell -file sqlserver-migrations.ps1 list --setup
sqlserver-migrations - v.2020.05.17.0125 - SQLServer Database Management Tool for upgrades and downgrades scripts

key             value
--------------- --------------------------------------------------
sqlcmdPath
servername      localhost
protocol        
port
login           user
password        password123
database        master
prefixUpgrade   upgrade-
prefixDowngrade downgrade-
```

* Create your first upgrade script (.sql)

```bat
ECHO CREATE TABLE tmp_sqlserver_migrations_demo ( a int ) >  upgrade-demo-01.sql
ECHO GO >> upgrade-demo-01.sql
```

* Create your second upgrade script (.sql)

```bat
ECHO DROP TABLE tmp_sqlserver_migrations_demo >  upgrade-demo-02.sql
ECHO GO >> upgrade-demo-02.sql
```

* Upgrade your environment
  * `sqlserver-migrations` runs all script prefixed with configuration `prefixUpgrade` order by name

```bat
C:\..\sqlserver-migrations\src\powershell> powershell -file sqlserver-migrations.ps1 upgrade
sqlserver-migrations - v.2020.05.17.0213 - SQLServer Database Management Tool for upgrades and downgrades scripts
```

* Now, let's analyze, script's, repository
  * sub-folder `.sqlserver-migrations` was created by `sqlserver-migrations` for repository
  * file   `sqlserver-migrations.ps1` is powershell script
  * file   `.\sqlserver-migrations\config-key-value.csv` contains setup configuration information
  * file(s) `upgrade-demo-01.sql` and `upgrade-demo-02.sql` are your upgrades scripts
  * file(s) `upgrade-demo-01.log` and `upgrade-demo-02.log` in sub-folder `.sqlserver-migrations` were created by `sqlserver-migrations` during upgrade and will be always overwritten with contents of last execution

```bat
C:\..\sqlserver-migrations\src\powershell> dir /s
Pasta de C:\GitHome\ws-github-01\sqlserver-migrations\src\powershell

17/05/2020  02:24    <DIR>          .
17/05/2020  02:24    <DIR>          ..
17/05/2020  02:08    <DIR>          .sqlserver-migrations
17/05/2020  02:16            13.534 sqlserver-migrations.ps1
17/05/2020  02:24                60 upgrade-demo-01.sql
17/05/2020  02:24                48 upgrade-demo-02.sql
               3 arquivo(s)         13.642 bytes

Pasta de C:\GitHome\ws-github-01\sqlserver-migrations\src\powershell\.sqlserver-migrations

17/05/2020  02:08    <DIR>          .
17/05/2020  02:08    <DIR>          ..
17/05/2020  02:20               402 config-key-value.csv
17/05/2020  02:50               128 upgrade-demo-01.log
17/05/2020  02:50               241 upgrade-demo-02.log
               3 arquivo(s)            402 bytes
```


## 3. Project

### 3.1. End User's Guide

* Clone `master` branch
* Read Tutorial section

### 3.2. Developer's Guide

* Clone `develop` branch if available, otherwise use `master` branch
* Read Tutorial section

### 3.3. Administrator's Guide

* Clone `develop` branch if available, otherwise use `master` branch
* Read Tutorial section



## I - References ##

* https://rollout.io/blog/database-migration/
