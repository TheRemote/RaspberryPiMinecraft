#!/bin/bash
# this script updates your server to the latest version available

# change to server directory
cd dirname/minecraft/

# execute stop script
./stop.sh

# ask user for desired update version
echo "To which server version would you like to update? Example: 1.16.5"
read -p "Your Version: " Version
VersionExists=false
while [[ $VersionExists == false ]]; do
	echo "checking availability of server version $Version ..."
	wget --spider --quiet https://papermc.io/api/v1/paper/$Version/latest/download
	if [ "$?" != 0 ]; then
		VersionExists=false
		echo "Version $Version does not exists (yet) - please try anotherone"
		read -p "Your Version: " Version
	else
		echo "Version $Version exists! - updating server..."
		VersionExists=true
	fi
done

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
