#!/bin/bash
# Minecraft Server Installation Script - James A. Chambers - https://www.jamesachambers.com
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft

# Minecraft server version
Version="1.14.4"

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

# Configure how much memory to use for the Minecraft server
Get_ServerMemory () {
  Print_Style "Getting total system memory..." $YELLOW
  TotalMemory=$(awk '/MemTotal/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
  AvailableMemory=$(awk '/MemAvailable/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
  Print_Style "Total memory: $TotalMemory - Available Memory: $AvailableMemory" $YELLOW
  if [[ "$CPUArch" == *"armv7"* || "$CPUArch" == *"armhf"* ]]; then
    if [[ $AvailableMemory > 2700 ]]; then
      AvailableMemory=2700
    fi
  fi
  if [ $TotalMemory -lt 700 ]; then
    Print_Style "Not enough memory to run a Minecraft server.  Requires at least 1024MB of memory!" $YELLOW
    exit 1
  fi
  Print_Style "Total memory: $TotalMemory - Available Memory: $AvailableMemory"&
  if [ $AvailableMemory -lt 700 ]; then
    Print_Style "WARNING:  Available memory to run the server is less than 700MB.  This will impact performance and stability." $RED
    Print_Style "You can increase available memory by closing other processes.  If nothing else is running your distro may be using all available memory." $RED
    Print_Style "It is recommended to use a headless distro (Lite or Server version) to ensure you have the maximum memory available possible." $RED
    read -n1 -r -p "Press any key to continue"
  fi

  # Ask user for amount of memory they want to dedicate to the Minecraft server
  Print_Style "Please enter the amount of memory you want to dedicate to the server.  A minimum of 700MB is recommended." $CYAN
  Print_Style "You must leave enough left over memory for the operating system to run background processes." $CYAN
  Print_Style "If all memory is exhausted the Minecraft server will either crash or force background processes into the paging file (very slow)." $CYAN
  MemSelected=0
  while [[ $MemSelected -lt 600 || $MemSelected -ge $TotalMemory ]]; do
    read -p "Enter amount of memory in megabytes to dedicate to the Minecraft server (recommended: $AvailableMemory): " MemSelected
    if [[ $MemSelected -lt 600 ]]; then
      Print_Style "Please enter a minimum of 600" $RED
    elif [[ $MemSelected -gt $TotalMemory ]]; then
      Print_Style "Please enter an amount less than the total memory in the system ($TotalMemory)" $RED
    elif [[ $MemSelected -gt 2700 ]]; then
      Print_Style "You are running a 32 bit operating system which has a limit of 2700MB.  Please enter 2700 to use it all." $RED
      Print_Style "You can lift this restriction by upgrading to a 64 bit operating system." $RED
      MemSelected=0
    fi
  done
  Print_Style "Amount of memory for Minecraft server selected: $MemSelected MB" $GREEN
}

# Updates all scripts
Update_Scripts () {
  # Remove existing scripts
  rm minecraft/start.sh minecraft/stop.sh minecraft/restart.sh

  # Download start.sh from repository
  Print_Style "Grabbing start.sh from repository..." $YELLOW
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
}

# Updates Minecraft service
Update_Service () {
  sudo wget -O /etc/systemd/system/minecraft.service https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/minecraft.service
  sudo chmod +x /etc/systemd/system/minecraft.service
  sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/minecraft.service
  sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/minecraft.service
  sudo systemctl daemon-reload
  Print_Style "Minecraft can automatically start at boot if you wish." $CYAN
  echo -n "Start Minecraft server at startup automatically (y/n)?"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    sudo systemctl enable minecraft.service
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
    croncmd="$DirName/minecraft/restart.sh"
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
    Print_Style "Daily reboot scheduled.  To change time or remove automatic reboot type crontab -e" $GREEN
  fi
}

Print_Style "Minecraft Server installation script by James Chambers - August 25th 2019" $MAGENTA
Print_Style "Latest version always at https://github.com/TheRemote/RaspberryPiMinecraft" $MAGENTA
Print_Style "Don't forget to set up port forwarding on your router!  The default port is 25565" $MAGENTA

# Check system architecture to ensure we are running ARMv7 or higher
CPUArch=$(uname -m)
Print_Style "System Architecture: $CPUArch" $YELLOW

# Install dependencies needed to run minecraft in the background
Print_Style "Installing screen, sudo, net-tools, wget..." $YELLOW
if [ ! -n "`which sudo`" ]; then
  apt-get update && apt-get install sudo -y
fi
sudo apt-get update
sudo apt-get install screen wget -y
sudo apt-get install net-tools -y

# Install Java
Print_Style "Installing latest Java OpenJDK..." $YELLOW
JavaVer=$(apt-cache show openjdk-13-jre-headless | grep Version | awk 'NR==1{ print $2 }')
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
if [ -d "minecraft" ]; then
  Print_Style "Directory minecraft already exists!  Updating scripts and configuring service ..." $YELLOW

  # Get Home directory path and username
  cd minecraft
  DirName=$(readlink -e ~)
  UserName=$(whoami)

  # Ask user for amount of memory they want to dedicate to the Minecraft server
  Get_ServerMemory

  # Update Minecraft server scripts
  Update_Scripts

  # Service configuration
  Update_Service

  # Configure automatic start on boot
  Configure_Reboot

  Print_Style "Minecraft installation scripts have been updated to the latest version!" $GREEN
  exit 0
fi

RebootRequired=0
# Check MicroSD clock speed
MicroSDClock="$(sudo grep "actual clock" /sys/kernel/debug/mmc0/ios 2>/dev/null | awk '{printf("%0.3f MHz", $3/1000000)}')"
if [ -n "$MicroSDClock" ]; then
  if [[ "$MicroSDClock" == "50.000 MHz" ]]; then
    Print_Style "Your MicroSD clock is set at $MicroSDClock instead of the recommended 100 MHz" $CYAN
    Print_Style "This setup can overclock this for you but some (usually cheaper) MicroSD cards will not boot with this setting" $CYAN
    Print_Style "If this happens you can remove dtparam=sd_overclock=100 from /boot/config.txt or reimage the MicroSD and the Pi will work normally again" $CYAN
    Print_Style "This is at your own risk and does make a huge performance difference.  If you have a card that won't overclock or don't want to do this press n." $CYAN
    echo -n "Set clock speed to 100 MHz?  Requires reboot. (y/n)?"
    read answer

    if [ "$answer" != "${answer#[Yy]}" ]; then
      # Check for config.txt in /boot and /boot/firmware
      if [ -f "/boot/config.txt" ]; then
        sudo bash -c 'printf "\ndtparam=sd_overclock=100\n" >> /boot/config.txt'
        Print_Style "SD Card speed has been changed.  Please run setup again after reboot." $GREEN
        RebootRequired=1
      elif [ -f "/boot/firmware/config.txt" ]; then
        sudo bash -c 'printf "\ndtparam=sd_overclock=100\n" >> /boot/firmware/config.txt'
        Print_Style "SD Card speed has been changed.  Please run setup again after reboot." $GREEN
        RebootRequired=1
      else
        Print_Style "Error -- Unable to find config.txt file on this platform - MicroSD clock speed has not been changed!" $RED
      fi
    fi
  fi
fi

# Check that GPU Shared memory is set to 16MB to give our server more resources
Print_Style "Getting shared GPU memory..." $YELLOW
if [ -f "/boot/config.txt" ]; then
  GPUMemory=$(grep "gpu_mem" /boot/config.txt)
elif [ -f "/boot/firmware/config.txt" ]; then
  GPUMemory=$(grep "gpu_mem" /boot/firmware/config.txt)
else
  GPUMemory="Unknown"
  Print_Style "Error -- Unable to find config.txt file on this platform - GPU shared memory has not been changed!" $RED
fi

if [[ "$GPUMemory" != "Unknown" && "$GPUMemory" != "gpu_mem=16" ]]; then
  Print_Style "GPU memory needs to be set to 16MB for best performance." $CYAN
  Print_Style "This can be set in sudo raspi-config or the script can change it for you now." $CYAN
  echo -n "Change GPU shared memory to 16MB?  Requires reboot. (y/n)?"
  read answer

  if [ "$answer" != "${answer#[Yy]}" ]; then
    if [ -f "/boot/config.txt" ]; then
      sudo bash -c 'printf "\ngpu_mem=16\n" >> /boot/config.txt'
      Print_Style "Split GPU memory has been changed.  Please run setup again after reboot." $GREEN
      RebootRequired=1
    elif [ -f "/boot/firmware/config.txt" ]; then
      sudo bash -c 'printf "\ngpu_mem=16\n" >> /boot/firmware/config.txt'
      Print_Style "Split GPU memory has been changed.  Please run setup again after reboot." $GREEN
      RebootRequired=1
    else
      Print_Style "Error -- Unable to find config.txt file on this platform - split GPU memory has not been changed!" $RED
    fi
  fi
fi

# Check if any configuration changes needed a reboot
if [ $RebootRequired -eq 1 ]; then
  Print_Style "System is restarting -- please run setup again after restart" $GREEN
  sudo reboot
  exit 0
fi

# Get total system memory and make sure we are a 1024MB or higher board
sync
sleep 1s
Get_ServerMemory

# Create server directory
Print_Style "Creating minecraft server directory..." $YELLOW
cd ~
mkdir minecraft
cd minecraft
mkdir backups

# Get Home directory path and username
DirName=$(readlink -e ~)
UserName=$(whoami)

# Retrieve latest build of Paper minecraft server
Print_Style "Getting latest Paper Minecraft server..." $YELLOW
wget -O paperclip.jar https://papermc.io/api/v1/paper/$Version/latest/download

# Run the Minecraft server for the first time which will build the modified server and exit saying the EULA needs to be accepted
Print_Style "Building the Minecraft server..." $YELLOW
java -jar -Xms400M -Xmx"$MemSelected"M paperclip.jar

# Accept the EULA
Print_Style "Accepting the EULA..." $GREEN
echo eula=true > eula.txt

# Update Minecraft server scripts
Update_Scripts

# Server configuration
Print_Style "Enter a name for your server..." $MAGENTA
read -p 'Server Name: ' servername
echo "server-name=$servername" >> server.properties
echo "motd=$servername" >> server.properties

# Service configuration
Update_Service

# Configure automatic start on boot
Configure_Reboot

# Finished!
Print_Style "Setup is complete.  Starting Minecraft server..." $GREEN
sudo systemctl start minecraft.service

# Wait up to 30 seconds for server to start
StartChecks=0
while [ $StartChecks -lt 30 ]; do
  if screen -list | grep -q "minecraft"; then
    screen -r minecraft
    break
  fi
  sleep 1;
  StartChecks=$((StartChecks+1))
done

if [[ $StartChecks == 30 ]]; then
  Print_Style "Server has failed to start after 30 seconds." $RED
else
  screen -r minecraft
fi