#!/bin/bash
# James Chambers - V1.0 - March 24th 2018
# Marc Tönsing - V1.1 - May 18th 2018
# James Chambers - V1.2 - February 2nd 2019
# Minecraft Server startup script using screen

# Flush out memory to disk so we have the maximum available for Java allocation
sync

# Start server
echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
cd /home/pi/minecraft/
/usr/bin/screen -dmS minecraft /usr/lib/jvm/java-9-openjdk-armhf/bin/java -jar -Xms850M -Xmx850M /home/pi/minecraft/paperclip.jar