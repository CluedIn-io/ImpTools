# Crashdumping Dotnet Processes from Live Pod

## Enable crashdumping
1. open a root *pod shell* to the node that contains the pod of interest
2. run the contents of [`node_enable_crashdump.sh`](node_enable_crashdump.sh)

## Create crashdumps
1. open  *pod shell* to the pod of interest
2. `ps | less` to grab the command line and `pids` of the dotnet processes
3. note the folder dotnet is running in (most likely `/usr/share/dotnet`)
4. find the `createdump` binary
   1. `find /usr/share/dotnet -name createdump`
   2. Most likely `/usr/share/dotnet/shared/Microsoft.NETCore.App/3.1.21/createdump`
5. run createdump on all the pids
   1. e.g. `/usr/share/dotnet/shared/Microsoft.NETCore.App/3.1.21/createdump -u 9`

## Compress and download coredumps
```bash
/app $ ls -lh /tmp/coredump.*
-rw-------    1 1000     root        2.8G Jan 17 03:15 /tmp/coredump.138
-rw-------    1 1000     root      525.3M Jan 17 03:15 /tmp/coredump.190
-rw-------    1 1000     root      761.9M Jan 17 03:15 /tmp/coredump.9

$ cd /tmp
$ tar cfvzp coredumps.tgz coredump.*
$ md5sum coredumps.tgz
```

Copy using `kubectl cp` to local computer.

## Analyse coredumps
1. download scripts from this github folder to the root folder of your dumps
2. run [docker_run_dotnet_sdk6_alpine.ps1](docker_run_dotnet_sdk6_alpine.ps1) to create docker container
3. `cd /dumps`
4. run contents of [install_dotnet_dump.sh](install_dotnet_dump.sh)
5. run [dump_all.sh](dump_all.sh), or
6. run [dump_all.sh example_dump_folder](dump_all.sh)
7. examine resulting `txt` files for each `coredump.pid` file