#!/bin/bash
# Minecraft Server Installation Script - James A. Chambers - https://jamesachambers.com
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft

# To run the setup script use:
# curl https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh | bash

# Minecraft server version
Version="1.21.8"
# Set to AllowLocalCopy="1" if you make changes to the script otherwise any changes will be discarded and the latest online version will run
AllowLocalCopy="0"

# Custom Directory
# You can change this to a custom directory -- it is meant to be the root directory that contains everything (not including the "minecraft" folder part)
DirName=$(readlink -e ~)
if [ -z "$DirName" ]; then
  DirName=~
fi

cd "$DirName"

UserName=$(whoami)

# Terminal colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Function to read input from user with a prompt
function read_with_prompt() {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name </dev/tty
    if [ ! -n "$(which xargs)" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}' | tr -cd '[a-zA-Z0-9]._-')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]]; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
    read answer </dev/tty
    if [[ "$answer" == "${answer#[Yy]}" ]]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

# Prints a line with color using terminal codes
Print_Style() {
  printf "%s\n" "${2}$1${NORMAL}"
}

# Configure how much memory to use for the Minecraft server
Get_ServerMemory() {
  sync
  sleep 1s

  Print_Style "Getting total system memory..." "$YELLOW"
  TotalMemory=$(awk '/MemTotal/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
  AvailableMemory=$(awk '/MemAvailable/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
  CPUArch=$(uname -m)

  Print_Style "Total memory: $TotalMemory - Available Memory: $AvailableMemory" "$YELLOW"
  if [[ "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
    if [ "$AvailableMemory" -gt 2500 ]; then
      Print_Style "Warning: You are running a 32 bit operating system which has a hard limit of 3 GB of memory per process" "$RED"
      Print_Style "You must also leave behind some room for the Java VM process overhead.  It is not recommended to exceed 2500 and if you experience crashes you may need to reduce it further." $RED
      Print_Style "You can remove this limit by using a 64 bit Raspberry Pi Linux distribution (aarch64/arm64) like Ubuntu, Debian, etc." "$RED"
      AvailableMemory=2500
    fi
  fi
  if [ "$TotalMemory" -lt 700 ]; then
    Print_Style "Not enough memory to run a Minecraft server.  Requires at least 1024MB of memory!" "$YELLOW"
    exit 1
  fi
  Print_Style "Total memory: $TotalMemory - Available Memory: $AvailableMemory"
  if [ $AvailableMemory -lt 700 ]; then
    Print_Style "WARNING:  Available memory to run the server is less than 700MB.  This will impact performance and stability." "$RED"
    Print_Style "You can increase available memory by closing other processes.  If nothing else is running your distro may be using all available memory." "$RED"
    Print_Style "It is recommended to use a headless distro (Lite or Server version) to ensure you have the maximum memory available possible." "$RED"
    echo -n "Press any key to continue"
    read endkey </dev/tty
  fi

  # Ask user for amount of memory they want to dedicate to the Minecraft server
  Print_Style "Please enter the amount of memory you want to dedicate to the server.  A minimum of 700MB is recommended." "$CYAN"
  Print_Style "You must leave enough left over memory for the operating system to run background processes." "$CYAN"
  Print_Style "If all memory is exhausted the Minecraft server will either crash or force background processes into the paging file (very slow)." "$CYAN"
  if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
    Print_Style "INFO: You are running a 64-bit architecture, which means you can use more than 2700MB of RAM for the Minecraft server." "$YELLOW"
  fi
  MemSelected=0
  RecommendedMemory=$(($AvailableMemory - 400))
  while [[ $MemSelected -lt 600 || $MemSelected -ge $TotalMemory ]]; do
    echo -n "Enter amount of memory in megabytes to dedicate to the Minecraft server (recommended: $RecommendedMemory): "
    read MemSelected </dev/tty
    if [[ $MemSelected -lt 600 ]]; then
      Print_Style "Please enter a minimum of 600" "$RED"
    elif [[ $MemSelected -gt $TotalMemory ]]; then
      Print_Style "Please enter an amount less than the total memory in the system ($TotalMemory)" "$RED"
    elif [[ $MemSelected -gt 2700 && "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
      Print_Style "You are running a 32 bit operating system which has a limit of 2700MB.  Please enter 2700 to use it all." "$RED"
      Print_Style "If you experience crashes at 2700MB you may need to run SetupMinecraft again and lower it further." "$RED"
      Print_Style "You can lift this restriction by upgrading to a 64 bit operating system." "$RED"
      MemSelected=0
    fi
  done
  Print_Style "Amount of memory for Minecraft server selected: $MemSelected MB" "$GREEN"
}

# Updates all scripts
Update_Scripts() {
  # Remove existing scripts
  cd $DirName/minecraft
  rm -f start.sh stop.sh restart.sh fixpermissions.sh update.sh

  # Download start.sh from repository
  Print_Style "Grabbing start.sh from repository..." "$YELLOW"
  curl -H "Accept-Encoding: identity" -L -o start.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/start.sh
  chmod +x start.sh
  sed -i "s:dirname:$DirName:g" start.sh
  sed -i "s:memselect:$MemSelected:g" start.sh
  sed -i "s:verselect:$Version:g" start.sh
  sed -i "s<pathvariable<$PATH<g" start.sh

  # Download stop.sh from repository
  echo "Grabbing stop.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o stop.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/stop.sh
  chmod +x stop.sh
  sed -i "s:dirname:$DirName:g" stop.sh
  sed -i "s<pathvariable<$PATH<g" stop.sh

  # Download restart.sh from repository
  echo "Grabbing restart.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o restart.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/restart.sh
  chmod +x restart.sh
  sed -i "s:dirname:$DirName:g" restart.sh
  sed -i "s<pathvariable<$PATH<g" restart.sh

  # Download permissions.sh from repository
  echo "Grabbing fixpermissions.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o fixpermissions.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/fixpermissions.sh
  chmod +x fixpermissions.sh
  sed -i "s:dirname:$DirName:g" fixpermissions.sh
  sed -i "s:userxname:$UserName:g" fixpermissions.sh
  sed -i "s<pathvariable<$PATH<g" fixpermissions.sh

  # Download update.sh from repository
  echo "Grabbing update.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o update.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/update.sh
  chmod +x update.sh
  sed -i "s<pathvariable<$PATH<g" update.sh
}

# Updates Minecraft service
Update_Service() {
  sudo curl -H "Accept-Encoding: identity" -L -o /etc/systemd/system/minecraft.service https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/minecraft.service
  sudo sed -i "s:userxname:$UserName:g" /etc/systemd/system/minecraft.service
  sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/minecraft.service
  sudo systemctl daemon-reload
  Print_Style "Minecraft can automatically start at boot if you wish." "$CYAN"
  echo -n "Start Minecraft server at startup automatically (y/n)?"
  read answer </dev/tty
  if [ "$answer" != "${answer#[Yy]}" ]; then
    sudo systemctl enable minecraft.service
  fi
}

# Configuration of server automatic reboots
Configure_Reboot() {
  # Automatic reboot at 4am configuration
  TimeZone=$(cat /etc/timezone)
  CurrentTime=$(date)
  Print_Style "Your time zone is currently set to $TimeZone.  Current system time: $CurrentTime" "$CYAN"
  Print_Style "You can adjust/remove the selected reboot time later by typing crontab -e" "$CYAN"
  echo -n "Automatically reboot Pi and update server at 4am daily (y/n)?"
  read answer </dev/tty
  if [ "$answer" != "${answer#[Yy]}" ]; then
    croncmd="$DirName/minecraft/restart.sh"
    cronjob="0 4 * * * $croncmd 2>&1"
    (
      crontab -l | grep -v -F "$croncmd"
      echo "$cronjob"
    ) | crontab -
    Print_Style "Daily reboot scheduled.  To change time or remove automatic reboot type crontab -e" "$GREEN"
  fi
}

Install_Java() {
  # Remove old JRE
  rm -rf "$DirName/minecraft/jre"

  # Install Java
  Print_Style "Installing OpenJDK..." "$YELLOW"

  CPUArch=$(uname -m)
  if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.3%2B9/OpenJDK21U-jre_aarch64_linux_hotspot_21.0.3_9.tar.gz' -o jre21.tar.gz -L
    tar -xf jre21.tar.gz
    rm -f jre21.tar.gz
    mv jdk-* jre
  elif [[ "$CPUArch" == *"x86_64"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.3%2B9/OpenJDK21U-jre_x64_linux_hotspot_21.0.3_9.tar.gz' -o jre21.tar.gz -L
    tar -xf jre21.tar.gz
    rm -f jre21.tar.gz
    mv jdk-* jre
  elif [[ "$CPUArch" == *"s390x"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.3%2B9/OpenJDK21U-jre_s390x_linux_hotspot_21.0.3_9.tar.gz' -o jre21.tar.gz -L
    tar -xf jre21.tar.gz
    rm -f jre21.tar.gz
    mv jdk-* jre
  elif [[ "$CPUArch" == *"ppc64le"* ]]; then
    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.3%2B9/OpenJDK21U-jre_ppc64le_linux_hotspot_21.0.3_9.tar.gz' -o jre21.tar.gz -L
    tar -xf jre21.tar.gz
    rm -f jre21.tar.gz
    mv jdk-* jre
  fi

  if [ -e "$DirName/minecraft/jre/bin/java" ]; then
    CurrentJava=$($DirName/minecraft/jre/bin/java -version 2>&1 | head -1 | cut -d '"' -f 2 | cut -d '.' -f 1)
    if [[ $CurrentJava -lt 21 ]]; then
      Print_Style "Required OpenJDK version 21 could not be installed." "$RED"
      exit 1
    else
      Print_Style "OpenJDK installation completed." "$GREEN"
    fi
  else
    rm -rf "$DirName/minecraft/jre"
    Print_Style "Required OpenJDK version 21 could not be installed." "$RED"
    exit 1
  fi
}

Update_Sudoers() {
  if [ -d /etc/sudoers.d ]; then
    sudoline="$UserName ALL=(ALL) NOPASSWD: /bin/bash $DirName/minecraft/fixpermissions.sh, /bin/systemctl start minecraft, /bin/bash $DirName/minecraft/start.sh, /sbin/reboot"
    if [ -e /etc/sudoers.d/minecraft ]; then
      AddLine=$(sudo grep -qxF "$sudoline" /etc/sudoers.d/minecraft || echo "$sudoline" | sudo tee -a /etc/sudoers.d/minecraft)
    else
      AddLine=$(echo "$sudoline" | sudo tee /etc/sudoers.d/minecraft)
    fi
  else
    echo "/etc/sudoers.d was not found on your system.  Please add this line to sudoers using sudo visudo:  $sudoline"
  fi
}

Fix_Permissions() {
  echo "Setting server file permissions..."
  sudo ./fixpermissions.sh -a >/dev/null
}

#################################################################################################

Print_Style "Minecraft Server installation script by James A. Chambers - https://jamesachambers.com/" "$MAGENTA"
Print_Style "Version $Version will be installed.  To change this, open SetupMinecraft.sh and change the \"Version\" variable to the version you want to install." "$MAGENTA"
Print_Style "Latest version is always available at https://github.com/TheRemote/RaspberryPiMinecraft" "$MAGENTA"
Print_Style "Don't forget to set up port forwarding on your router!  The default port is 25565" "$MAGENTA"

cd "$DirName"

if [[ -e "SetupMinecraft.sh" && "$AllowLocalCopy" -ne "1" ]]; then
  rm -f "SetupMinecraft.sh"
  echo "Local copy of SetupMinecraft.sh running.  Exiting and running online version.  To override set AllowLocalCopy=\"1\" at the top of the script."
  curl https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh | bash
  exit 1
fi

# Check to make sure we aren't running as root
if [[ $(id -u) = 0 ]]; then
  echo "This script is not meant to run as root or sudo.  Please run as a normal user with ./SetupMinecraft.sh.  Exiting..."
  exit 1
fi

# Install dependencies needed to run minecraft in the background
Print_Style "Installing screen, sudo, net-tools, curl..." "$YELLOW"
if [ ! -n "$(which sudo)" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install net-tools -y
if [ ! -n "$(which screen)" ]; then
  sudo apt-get install screen -y
fi
if [ ! -n "$(which curl)" ]; then
  sudo apt-get install curl -y
fi
if [ ! -n "$(which pigz)" ]; then
  sudo apt-get install pigz -y
fi

# Check to see if Minecraft directory already exists, if it does then reconfigure existing scripts
if [ -d "$DirName/minecraft" ]; then
  Print_Style "Directory minecraft already exists!  Updating scripts and configuring service ..." "$YELLOW"

  # Get Home directory path and username
  cd "$DirName/minecraft"

  if [ -d "$DirName/minecraft/jre" ]; then
    if [ -e "$DirName/minecraft/jre/bin/java" ]; then
      CurrentJava=$($DirName/minecraft/jre/bin/java -version 2>&1 | head -1 | cut -d '"' -f 2 | cut -d '.' -f 1)
      if [[ $CurrentJava -lt 18 ]]; then
        Print_Style "Updating Java..." "$YELLOW"
        rm -rf "$DirName/minecraft/jre"
        Install_Java
      fi
    else
      Print_Style "Updating Java..." "$YELLOW"
      rm -rf "$DirName/minecraft/jre"
      Install_Java
    fi
  else
    Install_Java
  fi

  # Ask user for amount of memory they want to dedicate to the Minecraft server
  Get_ServerMemory

  # Update Minecraft server scripts
  Update_Scripts

  # Service configuration
  Update_Service

  # Sudoers configuration
  Update_Sudoers

  # Fix server files/folders permissions
  Fix_Permissions

  # Configure automatic start on boot
  Configure_Reboot

  Print_Style "Minecraft installation scripts have been updated to the latest version!" "$GREEN"
  exit 0
fi

# Create server directory
Print_Style "Creating minecraft server directory..." "$YELLOW"
mkdir -p "$DirName/minecraft"
cd "$DirName/minecraft"
mkdir backups
mkdir logs

# Install Java
Install_Java

# Get total system memory
Get_ServerMemory

# Retrieve latest build of Paper minecraft server
Print_Style "Getting latest Paper Minecraft server..." "$YELLOW"
BuildJSON=$(curl --no-progress-meter -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" https://api.papermc.io/v2/projects/paper/versions/$Version)
Build=$(echo "$BuildJSON" | rev | cut -d, -f 1 | cut -d']' -f 2 | cut -d'[' -f 1 | rev)
Build=$(($Build + 0))
curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4.212 Safari/537.36" -o paperclip.jar "https://api.papermc.io/v2/projects/paper/versions/$Version/builds/$Build/downloads/paper-$Version-$Build.jar"

# Run the Minecraft server for the first time which will build the modified server and exit saying the EULA needs to be accepted
Print_Style "Building the Minecraft server..." "$YELLOW"
$DirName/minecraft/jre/bin/java -jar -Xms400M -Xmx"$MemSelected"M paperclip.jar

# Accept the EULA
Print_Style "Accepting the EULA..." "$GREEN"
echo eula=true >eula.txt

# Update Minecraft server scripts
Update_Scripts

# Server configuration
Print_Style "Enter a name for your server..." "$MAGENTA"
read -p 'Server Name: ' servername </dev/tty

# Remove non-alphanumeric characters from servername
servername=$(echo "$servername" | tr -cd '[a-zA-Z0-9]._-')

# Modify server.properties with server name
echo "server-name=$servername" >>server.properties
echo "motd=$servername" >>server.properties

# Service configuration
Update_Service

# Configure automatic start on boot
Configure_Reboot

# Sudoers configuration
Update_Sudoers

# Fix server files/folders permissions
Fix_Permissions

# Finished!
Print_Style "Setup is complete.  Starting Minecraft server..." "$GREEN"
sudo systemctl start minecraft.service

# Wait up to 30 seconds for server to start
StartChecks=0
while [ $StartChecks -lt 30 ]; do
  if screen -list | grep -q "\.minecraft"; then
    sleep 5
    screen -r minecraft
    break
  fi
  sleep 1
  StartChecks=$((StartChecks + 1))
done

if [[ $StartChecks == 30 ]]; then
  Print_Style "Server has failed to start after 30 seconds." "$RED"
else
  screen -r minecraft
fi
