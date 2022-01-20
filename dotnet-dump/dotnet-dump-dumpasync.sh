#!/bin/sh

echo dotnet-dump analyze $1 -c 'dumpasync' \> $1.dumpasync.txt
if [ -f $1.dumpasync.txt ];
then
	echo "."
else
	dotnet-dump analyze $1 -c 'dumpasync' > $1.dumpasync.txt
fi
