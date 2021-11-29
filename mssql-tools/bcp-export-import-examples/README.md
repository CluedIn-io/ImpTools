# BCP Export/Import Examples

## Purpose
These scripts were developed on ubuntu in order to extract the first 1000 rows from a large dataset and load it into the local sqlserver in docker desktop.

## Background
The firewalls to access the Azure Database was only to 2 ubuntu VMs in Azure, we couldn't access the db from anywhere else. It was handy to be able to perform all these operations on the ubuntu VM - more repeatable and useful for future examples.

## Setup
Install the mssql-tools in ubuntu.

As of Nov 2021

Follow the instructions here:

https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15#ubuntu

i.e.:
```
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

sudo apt-get update 
sudo apt-get install mssql-tools unixodbc-dev

sudo apt-get update 
sudo apt-get install mssql-tools

# Optional: Add /opt/mssql-tools/bin/ to your PATH environment variable in a bash shell.
export PATH=:$PATH:/opt/mssql-tools/bin

# this is the path
azureuser@UbuntuCluedInAPACDemo:~$ ls -l /opt/mssql-tools/bin/sqlcmd
-rwxr-xr-x 1 root root 417848 Jun 26 10:33 /opt/mssql-tools/bin/sqlcmd
```

# Examples
# Sqlcmd Example

```
azureuser@UbuntuCluedInAPACDemo:~$ /opt/mssql-tools/bin/sqlcmd -H localhost -U sa
Password:
1>

https://www.sqlshack.com/working-sql-server-command-line-sqlcmd/

1> sp_databases
2> go
DATABASE_NAME               DATABASE_SIZE REMARKS                                                            
-------------------------------------------------
DataStore.Db.AuditLog               16384 NULL
DataStore.Db.Authentication         16384 NULL
DataStore.Db.BlobStorage           147456 NULL
DataStore.Db.Configuration          16384 NULL
DataStore.Db.ExternalSearch         16384 NULL
DataStore.Db.Metrics                81920 NULL
DataStore.Db.MicroServices          16384 NULL
DataStore.Db.OpenCommunication      16384 NULL
DataStore.Db.TokenStore             16384 NULL
DataStore.Db.Training               16384 NULL
DataStore.Db.WebApp                 16384 NULL
master                               6144 NULL
model                               16384 NULL
msdb                                14528 NULL
tempdb                              16384 NULL      
```

## Create Fmt File Example
```
yes "" | bcp vClaimsVehicle format -D -S example.database.windows.net -U sqladmin -P redacted -d DATADB -f vClaimsVehicle.fmt
```

## Dump Data
```
bcp vClaimsVehicle out vClaimsVehicle.dat -F 1 -L 1000 -S example.database.windows.net -U sqladmin -P redacted -d DATADB -f vClaimsVehicle.fmt
```

## Connect to local docker database example

```
azureuser@UbuntuCluedInAPACDemo2:~/DATA-DB$ grep PASS ~/Home-Dev/src/env/325/.env
CLUEDIN_EMAIL_PASS=
CLUEDIN_RABBITMQ_PASSWORD=
CLUEDIN_SQLSERVER_PASS=redacted(!)redacted

azureuser@UbuntuCluedInAPACDemo2:~/DATA-DB$ sudo docker ps | grep sql
3e2f9a73f7b6   cluedin/sqlserver:release-3.2.5                       "sh -c /init/init.sh"    6 days ago   Up 3 days             0.0.0.0:1433->1433/tcp, :::1433->1433/tcp                                                                                                                                                                            cluedin_325_c87357d5_sqlserver_1

export CLUEDIN_SQLSERVER_PASS='redacted(!)redacted
azureuser@UbuntuCluedInAPACDemo2:~/DATA-DB$ sqlcmd -Stcp:localhost,1433 -U sa -P $CLUEDIN_SQLSERVER_PASS
1>

# list all databases
1> sp_databases
2> go

# create db DATA-DB
1> CREATE DATABASE [DATA-DB]
2> go
```

## Convert all Fmt files Sql
```
azureuser@UbuntuCluedInAPACDemo2:~/DATA-DB$ for file in `ls *.fmt`; do perl fmt2createtablesql.pl $file > $file.sql ; done
```

## Execute Sql to Create Tables
```
azureuser@UbuntuCluedInAPACDemo2:~/DATA-DB$ for file in `ls *.sql`; do sqlcmd -Stcp:localhost,1433 -U sa -P $CLUEDIN_SQLSERVER_PASS -d DATA-DB -i $file ; done
```

## Copy From One Database to Another using BCP
Modify variables in scripts to suit - e.g. source is external azure database, destination is local docker desktop database

1. `./list_tables.sh`
2. `./dump_tables.sh`
3. `for file in `ls *.fmt`; do perl fmt2createtablesql.pl $file > $file.sql ; done`
4. `./load_tables.sh`
   