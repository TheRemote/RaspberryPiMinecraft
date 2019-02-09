#!/bin/bash
# James Chambers - February 9th 2019
# Minecraft Server startup script using screen

# Flush out memory to disk so we have the maximum available for Java allocation
sync

# Check if server is already running
if screen -list | grep -q "minecraft"; then
    echo "Server is already running!  Type screen -r minecraft to open the console"
    exit 1
fi

# Start server
cd /home/pi/minecraft/

# Update paperclip.jar
echo "Updating to most recent paperclip version."
wget -q https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar -O /home/pi/minecraft/paperclip.jar

echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
/usr/bin/screen -dmS minecraft /usr/lib/jvm/java-9-openjdk-armhf/bin/java -jar -Xms850M -Xmx850M /home/pi/minecraft/paperclip.jar