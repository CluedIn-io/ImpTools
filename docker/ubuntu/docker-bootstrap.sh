#!/usr/bin/bash

# install docker on ubuntu for CluedIn purposes
# tested with 20.04.3 LTS (Focal Fossa) in Azure on a D8s_v3 VM using Ubuntu Server 20.04 LTS - Gen1
# rha@cluedin.com Nov 2021

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

cd /root

if [ -f /usr/sbin/ifconfig ]; then
	echo net-tools already installed
else
	apt install net-tools
fi

echo

if [ -f /usr/bin/docker ]; then
	echo docker already installed
	echo `docker --version`
else
	# https://docs.docker.com/engine/install/ubuntu/
	apt-get update
	apt-get install \
		ca-certificates \
		curl \
		gnupg \
		lsb-release

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	apt-get update
	apt-get install docker-ce docker-ce-cli containerd.io
	docker run hello-world
	docker --version
fi

echo

if [ -f /usr/local/bin/docker-compose ]; then
	echo docker-compose already installed
	echo `docker-compose --version`
else
	# https://docs.docker.com/compose/install/
	curl -L"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"-o/usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	docker-compose --version
fi

echo

if [ -f /usr/bin/pwsh ]; then
	echo powershell already installed
	echo `pwsh --version`
else
	# https://docs.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.1
	echo installing powershell
	wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/powershell_7.1.5-1.ubuntu.20.04_amd64.deb
	dpkg -i powershell_7.1.5-1.ubuntu.20.04_amd64.deb
	pwsh --version
fi

echo finished!!!
