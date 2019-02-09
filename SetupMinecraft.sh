#!/bin/bash
# Minecraft Server Installation Script - James A. Chambers - https://www.jamesachambers.com
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft
echo "Minecraft Server installation script by James Chambers - February 9th 2019"
echo "Latest version always at https://github.com/TheRemote/RaspberryPiMinecraft"
echo "Don't forget to set up port forwarding on your router!  The default port is 25565"

# Check to see if Minecraft directory already exists, if it does then exit
if [ -d "minecraft" ]; then
  echo "Directory minecraft already exists!  Exiting..."
  exit 1
fi

# Get total system memory and make sure we are a 1024MB or higher board
echo "Getting total system memory..."
TotalMemory=$(awk '/MemTotal/{print $2}' /proc/meminfo)
echo "Total memory available: $TotalMemory"
if [ $TotalMemory -lt 800000 ]; then
  echo "Not enough memory to run a Minecraft server.  Requires Raspberry Pi with at least 1024MB of memory!"
  exit 1
fi

# Check system architecture to ensure we are running ARMv7
echo "Getting system ARM architecture..."
CPUModel=$(cat /proc/cpuinfo | grep 'model name' | uniq)
echo "System Architecture: $CPUModel"
if [[ "$CPUModel" == *"ARMv7"* ]]; then
  echo "Installing latest Java OpenJDK 9..."
  sudo apt-get install openjdk-9-jre-headless -y
  if [ -n 'which java' ]; then
    echo "Java installed successfully"
  else
    echo "Java did not install successfully -- please check the above output to see what went wrong."
    exit 1
  fi
else
  echo "You must be using a Raspberry Pi with ARMv7 support to run a Minecraft server!"
  echo "ARMv7 enables the G1GC garbage collector in Java which is required to have playable performance."
  exit 1
fi

RebootRequired=0
# Check MicroSD clock speed
MicroSDClock="$(sudo grep "actual clock" /sys/kernel/debug/mmc0/ios 2>/dev/null | awk '{printf("%0.3f MHz", $3/1000000)}')"
if [ -n "$MicroSDClock" ]; then
  echo "MicroSD clock: $MicroSDClock"
  if [ "$MicroSDClock" != "100.000 MHz" ]; then
    echo "Your MicroSD clock is set at $MicroSDClock instead of the recommended 100 MHz"
    echo "This setup can overclock this for you but some (usually cheaper) MicroSD cards will not boot with this setting"
    echo "If this happens you can remove dtparam=sd_overclock=100 or reimage the MicroSD and the Pi will work normally again"
    echo "This is at your own risk and does make a huge performance difference.  If you have a card that won't overclock or don't want to do this press n."
    echo -n "Set clock speed to 100 MHz?  Requires reboot. (y/n)?"
    read answer

    if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo bash -c 'printf "dtparam=sd_overclock=100\n" >> /boot/config.txt'
        echo "SD Card speed has been changed.  Please run setup again after reboot."
        RebootRequired=1
    fi
  fi
fi

# Check that GPU Shared memory is set to 16MB to give our server more resources
echo "Getting shared GPU memory..."
GPUMemory=$(vcgencmd get_mem gpu)
echo "Memory being used by shared GPU: $GPUMemory"
if [ "$GPUMemory" != "gpu=16M" ]; then
  echo "GPU memory needs to be set to 16MB for best performance."
  echo "This can be set in sudo raspi-config or the script can change it for you now."
  echo -n "Change GPU shared memory to 16MB?  Requires reboot. (y/n)?"
  read answer

  if [ "$answer" != "${answer#[Yy]}" ]; then
      sudo raspi-config nonint do_memory_split "16"
      echo "Split GPU memory has been changed.  Please run setup again after reboot."
      RebootRequired=1
  fi
fi

# Check if any configuration changes needed a reboot
if [ $RebootRequired -eq 1 ]; then
  echo "System is restarting -- please run setup again after restart"
  sudo reboot
  exit 0
fi

# Install screen to run minecraft in the background
echo "Installing screen..."
sudo apt-get install screen -y

# Create server directory
echo "Creating minecraft server directory..."
mkdir minecraft
cd minecraft

# Retrieve latest build of Paper minecraft server
echo "Getting latest Paper Minecraft server..."
wget -O paperclip.jar https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar

# Run the Minecraft server for the first time which will build the modified server and exit saying the EULA needs to be accepted
echo "Building the Minecraft server..."
java -jar -Xms850M -Xmx850M paperclip.jar

# Accept the EULA
echo "Accepting the EULA..."
echo eula=true > eula.txt

# Download start.sh from repository
echo "Grabbing start.sh from repository..."
wget -O start.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/start.sh
chmod +x start.sh

# Download stop.sh from repository
echo "Grabbing stop.sh from repository..."
wget -O stop.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/stop.sh
chmod +x stop.sh

# Download restart.sh from repository
echo "Grabbing restart.sh from repository..."
wget -O restart.sh https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/restart.sh
chmod +x restart.sh

# Server configuration
echo "Enter a name for your server..."
read -p 'Server Name: ' servername
echo "server-name=$servername" >> server.properties
echo "motd=$servername" >> server.properties

# Service configuration
sudo wget -O /etc/systemd/system/minecraft.service https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/minecraft.service
sudo chmod +x /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
echo -n "Start Minecraft server at startup automatically (y/n)?"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
  sudo systemctl enable minecraft.service

  # Automatic reboot at 4am configuration
  echo -n "Automatically reboot Pi and update server at 4am daily (y/n)?"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    croncmd="/home/pi/minecraft/restart.sh"
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
    echo "Daily reboot scheduled.  To change time or remove automatic reboot type crontab -e"
  fi
fi

# Finished!
echo "Setup is complete.  Starting Minecraft server..."
sudo systemctl start minecraft.service

# Sleep for 5 seconds to give the server time to start
sleep 5

screen -r minecraft
