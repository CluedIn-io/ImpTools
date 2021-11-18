#!/bin/bash

# simple script for managing common CluedIn functions
# tested with 20.04.3 LTS (Focal Fossa) in Azure on a D8s_v3 VM using Ubuntu Server 20.04 LTS - Gen1
# rha@cluedin.com Nov 2021

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
	echo "q - to quit"
}

function anykey()
{
	echo
	read -p '<press enter to continue>' blah
}

pushd .

tag=325beta
cd /home/azureuser/Home-Dev/src

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
	"q")
		break
	;;
	esac
	anykey
done

popd
