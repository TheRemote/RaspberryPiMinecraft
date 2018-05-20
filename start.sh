#!/bin/bash
# James Chambers - V1.0 - March 24th 2018
# Marc Tönsing - V1.1 - May 18th 2018
# Minecraft Server startup script using screen
echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
cd /home/pi/minecraft/
/usr/bin/screen -dmS minecraft /usr/lib/jvm/java-9-openjdk-armhf/bin/java -jar -Xms800M -Xmx800M /home/pi/minecraft/paperclip.jar
