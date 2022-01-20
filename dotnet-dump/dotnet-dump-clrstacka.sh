#!/bin/sh

echo dotnet-dump analyze $1 -c 'clrstack -a' \> $1.clrstacka.txt
if [ -f $1.clrstacka.txt ];
then
	echo "."
else
	dotnet-dump analyze $1 -c 'clrstack -a' > $1.clrstacka.txt
fi
