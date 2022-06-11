#!/bin/bash
# Author: James A. Chambers - https://jamesachambers.com/
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft
# Calls the latest SetupMinecraft.sh setup script

# Set path variable
USERPATH="pathvariable"
PathLength=${#USERPATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$USERPATH"
else
    echo "Unable to set path variable.  You likely need an updated version of SetupMinecraft.sh from GitHub!"
fi

# Check to make sure we aren't running as root
if [[ $(id -u) = 0 ]]; then
   echo "This script is not meant to run as root or sudo.  Please run as a normal user with ./update.sh.  Exiting..."
   exit 1
fi

curl https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh | bash
