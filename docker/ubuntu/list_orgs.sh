#!/bin/bash

# access local docker mssql
DBUSER='sa'
DBPASS='yourStrong(!)Password'

sqlcmd -Stcp:localhost,1433 -U $DBUSER -P $DBPASS -Q "SELECT OrganizationName, Domain, Id FROM [DataStore.Db.OpenCommunication].[dbo].[OrganizationProfile]" | perl -e '$i=0;while(<>){my($a,$b,$c,@rest)=split(" ",$_); if($i++>1){print "$c $a\t$b\n"} if ($a eq ""){goto end;};}end:'
