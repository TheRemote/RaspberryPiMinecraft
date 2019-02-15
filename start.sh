#!/bin/bash
# James Chambers - February 15th 2019
# Minecraft Server startup script using screen

# Flush out memory to disk so we have the maximum available for Java allocation
sync

# Check if server is already running
if /usr/bin/screen -list | /bin/grep -q "minecraft"; then
    echo "Server is already running!  Type screen -r minecraft to open the console"
    exit 1
fi

# Check if network interfaces are up
NetworkChecks=0
DefaultRoute=$(/sbin/route -n | /usr/bin/awk '$4 == "UG" {print $2}')
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second";
    /bin/sleep 1;
    DefaultRoute=$(/sbin/route -n | /usr/bin/awk '$4 == "UG" {print $2}')
    ((NetworkChecks++))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

# Switch to server directory
cd /home/pi/minecraft/

# Update paperclip.jar
echo "Updating to most recent paperclip version ..."
# Test internet connectivity first
/usr/bin/wget --spider --quiet https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    /usr/bin/wget https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar -O /home/pi/minecraft/paperclip.jar
fi

echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
/usr/bin/screen -L /home/pi/minecraft/minecraft.log -dmS minecraft /usr/lib/jvm/java-9-openjdk-armhf/bin/java -jar -Xms850M -Xmx850M /home/pi/minecraft/paperclip.jar