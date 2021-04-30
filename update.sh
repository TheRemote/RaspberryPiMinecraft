#!/bin/bash
# this script updates your server to the latest version available

# change to server directory
cd dirname/minecraft/

# execute stop script
./stop.sh

# grep latest verion from papermc.io
Version=$(wget -q -O - https://papermc.io/api/v2/projects/paper | rev | cut -d, -f1 | rev)
Version="${Version:1}"
Version="${Version::-3}"
echo "latest server version seems to be $Version"
echo "trying to update to version $Version ..."

# test if papermc is avalable and update on success
wget --spider --quiet https://papermc.io/api/v1/paper/$Version/latest/download
if [ "$?" != 0 ]; then
	echo "Warning: Unable to connect to papermc API. Skipping update..."
else
	echo "Success: Updating to latest papermc version..."
	rm paperclip.jar
	wget -q -O paperclip.jar https://papermc.io/api/v1/paper/$Version/latest/download
fi

# execute start script
./start.sh
