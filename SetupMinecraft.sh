#!/bin/bash
# Minecraft Server Installation Script - James A. Chambers - https://jamesachambers.com
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft

# To run the setup script use:
# curl https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh | bash

# Minecraft server version
Version="1.17"
AllowLocalCopy="0"

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
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
    read answer < /dev/tty
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
    if [ "$AvailableMemory" -gt 2700 ]; then
      Print_Style "Warning: You are running a 32 bit operating system which has a hard limit of 3 GB of memory per process" "$RED"
      Print_Style "You must also leave behind some room for the Java VM process overhead.  It is not recommended to exceed 2700 and if you experience crashes you may need to reduce it further." $RED
      Print_Style "You can remove this limit by using a 64 bit Raspberry Pi Linux distribution (aarch64/arm64) like Ubuntu, Debian, etc." "$RED"
      AvailableMemory=2700
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
    read endkey < /dev/tty
  fi

  # Ask user for amount of memory they want to dedicate to the Minecraft server
  Print_Style "Please enter the amount of memory you want to dedicate to the server.  A minimum of 700MB is recommended." "$CYAN"
  Print_Style "You must leave enough left over memory for the operating system to run background processes." "$CYAN"
  Print_Style "If all memory is exhausted the Minecraft server will either crash or force background processes into the paging file (very slow)." "$CYAN"
  if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
    Print_Style "INFO: You are running a 64-bit architecture, which means you can use more than 2700MB of RAM for the Minecraft server." "$YELLOW"
  fi
  MemSelected=0
  RecommendedMemory=$(($AvailableMemory - 200))
  while [[ $MemSelected -lt 600 || $MemSelected -ge $TotalMemory ]]; do
    echo -n "Enter amount of memory in megabytes to dedicate to the Minecraft server (recommended: $RecommendedMemory): " 
    read MemSelected < /dev/tty
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
  rm start.sh stop.sh restart.sh fixpermissions.sh

  # Download start.sh from repository
  Print_Style "Grabbing start.sh from repository..." "$YELLOW"
  wget -O start.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/start.sh
  chmod +x start.sh
  sed -i "s:dirname:$DirName:g" start.sh
  sed -i "s:memselect:$MemSelected:g" start.sh
  sed -i "s:verselect:$Version:g" start.sh

  # Download stop.sh from repository
  echo "Grabbing stop.sh from repository..."
  wget -O stop.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/stop.sh
  chmod +x stop.sh
  sed -i "s:dirname:$DirName:g" stop.sh

  # Download restart.sh from repository
  echo "Grabbing restart.sh from repository..."
  wget -O restart.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/restart.sh
  chmod +x restart.sh
  sed -i "s:dirname:$DirName:g" restart.sh

  # Download permissions.sh from repository
  echo "Grabbing fixpermissions.sh from repository..."
  wget -O fixpermissions.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/fixpermissions.sh
  chmod +x fixpermissions.sh
  sed -i "s:dirname:$DirName:g" fixpermissions.sh
  sed -i "s:userxname:$UserName:g" fixpermissions.sh
}

# Updates Minecraft service
Update_Service() {
  sudo wget -O /etc/systemd/system/minecraft.service https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/minecraft.service
  sudo chmod +x /etc/systemd/system/minecraft.service
  sudo sed -i "s:userxname:$UserName:g" /etc/systemd/system/minecraft.service
  sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/minecraft.service
  sudo systemctl daemon-reload
  Print_Style "Minecraft can automatically start at boot if you wish." "$CYAN"
  echo -n "Start Minecraft server at startup automatically (y/n)?"
  read answer < /dev/tty
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
  read answer < /dev/tty
  if [ "$answer" != "${answer#[Yy]}" ]; then
    croncmd="$DirName/minecraft/restart.sh"
    cronjob="0 4 * * * $croncmd"
    (
      crontab -l | grep -v -F "$croncmd"
      echo "$cronjob"
    ) | crontab -
    Print_Style "Daily reboot scheduled.  To change time or remove automatic reboot type crontab -e" "$GREEN"
  fi
}

Install_Java() {
  # Install Java
  Print_Style "Installing latest Java OpenJDK..." "$YELLOW"

  # Check for the highest available JDK first and then decrement version until we find a candidate for installation
  JavaVer=$(apt-cache show openjdk-16-jre-headless 2&>1 | grep Version | awk 'NR==1{ print $2 }')
  if [[ "$JavaVer" ]]; then
    sudo apt-get install openjdk-16-jre-headless -y
    return
  fi

  # Fall back to non headless JRE
  JavaVer=$(apt-cache show openjdk-16-jre 2&>1 | grep Version | awk 'NR==1{ print $2 }')
  if [[ "$JavaVer" ]]; then
    sudo apt-get install openjdk-16-jre -y
    return
  fi

  CurrentJava=$(java -version 2>&1 | head -1 | cut -d '"' -f 2 | cut -d '.' -f 1)
  if [[ $CurrentJava -lt 16 ]]; then
    Print_Style  "New enough OpenJDK (>=16) was not found in apt repositories and needs to be installed via snapd.  Checking for snapd..." "$YELLOW"
    if [ ! -n "$(which snap)" ]; then
      Print_Style "The snap application is not currently installed." "$CYAN"
      echo -n "Install snapd and reboot the Pi now? (run SetupMinecraft.sh again after reboot completes) (y/n)?"
      read answer < /dev/tty
      if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo apt-get install snapd -y
        sudo reboot
      else
        echo "Installation of snapd was aborted.  Exiting..."
        exit 1
      fi
      apt-get update && apt-get install sudo -y
    else
      Print_Style "Installing OpenJDK..." "$YELLOW"
      sudo snap install core
      sudo snap install openjdk
      sudo snap refresh openjdk
      sudo update-alternatives --install /usr/bin/java java /snap/openjdk/current/jdk/bin/java 1
      sudo update-alternatives --set java /snap/openjdk/current/jdk/bin/java
      CurrentJava=$(java -version 2>&1 | head -1 | cut -d '"' -f 2 | cut -d '.' -f 1)
      if [[ $CurrentJava -lt 16 || $CurrentJava -gt 16 ]]; then
        Print_Style "OpenJDK installation failed.  Java version is still reporting as less or greater than OpenJDK 16!" "$RED"
        exit 1
      else
        Print_Style "OpenJDK installation completed." "$GREEN"
      fi
    fi
  else
    Print_Style "OpenJDK installation completed." "$GREEN"
  fi
}

