#!/bin/bash
# this script updates your server to the latest version available

# defines papermc server version
Version="1.16.5"

# change to server directory
cd dirname/minecraft/

# execute stop script
./stop.sh

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
