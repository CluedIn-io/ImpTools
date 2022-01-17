#!/bin/bash

# purpose: simple script for managing common CluedIn functions with Docker Desktop on Ubuntu
# Nov 2021 - tested with 20.04.3 LTS (Focal Fossa) in Azure on a F16s_v2 preferred (D8s_v3 also works but not as well) VM using Ubuntu Server 20.04 LTS - Gen1
# author: rha@cluedin.com
# version: 0.2

function menu()
{
	clear
	echo "--- CluedIn Ghetto Management Script ---"
	echo
	echo "s - status"
	echo "r - restart all docker containers"
	echo "x - stop - stop in current state"
	echo "X - start - opposite of stop"
	echo "u - up - start and ensuring changed containers are created"
	echo "w - wipe i.e. tear DOWN cluster and bring it back UP"
	echo "d - wipe/down i.e. tear DOWN cluster"
	#echo "c - create new org and admin user"
	echo "q - to quit"
}

function anykey()
{
	echo
	read -p '<press enter to continue>' blah
}

pushd .

tag=325
cd /home/azureuser/Home

while [ true ]
do
	menu
	read -p '> ' cmd
	case $cmd in
	"s")
		sudo pwsh ./cluedin.ps1 status
	;;
	"r")
		sudo pwsh ./cluedin.ps1 stop $tag
		sudo pwsh ./cluedin.ps1 up $tag
	;;
	"x")
		sudo pwsh ./cluedin.ps1 stop $tag
	;;
	"X")
		sudo pwsh ./cluedin.ps1 start $tag
		echo
		echo "(ignore installer failure - this is normal)"
	;;
	"u")
		sudo pwsh ./cluedin.ps1 up $tag
	;;
	"w")
		sudo pwsh ./cluedin.ps1 down $tag
		sudo pwsh ./cluedin.ps1 up $tag
	;;
	"d")
		sudo pwsh ./cluedin.ps1 down $tag
	;;
#	"c")
#		echo "If you really want this feature let Rudi know..."
#	;;
	"q")
		break
	;;
	esac
	anykey
done

popd
