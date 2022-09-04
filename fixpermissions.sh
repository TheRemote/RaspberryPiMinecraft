#!/bin/bash
# Minecraft Server Permissions Fix Script - James A. Chambers - https://jamesachambers.com

# Takes ownership of server files to fix common permission errors such as access denied
# This is very common when restoring backups, moving and editing files, etc.

# If you are using the systemd service (sudo systemctl start minecraft) it performs this automatically for you each startup

# Set path variable
USERPATH="pathvariable"
PathLength=${#USERPATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$USERPATH"
else
    echo "Unable to set path variable.  You likely need to download an updated version of SetupMinecraft.sh from GitHub!"
fi

echo "Taking ownership of all server files/folders in dirname/minecraft..."
sudo chown -R userxname dirname/minecraft
sudo chmod -R 755 dirname/minecraft/*.sh

echo "Complete"