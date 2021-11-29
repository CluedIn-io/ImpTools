#!/bin/bash

DBHOST=example.database.windows.net
DBUSER=sqladmin
DBPASS=redacted
DBNAME=EXAMPLEDB

CONNECT="-S $DBHOST -U $DBUSER -P $DBPASS -d $DBNAME"

# dump all the tables of interest
for table in vClaimsBuilding vClaimsPolicy vClaimsBroker vClaimsDriver vClaimsVehicle vClaimsInsured;
do
	# create format file
	yes "" | bcp $table format nul $CONNECT -f $table.fmt

	# dump table
	# -F for first row number
	# -L for last row number
	# i.e. 1000 rows
	bcp $table out $table.dat -F 1 -L 1000 $CONNECT -f $table.fmt
done