#################################################################################################

Print_Style "Minecraft Server installation script by James A. Chambers - https://jamesachambers.com/" "$MAGENTA"
Print_Style "Version $Version will be installed.  To change this, open SetupMinecraft.sh and change the \"Version\" variable to the version you want to install." "$MAGENTA"
Print_Style "Latest version is always available at https://github.com/TheRemote/RaspberryPiMinecraft" "$MAGENTA"
Print_Style "Don't forget to set up port forwarding on your router!  The default port is 25565" "$MAGENTA"

if [[ -e "SetupMinecraft.sh" && "$AllowLocalCopy" -ne "1" ]]; then
  rm -f "SetupMinecraft.sh"
  echo "Local copy of SetupMinecraft.sh running.  Exiting and running online version.  To override set AllowLocalCopy=\"1\" at the top of the script."
  curl https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh | bash
  exit 1
fi

# Check to make sure we aren't being ran as root
if [[ $(id -u) = 0 ]]; then
   echo "This script is not meant to be ran as root or sudo.  Please run normally with ./SetupMinecraft.sh.  If you know what you are doing and want to override this edit this check out of SetupMinecraft.sh.  Exiting..."
   exit 1
fi

# Install dependencies needed to run minecraft in the background
Print_Style "Installing screen, sudo, net-tools, wget..." "$YELLOW"
if [ ! -n "$(which sudo)" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install screen wget -y
sudo apt-get install net-tools -y

# Install Java dependency
Install_Java

# Check if Java installation was successful
if [ -n "$(which java)" ]; then
  CurrentJava=$(java -version 2>&1 | head -1 | cut -d '"' -f 2 | cut -d '.' -f 1)
  if [[ $CurrentJava -ge 16 ]]; then
    Print_Style "Java installed successfully" "$GREEN"
    else
      Print_Style "Java did not install successfully -- please install manually or check the above output to see what went wrong and run the installation script again." "$RED"
      exit 1
    fi
else
  Print_Style "Java did not install successfully -- please install manually or check the above output to see what went wrong and run the installation script again." "$RED"
  exit 1
fi

# Get directory path (default ~)
echo "Enter directory path to install Minecraft server (default ~): "
read_with_prompt DirName "Directory Path" ~
DirName=$(eval echo "$DirName")
UserName=$(whoami)

# Check to see if Minecraft directory already exists, if it does then reconfigure existing scripts
if [ -d "$DirName/minecraft" ]; then
  Print_Style "Directory minecraft already exists!  Updating scripts and configuring service ..." "$YELLOW"
  # Get Home directory path and username
  cd "$DirName/minecraft"

  # Ask user for amount of memory they want to dedicate to the Minecraft server
  Get_ServerMemory

  # Update Minecraft server scripts
  Update_Scripts

  # Service configuration
  Update_Service

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

# Get total system memory
Get_ServerMemory

# Retrieve latest build of Paper minecraft server
Print_Style "Getting latest Paper Minecraft server..." "$YELLOW"
wget -O paperclip.jar https://papermc.io/api/v1/paper/$Version/latest/download

# Run the Minecraft server for the first time which will build the modified server and exit saying the EULA needs to be accepted
Print_Style "Building the Minecraft server..." "$YELLOW"
java -jar -Xms400M -Xmx"$MemSelected"M paperclip.jar

# Accept the EULA
Print_Style "Accepting the EULA..." "$GREEN"
echo eula=true >eula.txt

# Update Minecraft server scripts
Update_Scripts

# Server configuration
Print_Style "Enter a name for your server..." "$MAGENTA"
read -p 'Server Name: ' servername
echo "server-name=$servername" >>server.properties
echo "motd=$servername" >>server.properties

# Service configuration
Update_Service

# Configure automatic start on boot
Configure_Reboot

# Finished!
Print_Style "Setup is complete.  Starting Minecraft server..." "$GREEN"
sudo systemctl start minecraft.service

# Wait up to 30 seconds for server to start
StartChecks=0
while [ $StartChecks -lt 30 ]; do
  if screen -list | grep -q "\.minecraft"; then
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
