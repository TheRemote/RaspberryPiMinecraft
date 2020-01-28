#!/bin/bash
# Randomblock1 and James Chambers - October 5th 2019
# GitHub Repository: https://github.com/Randomblock1/RaspberryPiMinecraft
# NukkitX Minecraft Server startup script using screen

# Minecraft server version from NukkitX-CI (Jenkins)
Artifact=artifact

# Flush out memory to disk so we have the maximum available for Java allocation
sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
sync

# Check if server is already running
if screen -list | grep -q "nukkitx"; then
    echo "Server is already running!  Type screen -r nukkitx to open the console"
    exit 1
fi

# Check if network interfaces are up
NetworkChecks=0
DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second";
    sleep 1;
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    NetworkChecks=$((NetworkChecks+1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

# Switch to server directory
cd dirname/nukkitx/

# Back up server
if [ -d "world" ]; then 
    echo "Backing up server (to nukkitx/backups folder)"
    tar --exclude='./backups' --exclude='./cache' --exclude='./logs' --exclude='./nukkitx.jar' -pzvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz ./*
fi

# Configure server.properties options
if [ -f "server.properties" ]; then
    # Configure server.properties
    # Disable Spawn protection
    sed -i "s/spawn-protection=16/spawn-protection=0/g" server.properties
fi

# Update nukkitx.jar
echo "Updating to most recent NukkitX version ..."

# Test internet connectivity first
wget --spider --quiet $Artifact
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    wget -O nukkitx.jar $Artifact
fi

echo "Starting NukkitX server.  To view window type screen -r nukkitx."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
screen -dmS nukkitx java -jar dirname/nukkitx/nukkitx.jar
