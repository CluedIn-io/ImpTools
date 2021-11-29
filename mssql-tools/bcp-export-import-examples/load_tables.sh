#!/bin/bash

# load into load docker db
# make sure you have created the DBNAME first with
# sqlcmd -Stcp:localhost,1433 -U sa -P $CLUEDIN_SQLSERVER_PASS
# 1> CREATE DATABASE [DATA-DB]
# 2> go
DBHOST=localhost
DBUSER=sa
DBPASS='redacted(!)redacted'
DBNAME=DATA-DB

CONNECT="-S $DBHOST -U $DBUSER -P $DBPASS -d $DBNAME"

# make sure these tables already exist... use the fmt2createtablesql.pl to assist
for table in vClaimsBuilding vClaimsPolicy vClaimsBroker vClaimsDriver vClaimsVehicle vClaimsInsured;
do
#	yes "" | bcp $table format nul $CONNECT -f $table.fmt
	bcp $table in $table.dat $CONNECT -f $table.fmt
done

