#!/bin/sh

echo dotnet-dump analyze $1 -c 'clrstack' \> $1.clrstack.txt
if [ -f $1.clrstack.txt ];
then
	echo "."
else
	dotnet-dump analyze $1 -c 'clrstack' > $1.clrstack.txt
fi
