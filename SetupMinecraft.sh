#!/bin/bash
# NukkitX Server Installation Script by LexNetAT
# Forked from Randomblock1 - original code by James A. Chambers - https://www.jamesachambers.com
# GitHub Repository: https://github.com//RaspberryPiMinecraft

# GIT Repository
GIT="https://raw.githubusercontent.com/LexNetAT/RaspberryPiMinecraft"

# Minecraft server version from NukkitX-CI (Jenkins)
Artifact="https://ci.nukkitx.com/job/NukkitX/job/Nukkit/job/2.0/lastSuccessfulBuild/artifact/target/Nukkit.jar"

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

# Prints a line with color using terminal codes
Print_Style () {
  printf "%s\n" "${2}$1${NORMAL}"
}

# Updates all scripts
Update_Scripts () {
  # Remove existing scripts
  rm nukkitx/start.sh nukkitx/stop.sh nukkitx/restart.sh

  # Download start.sh from repository
  Print_Style "Grabbing start.sh from repository..." $YELLOW
  wget -O start.sh $GIT/master/start.sh
  chmod +x start.sh
  sed -i "s:dirname:$DirName:g" start.sh
  sed -i "s:memselect:$MemSelected:g" start.sh
  sed -i "s|artifact|$Artifact|g" start.sh
  
  # Download stop.sh from repository
  echo "Grabbing stop.sh from repository..."
  wget -O stop.sh $GIT/master/stop.sh
  chmod +x stop.sh
  sed -i "s:dirname:$DirName:g" stop.sh

  # Download restart.sh from repository
  echo "Grabbing restart.sh from repository..."
  wget -O restart.sh $GIT/master/restart.sh
  chmod +x restart.sh
  sed -i "s:dirname:$DirName:g" restart.sh
}

# Updates NukkitX service
Update_Service () {
  sudo wget -O /etc/systemd/system/nukkitx.service $GIT/master/nukkitx.service
  sudo chmod +x /etc/systemd/system/nukkitx.service
  sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/nukkitx.service
  sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/nukkitx.service
  sudo systemctl daemon-reload
  Print_Style "NukkitX can automatically start at boot if you wish." $CYAN
  echo -n "Start NukkitX Minecraft server at startup automatically (y/n)?"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    sudo systemctl enable nukkitx.service
  fi
}

# Configuration of server automatic reboots
Configure_Reboot () {
  # Automatic reboot at 4am configuration
  TimeZone=$(cat /etc/timezone)
  CurrentTime=$(date)
  Print_Style "Your time zone is currently set to $TimeZone.  Current system time: $CurrentTime" $CYAN
  Print_Style "You can adjust/remove the selected reboot time later by typing crontab -e" $CYAN
  echo -n "Automatically reboot Pi and update server at 4am daily (y/n)?"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    croncmd="$DirName/nukkitx/restart.sh"
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
    Print_Style "Daily reboot scheduled.  To change time or remove automatic reboot type crontab -e" $GREEN
  fi
}

Print_Style "NukkitX Minecraft: Bedrock Edition Server installation script by LexNetAT" $MAGENTA

# Check system architecture to ensure we are running ARMv7 or higher
CPUArch=$(uname -m)
Print_Style "System Architecture: $CPUArch" $YELLOW

