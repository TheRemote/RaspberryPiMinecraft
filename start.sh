#!/bin/bash
# Marc Tönsing - V1.0 - 18.05.2018
# Minecraft Server startup script using screen
echo "Starte Minecraft Server.  Um  screen -r minecraft."
echo "Um den screen in den Hintergrund zu schieben, drücke Ctrl+A und dann Ctrl+D"
cd /home/pi/minecraft/
/usr/bin/screen -dmS minecraft /usr/lib/jvm/java-9-openjdk-armhf/bin/java -jar -Xms800M -Xmx800M /home/pi/minecraft/paperclip.jar
