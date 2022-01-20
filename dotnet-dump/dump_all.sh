#!/bin/sh

# first arg is the location of the crashdumps to recursively scan

find $1 -name coredump.? -exec ./dotnet-dump-clrstack.sh {} \;
find $1 -name coredump.?? -exec ./dotnet-dump-clrstack.sh {} \;
find $1 -name coredump.??? -exec ./dotnet-dump-clrstack.sh {} \;

find $1 -name coredump.? -exec ./dotnet-dump-clrstacka.sh {} \;
find $1 -name coredump.?? -exec ./dotnet-dump-clrstacka.sh {} \;
find $1 -name coredump.??? -exec ./dotnet-dump-clrstacka.sh {} \;

find $1 -name coredump.? -exec ./dotnet-dump-dumpasync.sh {} \;
find $1 -name coredump.?? -exec ./dotnet-dump-dumpasync.sh {} \;
find $1 -name coredump.??? -exec ./dotnet-dump-dumpasync.sh {} \;