# Install dependencies needed to run minecraft in the background
Print_Style "Installing screen, sudo, net-tools, wget..." $YELLOW
if [ ! -n "`which sudo`" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install screen wget net-tools -y

# Install Java
Print_Style "Installing latest Java OpenJDK..." $YELLOW
JavaVer=$(apt-cache show openjdk-14-jre-headless | grep Version | awk 'NR==1{ print $2 }')
if [[ "$JavaVer" ]]; then
  sudo apt-get install openjdk-14-jre-headless -y
else
  JavaVer=$(apt-cache show openjdk-13-jre-headless | grep Version | awk 'NR==1{ print $2 }')
  if [[ "$JavaVer" ]]; then
    sudo apt-get install openjdk-13-jre-headless -y
  else
    JavaVer=$(apt-cache show openjdk-12-jre-headless | grep Version | awk 'NR==1{ print $2 }')
    if [[ "$JavaVer" ]]; then
      sudo apt-get install openjdk-12-jre-headless -y
    else
      JavaVer=$(apt-cache show openjdk-11-jre-headless | grep Version | awk 'NR==1{ print $2 }')
      # Check for OpenJDK 11
      if [[ "$JavaVer" ]]; then
        sudo apt-get install openjdk-11-jre-headless -y
      else
        JavaVer=$(apt-cache show openjdk-10-jre-headless | grep Version | awk 'NR==1{ print $2 }')
        # Check for OpenJDK 10
        if [[ "$JavaVer" ]]; then
          sudo apt-get install openjdk-10-jre-headless -y
        else
          # Install OpenJDK 9 as a fallback
          if [ ! -n "`which java`" ]; then
            JavaVer=$(apt-cache show openjdk-9-jre-headless | grep Version | awk 'NR==1{ print $2 }')
            if [[ "$JavaVer" ]]; then
              sudo apt-get install openjdk-9-jre-headless -y
              # Create soft link to fix broken ca-certificates-java package that looks for client instead of server
              if [[ "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
                sudo ln -s /usr/lib/jvm/java-9-openjdk-armhf/lib/server /usr/lib/jvm/java-9-openjdk-armhf/lib/client
              elif [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
                sudo ln -s /usr/lib/jvm/java-9-openjdk-arm64/lib/server /usr/lib/jvm/java-9-openjdk-arm64/lib/client
              fi
              sudo apt-get install openjdk-9-jre-headless -y
            fi
          fi
        fi
      fi
    fi
  fi
fi

# Check if Java installation was successful
if [ -n "`which java`" ]; then
  Print_Style "Java installed successfully" $GREEN
else
  Print_Style "Java did not install successfully -- please check the above output to see what went wrong." $RED
  exit 1
fi

# Check to see if Minecraft directory already exists, if it does then reconfigure existing scripts
if [ -d "nukkitx" ]; then
  Print_Style "Directory minecraft already exists!  Updating scripts and configuring service ..." $YELLOW

  # Get Home directory path and username
  cd nukkitx
  DirName=$(readlink -e ~)
  UserName=$(whoami)

  # Update Minecraft server scripts
  Update_Scripts

  # Service configuration
  Update_Service

  # Configure automatic start on boot
  Configure_Reboot

  Print_Style "NukkitX installation scripts have been updated to the latest version!" $GREEN
  exit 0
fi

# Create server directory
Print_Style "Creating minecraft server directory..." $YELLOW
cd ~
mkdir nukkitx
cd nukkitx
mkdir backups

# Get Home directory path and username
DirName=$(readlink -e ~)
UserName=$(whoami)

# Retrieve latest build of NukkitX Minecraft server
Print_Style "Getting latest NukkitX Minecraft server..." $YELLOW
wget -O nukkitx.jar $Artifact

# Update Minecraft server scripts
Update_Scripts

# Server configuration
Print_Style "Enter a name for your server..." $MAGENTA
read -p 'Server Name: ' servername
echo "motd=$servername" >> server.properties
Print_Style "Enter a Sub-MOTD for your server..." $MAGENTA
read -p 'Sub-MOTD: ' submotd
echo "sub-motd=$submotd" >> server.properties


# Service configuration
Update_Service

# Configure automatic start on boot
Configure_Reboot

# Finished!
Print_Style "Setup is complete.  Starting NukkitX..." $GREEN
Print_Style "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D." $GREEN

sudo systemctl start nukkitx.service

# Wait up to 30 seconds for server to start
StartChecks=0
while [ $StartChecks -lt 10 ]; do
  if screen -list | grep -q "nukkitx"; then
    screen -r nukkitx
    break
  fi
  sleep 1;
  StartChecks=$((StartChecks+1))
done

if [[ $StartChecks == 30 ]]; then
  Print_Style "Server has failed to start after 30 seconds." $RED
else
  screen -r nukkitx
fi
