This script will automatically download and configure the Paper Minecraft 1.13 server on your Raspberry Pi!<br>
For the full article and guide visit https://www.jamesachambers.com/2019/02/raspberry-pi-minecraft-server-script-with-startup-service-1-13/<br>
<br>
<b>German (DE) version and article by Marc Tönsing:</b><br>
Eine deutsche Anleitung für die Konfigration eines Raspberry Pi mit Paper als stabiler Minecraft Server findet ihr hier:<br>
http://marc.tv/stabiler-minecraft-server-raspberry-pi<br>
<br>
To get started type:<br>
wget https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh<br>
chmod +x SetupMinecraft.sh<br>
./SetupMinecraft.sh<br>
<br>
<b>Tested Distributions</b><br>
-Raspbian / Raspian Lite Stretch<br>
-Ubuntu Server 18.04.2<br>
-Debian 9 Buster Preview<br>
-Armbian 9 Stretch<br>
-TinkerOS Stretch 2.0.8<br>
<br>
<b>Update History</b><br>
<br>
March 31st 2019<br>
-Added x86_64 support<br>
<br>
March 9th 2019<br>
-Changed Paper download URL to use API (Issue #7 Fix)<br>
-Added \n to beginning of printf to config.txt to prevent adding our line to the end of another config line<br>
<br>
March 7th 2019<br>
-Added support for OpenJDK 8 to improve portability<br>
-Added Armbian support<br>
-Tinkerboard platform now supported.  Other Armbian capable boards should also work<br>
-Added ca-certificates-java OpenJDK 11 fix for a broken package on some platforms<br>
-Added checks for paper.yml and world backup folders before attempting to back up<br>
-Fixed portability issue with route vs /sbin/route<br>
<br>
March 4th 2019<br>
-Shared GPU memory reduction and MicroSD overclock now supported on distros that use /boot/firmware/config.txt such as Ubuntu Server and Debian<br>
-Removed vcgencmd usage for portability to other distros<br>
-Added check for sudo for compatibility with more distros<br>
-Improved MicroSD clock detection<br>
-Setup now sets paper.yml option for watchdog warnings to wait until 120 seconds after the server starts to suppress excessive warnings<br>
<br>
March 2nd 2019<br>
-Added a configuration option for memory to dedicate to the Minecraft server (along with a recommended amount)<br>
-Added support for Debian and Ubuntu Server Raspberry Pi distros<br>
-Server now installs OpenJDK-11-jre-headless if it is available, otherwise OpenJDK 9 will be selected<br>
-Improved CPU architecture detection<br>
-Added sudo, net-tools, wget to server dependencies to improve portability<br>
-Removed absolute paths from scripts to improve portability<br>
-MicroSD overclock and GPU memory split config are now split if vcgencmd is not present (non-Raspbian systems)<br>
<br>
February 18th 2019<br>
-The SetupMinecraft.sh script will now update all of your scripts to the latest version when ran and reinstall the startup service<br>
-Implemented a workaround for Java 9 installation since the ca-certificates-java package broke in Raspbian on the 16th<br>
<br>
February 15th 2019<br>
-Server now starts correctly on Raspbian Full (Raspbian Lite still highly recommended due to more available memory)<br>
-Added network connectivity check before attempting to update server - skips update if no connection available to prevent .jar corruption<br>
-Service now waits up to 20 seconds for network connectivity before starting up to prevent service starting before server gets an IP address<br>
-Fixed typo in stop.sh that was causing server to say it wasn't running when it was<br>
-Removed unnecessary sleep time on stop.sh script so it returns as soon as the minecraft server closes<br>
-Added automatic backups performed when server starts (located in minecraft/backups)<br>
<br>
February 9th 2019<br>
-Added check to make sure service isn't already running when started<br>
<br>
February 3rd 2019<br>
-Added optional service configuration to start minecraft automatically on boot<br>
-Added optional daily reboot configuration via Cron in setup script<br>
-Added a check in the installer to make sure Java was installed properly before continuing<br>
-Installer script now goes into the started screen window after installation<br>
-Server now checks for updates to the server on startup<br>
<br>
February 2nd 2019<br>
-Script now checks to make sure we are running on the ARMv7 CPU architecture with 1024MB of RAM to ensure Java 9 works<br>
-Script helps you overclock SD card and change gpu_mem to 16MB<br>
-Increased memory usage of server from 800MB to 850MB due to gpu_mem tweak<br>
-Improved reliability and validation checks on setup script<br>
