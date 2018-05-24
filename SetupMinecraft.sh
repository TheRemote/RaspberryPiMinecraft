#!/bin/bash
# Minecraft Server Installation Script - James A. Chambers - https://www.jamesachambers.com
# V1.0 - March 24th 2018
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft
red='tput setaf 1'
magenta='put setaf 5'
reset='put sgr0'

echo "${magenta}Minecraft Server installation script by James Chambers - V1.0"
echo "Latest version always at https://github.com/TheRemote/RaspberryPiMinecraft ${reset}"

if [ -d "minecraft" ]; then
  echo "${red}Directory minecraft already exists!  Exiting... ${reset}"
  exit 1
fi

echo "${magenta}Installing latest Java OpenJDK 9... ${reset}"
sudo apt-get install openjdk-9-jdk-headless -y

echo "${magenta}Installing screen... ${reset}"
sudo apt-get install screen -y

echo "${magenta}Creating minecraft server directory... ${reset}"
mkdir minecraft
cd minecraft

echo "${magenta}Getting latest Paper Minecraft server... ${reset}"
wget -O paperclip.jar https://ci.destroystokyo.com/job/PaperSpigot/lastSuccessfulBuild/artifact/paperclip.jar

echo "${magenta}Building the Minecraft server... ${reset}"
java -jar -Xms800M -Xmx800M paperclip.jar

echo "${magenta}Accepting the EULA... ${reset}"
echo eula=true > eula.txt

echo "${magenta}Grabbing start.sh from repository... ${reset}"
wget -O start.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/start.sh
chmod +x start.sh

echo "${magenta}Grabbing restart.sh from repository... ${reset}"
wget -O restart.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/restart.sh
chmod +x restart.sh

echo "${magenta}Enter a name for your server ${reset}"
read -p 'Server Name: ' servername
echo "server-name=$servername" >> server.properties
echo "motd=$servername" >> server.properties

echo "${magenta}Setup is complete.  To run the server go to the minecraft directory and type ./start.sh"
echo "Don't forget to set up port forwarding on your router.  The default port is 25565 ${reset}"
