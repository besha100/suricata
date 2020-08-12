#!/bin/bash
set -euo pipefail

check_root() {
	if [[ $EUID -ne 0 ]]; then
	   echo "[-] This script must be run as root"
	   exit 1
	fi
}

check_update() {

	sudo apt-get -y update
}


install_suricata() {
	
	# install dependencies
	apt-get install dialog apt-utils -y
	sudo apt -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev \
	libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev libjansson4 libjansson-dev pkg-config \
	rustc cargo libnetfilter-queue-dev geoip-bin geoip-database geoipupdate apt-transport-https libnetfilter-queue-dev \
        libnetfilter-queue1 libnfnetlink-dev tcpreplay

	# install with ubuntu package
	sudo add-apt-repository -y ppa:oisf/suricata-stable
	sudo apt -y update
	sudo apt -y install suricata suricata-dbg 
	
	# stop suricata
	#sudo systemctl stop suricata
	sudo /etc/init.d/suricata start

	# config suricata and schedule updating the signature every Monday at 8 AM
	sudo mv /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak
	sudo cp conf/suricata.yaml /etc/suricata/
	sed -i "s/CHANGE-IFACE/eth0/g" /etc/suricata/suricata.yaml
	sudo rm -rf /etc/suricata/rules/*
	sudo cp rules/* /etc/suricata/rules/
	( sudo crontab -l ; sudo echo "00 08 * * 1 sudo suricata-update || true")| sudo crontab - || true
	( sudo crontab -l ; sudo echo "00 09 * * 1 sudo cp /var/lib/suricata/rules/suricata.rules /etc/suricata/rules/ || true")| sudo crontab - || true


	
	# enable suricata at startup
	#sudo systemctl enable suricata

	# start suricata
	#sudo systemctl start suricata
	sudo /etc/init.d/suricata start

}

main() {

	#check root
	check_root

	# update
	check_update

	# install suricata 
	install_suricata	
}

main


