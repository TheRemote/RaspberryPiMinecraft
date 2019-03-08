#!/bin/bash
# James Chambers - March 4th 2019
# Minecraft Server startup script using screen

# Flush out memory to disk so we have the maximum available for Java allocation
sync

# Check if server is already running
if screen -list | grep -q "minecraft"; then
    echo "Server is already running!  Type screen -r minecraft to open the console"
    exit 1
fi

# Check if network interfaces are up
NetworkChecks=0
DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second";
    sleep 1;
    DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
    ((NetworkChecks++))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

# Switch to server directory
cd dirname/minecraft/

# Back up server
if [ -d "world" ]; then 
    echo "Backing up server (to minecraft/backups folder)"
    tar -pzvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz world world_nether world_the_end
fi

# Configure paper.yml options
if [ -f "paper.yml" ]; then
    sed -i "s/early-warning-delay: 10000/early-warning-delay: 120000/g" paper.yml
    sed -i "s/early-warning-every: 5000/early-warning-every: 15000/g" paper.yml
fi

# Update paperclip.jar
echo "Updating to most recent paperclip version ..."

# Test internet connectivity first
wget --spider --quiet https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    wget https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar -O paperclip.jar
fi

echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
screen -dmS minecraft java -jar -Xms250M -XmxmemselectM dirname/minecraft/paperclip.jar