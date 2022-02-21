#!/bin/bash
# list all the organizations in the local docker mssql
# install sqlcmd first using steps from https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15#ubuntu
# 
# TLDR; version
# curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
# curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
#	sudo apt-get update 
#	sudo apt-get install mssql-tools unixodbc-dev
#	sudo apt-get update 
#	sudo apt-get install mssql-tools
#	Optional: Add /opt/mssql-tools/bin/ to your PATH environment variable in a bash shell.
# export PATH=:$PATH:/opt/mssql-tools/bin


# access local docker mssql
DBUSER='sa'
DBPASS='yourStrong(!)Password'

sqlcmd -Stcp:localhost,1433 -U $DBUSER -P $DBPASS -Q "SELECT OrganizationName, Domain, Id FROM [DataStore.Db.OpenCommunication].[dbo].[OrganizationProfile]" | perl -e '$i=0;while(<>){my($a,$b,$c,@rest)=split(" ",$_); if($i++>1){print "$c $a\t$b\n"} if ($a eq ""){goto end;};}end:'
