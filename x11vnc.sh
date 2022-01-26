#! /bin/bash

# Function to validate every step in the script. In case of a faulure the script will be terminated.

function validate_process {
	

	if [ $? -eq 0 ]; then
	    printf "${GREEN}Done${NC}\n"
	    sleep 1
	else
	    printf "${RED}Failed! \nTerminating...${NC}\n" 
	    sleep 2
	    exit
	fi


}

# Set output colors

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # no color

# Update Ubuntu local repositories

printf "${YELLOW}Updating local repositories...${NC}\n"
sleep 2
apt update
validate_process

# Install lightdm and set lightdm as the default X server

printf "${YELLOW}Installing lightdm and setting as default display manager...${NC}\n"
sleep 2
DEBIAN_FRONTEND=noninteractive apt install -y -q lightdm
validate_process
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate


# Install x11vnc
printf "${YELLOW}Installing x11vnc...${NC}\n"
sleep 2
apt install -y x11vnc
validate_process

# Set x11vnc password to asdasd
printf "${YELLOW}Setting x11vnc password to asdasd${NC}\n"
sleep 2
x11vnc -storepasswd "asdasd" /etc/x11vnc.pass
validate_process

# Create x11vnc.service
printf "${YELLOW}Creating x11vnc.service...${NC}\n"
sleep 2
cat > /lib/systemd/system/x11vnc.service << EOF
# Description: Custom Service Unit file
# File: /lib/systemd/system/x11vnc.service
[Unit]
Description="x11vnc"
Requires=display-manager.service
After=display-manager.service

[Service]
ExecStart=/usr/bin/x11vnc -loop -nopw -xkb -repeat -noxrecord -noxfixes -noxdamage -forever -rfbauth /etc/x11vnc.pass -rfbport 5900 -display :0 -auth guess
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
Restart-sec=2

[Install]
WantedBy=multi-user.target
EOF
validate_process

# Enable x11vnc service
printf "${YELLOW}Enabling x11vnc.service...${NC}\n"
sleep 2 
systemctl enable x11vnc.service
validate_process




# Prompt user before a reboot

read -p "A reboot is required, please press 'y' to reboot: " UserInput

if [ "$UserInput" == "y" ] || ["$UserInput" == "Y" ]; then
       	printf "${YELLOW}Rebooting..."
	sleep 2 
       	reboot
else
        printf "${YELLOW}Script executed succesfully, Reboot later for changes to be applied.${NC}\n"
	sleep 2
        exit
fi
