#!/usr/bin/env bash

## Disable term blank
setterm -blank 0

## Script dir
SELF=$(pwd)

## Current user
USER=$(whoami);

## Find the dir.
cd ~/
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## Define the release file.
VERSION="bibsdb-v2.0"
URL="https://github.com/bibsdb/bibbox/archive/"
FILE="${VERSION}.tar.gz"

## Define colors.
BOLD=$(tput bold)
UNDERLINE=$(tput sgr 0 1)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

## Check if install has been executed before.
if [ -e $DIR/${DIR}/${VERSION}/ ]
then
		echo "${BOLD}Directory ${UNDERLINE}${RED}${DIR}/${VERSION}${RESET}${BOLD} already exists. Please remove it before running this script${RESET}"
		echo
		echo "rm -fr ${DIR}/${VERSION}"
		echo "rm -rf ~/bibbox"
		echo
		exit
fi

# Set the IP (if static).
function set_ip {
 read -p "Enter IP: " IP
 read -p "Subnet Mask (28): " SUBNET
 read -p "Gateway (172.16.55.1): " GATEWAY
 read -p "DNS 1 (10.150.4.201): " DNS1
 read -p "DNS 2 (10.150.4.202): " DNS2

 SUBNET=${SUBNET:-"28"}
 GATEWAY=${GATEWAY:-"172.16.55.1"}
 DNS1=${DNS1:-"10.150.4.201"}
 DNS2=${DNS2:-"10.150.4.202"}

 echo "network:
    ethernets:
        $1:
            dhcp4: false
            addresses: [${IP}/${SUBNET}]
            routes:
              - to: default
                via: ${GATEWAY}
            nameservers:
              addresses: [${DNS1},${DNS2}]
    version: 2" | sudo tee /etc/netplan/01-bibbox-network.yaml > /dev/null
}

while true; do
    read -p "Do you wish to set static IP (y/n)? " yn
    case $yn in
        [Yy]* )
					echo "${UNDERLINE}${GREEN}Network configuration${RESET}"
					echo "Ethernet adapters normally starts with ${RED}enp${RESET} and wireless ${RED}wlp${RESET}."
					echo "Select the interface to configure:"
					INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | tail -n +2)
					INTERFACES+=' Exit'
					select INTERFACE in ${INTERFACES};
					do
						case ${INTERFACE} in
							'Exit')
								break 2
								;;
							*)
								set_ip ${INTERFACE}
								break 2
								;;
						esac
					done
					break
					;;
        [Nn]* )
					break
					;;
        * ) echo "Please answer yes or no.";;
    esac
done

## Restart network anwait for it to be stable.
echo "${GREEN}Resetting network connections...${RESET}"
sudo netplan apply

## Switch to using resolve.conf from the applied netplan.
sudo unlink /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved.service

## Ensure system is up-to-date.
DEBIAN_FRONTEND=noninteractive
echo "\$nrconf{restart} = 'a';" | sudo tee -a /etc/needrestart/needrestart.conf > /dev/null
sudo apt-get update || exit 1
sudo apt-get upgrade -y || exit 1
sudo apt-get install cloud-init libnetplan0 libudev1 netplan.io udev bash-completion nano iputils-ping -y || exit 1

## Set timezone to "Europe/Copenhagen"
ln -fs /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

## Get NodeJS.
wget -q -O - https://deb.nodesource.com/setup_14.x | sudo bash
sudo apt-get install nodejs -y || exit 1

## Install tools.
sudo apt-get install build-essential libudev-dev openssh-server fail2ban openjdk-8-jdk -y || exit 1

## Install usefull packages.
sudo apt-get install git supervisor redis-server -y || exit 1

## Set udev rule for barcode.
sudo cat << DELIM >> ${DIR}/40-barcode.rules
# Rule for barcode

# 'libusb' device nodes
SUBSYSTEM=="usb", ATTR{idVendor}=="05f9", ATTR{idProduct}=="2206", GROUP="plugdev"

DELIM
sudo mv ${DIR}/40-barcode.rules /etc/udev/rules.d/40-barcode.rules

## Set udev rule for RFID.
sudo cat << DELIM >> ${DIR}/41-rfid.rules
# Rule for Feig Leser
# USB Leser

ACTION!="add", GOTO="feig_rules_end"
SUBSYSTEM!="usb", GOTO="feig_rules_end"

ATTR{product}=="OBID RFID-Reader", ATTR{manufacturer}=="FEIG ELECTRONIC GmbH", MODE:="666", GROUP="users", SYMLINK+="feig_\$ATTR{serial}"
LABEL="feig_rules_end"

