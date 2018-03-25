#!/bin/bash
# James Chambers - V1.0 - March 24th 2018
# Minecraft Server startup script using screen
echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
screen -dmS minecraft java -jar -Xms800M -Xmx800M paperclip.jar