DELIM
sudo mv ${DIR}/41-rfid.rules /etc/udev/rules.d/41-rfid.rules

if [ -d "${SELF}/feig" ]; then
	FEIG_DEST="/opt/feig"
	sudo mkdir -p ${FEIG_DEST}
	for file in ${SELF}/feig/lib*.so*
	do
	    sudo cp $file ${FEIG_DEST}
	done

	for file in ${FEIG_DEST}/*
	do
	    libminor=${file%.[0-9]*}
	    libmajor=${libminor%.[0-9]*}
	    libname=${libmajor%.[0-9]*}
	    sudo ln -sf $file $libmajor
	    sudo ln -sf $libmajor $libname
	done
	sudo ldconfig ${FEIG_DEST}
fi

## Add bibbox packages (use symlink to match later update process).
mkdir ${DIR}/${VERSION}/ || exit 1
wget -q ${URL}${FILE} || exit 1
tar -zxf ${FILE} --strip-components=1 -C ${DIR}/${VERSION}/ || exit 1
rm -rf ${FILE}
rm -f bibbox
ln -s ${DIR}/${VERSION}/ bibbox

cp ${SELF}/server.key ${DIR}/bibbox/
cp ${SELF}/server.crt ${DIR}/bibbox/


## Supervisor config
sudo cat << DELIM >> ${DIR}/bibbox.conf
[program:bibbox]
command=/usr/bin/node /home/${USER}/bibbox/bootstrap.js
autostart=true
autorestart=true
environment=NODE_ENV=production
stderr_logfile=/var/log/supervisor/bibbox.err.log
stdout_logfile=/var/log/supervisor/bibbox.out.log
user=root
DELIM

sudo mv ${DIR}/bibbox.conf /etc/supervisor/conf.d/bibbox.conf

# Fix supervisor install bug and ensure that it starts.
sudo systemctl enable supervisor
sudo systemctl start supervisor

## Add printer
sudo apt-get install cups libcups2 libcupsimage2 -y || exit 1
sudo dpkg -i ${SELF}/epson/*.deb || exit 1

tgtDir="/usr/share/ppd"
sudo mkdir -p "${tgtDir}/Epson"
sudo cp -p ${SELF}/epson/ppd/tm-* ${tgtDir}/Epson/
sudo chmod -f 644 ${tgtDir}/Epson/*

sudo lpadmin -p bon -E -v usb://EPSON/TM-m30 -P /usr/share/ppd/Epson/tm-ba-thermal-rastertotmt.ppd
sudo lpadmin -d bon

# Lock down queue to max one job.
sudo sh -c "echo '' >> /etc/cups/cupsd.conf"
sudo sh -c "echo 'MaxJobTime 30' >> /etc/cups/cupsd.conf"
sudo sh -c "echo 'MaxJobs 1' >> /etc/cups/cupsd.conf"
sudo sh -c "sed -i 's/ErrorPolicy .*/ErrorPolicy retry-job/' /etc/cups/cupsd.conf"

# Restart cups
sudo service cups restart

# Add elo touch driver
tgtDir="/etc/opt"
sudo cp -pr ${SELF}/elo ${tgtDir}/elo-usb
cd ${tgtDir}/elo-usb
sudo chmod 777 *
sudo chmod 444 *.txt

# Copy elo udev rules
sudo cp ${tgtDir}/elo-usb/99-elotouch.rules /etc/udev/rules.d

# Copy and enable the elo.service systemd script
sudo cp ${tgtDir}/elo-usb/elo.service /etc/systemd/system/
sudo systemctl enable elo.service

# Add bibbox.sonderborg.dk to /etc/hosts to make reboot button work
sudo sh -c "sed -i '/bibbox.sonderborg.dk/d' /etc/hosts"
sudo sh -c "echo '127.0.0.1  bibbox.sonderborg.dk' >> /etc/hosts"

## Send logs into log server
cat << DELIM >> ${DIR}/10-rsyslog.conf
*.=err   @@10.215.17.150:28778
*.=crit  @@10.215.17.150:28778
*.=alert @@10.215.17.150:28778
*.=emerg @@10.215.17.150:28778
DELIM
sudo mv ${DIR}/10-rsyslog.conf /etc/rsyslog.d/10-rsyslog.conf

## Clean up
rm -rf ${DIR}/{Desktop,Downloads,Documents,Music,Pictures,Public,Templates,Videos,examples.desktop}
sudo apt-get --purge remove avahi-daemon -y || exit 1
sudo apt-get autoremove -y || exit 1

## Restart the show
sudo reboot
