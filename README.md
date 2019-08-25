This script will automatically download and configure the Paper Minecraft 1.14.4 server on your Raspberry Pi!<br>
For the full article and guide visit https://www.jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service-1-13/<br>
<h2>Installation Instructions</h2>
To get started type:<br>
wget https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh<br>
chmod +x SetupMinecraft.sh<br>
./SetupMinecraft.sh<br>
<h2>Tested Distributions</h2>
-Raspbian / Raspian Lite Buster/Stretch<br>
-Ubuntu Server 18.04.2<br>
-Debian 9 Buster Preview<br>
-Armbian 9 Stretch<br>
-TinkerOS Stretch 2.0.8<br>
<h2>Update History</h2>
<h3>August 24th 2019</h3>
-To prevent startup failure on 32bit ARM the maximum memory for the Minecraft server is capped at 2700MB. This is a per process limitation of 32 bit on ARM and Linux. This restriction can be lifted by using a 64 bit operating system.
<h3>July 19th 2019</h3>
-Updated development version to 1.14.4<br>
-Added OpenJDK 13 support<br>
<h3>July 2nd 2019</h3>
-Removed bc dependency to improve portability<br>
<h3>June 30th 2019</h3>
-Raspberry Pi 4 support (all memory sizes)<br>
-Updated development version to 1.14.3<br>
-Fixed issue that could cause 1.13.2 servers to crash when going to the Nether<br>
<h3>June 1st 2019</h3>
-Added option to select stable or development version<br>
-Current stable version of the Paper Minecraft server is 1.13.2<br>
-If you want to install 1.14.2 you may select to do so during installation<br>
-Be aware that 1.14.2 continues to have severe performance issues for the entire Minecraft server/hosting community.  After playing on it myself and talking to the Paper developers I can personally state that performance on 1.14.2 is really bad right now and highly recommend sticking with the stable version.<br>
<h3>May 31st 2019</h3>
-OpenJDK 12 and OpenJDK 10 package checks added into the script<br>
-Script will attempt to install OpenJDK 10 from package on Raspbian if it isn't in apt<br>
-Added many paper.yml, bukkit.yml and spigot.yml changes to server config files to help with the ongoing lag affecting all Minecraft servers in 1.14<br>
-To configure them open start.sh in nano after running SetupMinecraft and you will see the different options and what they do<br>
-Updated Java certificates installer link<br>
-Fixed bug where changing GPU memory wasn't being applied<br>
<h3>May 30th 2019</h3>
-Updated to 1.14.2<br>
<h3>May 19th 2019</h3>
-Updated to 1.14.1<br>
<h3>April 18th 2019</h3>
-Changed StopChecks++ to StopChecks=$((StopChecks+1)) to improve portability (thanks Jason B.)<br>
-Added TimeoutStartSec=600 to server to prevent it being killed if taking longer than usual to download paperclip<br>
<h3>March 31st 2019</h3>
-Added x86_64 support<br>
<h3>March 9th 2019</h3>
-Changed Paper download URL to use API (Issue #7 Fix)<br>
-Added \n to beginning of printf to config.txt to prevent adding our line to the end of another config line<br>
<h3>March 7th 2019</h3>
-Added support for OpenJDK 8 to improve portability<br>
-Added Armbian support<br>
-Tinkerboard platform now supported.  Other Armbian capable boards should also work<br>
-Added ca-certificates-java OpenJDK 11 fix for a broken package on some platforms<br>
-Added checks for paper.yml and world backup folders before attempting to back up<br>
-Fixed portability issue with route vs /sbin/route<br>
<h3>March 4th 2019</h3>
-Shared GPU memory reduction and MicroSD overclock now supported on distros that use /boot/firmware/config.txt such as Ubuntu Server and Debian<br>
-Removed vcgencmd usage for portability to other distros<br>
-Added check for sudo for compatibility with more distros<br>
-Improved MicroSD clock detection<br>
-Setup now sets paper.yml option for watchdog warnings to wait until 120 seconds after the server starts to suppress excessive warnings<br>
<h3>March 2nd 2019</h3>
-Added a configuration option for memory to dedicate to the Minecraft server (along with a recommended amount)<br>
-Added support for Debian and Ubuntu Server Raspberry Pi distros<br>
-Server now installs OpenJDK-11-jre-headless if it is available, otherwise OpenJDK 9 will be selected<br>
-Improved CPU architecture detection<br>
-Added sudo, net-tools, wget to server dependencies to improve portability<br>
-Removed absolute paths from scripts to improve portability<br>
-MicroSD overclock and GPU memory split config are now split if vcgencmd is not present (non-Raspbian systems)<br>
<h3>February 18th 2019</h3>
-The SetupMinecraft.sh script will now update all of your scripts to the latest version when ran and reinstall the startup service<br>
-Implemented a workaround for Java 9 installation since the ca-certificates-java package broke in Raspbian on the 16th<br>
<h3>February 15th 2019</h3>
-Server now starts correctly on Raspbian Full (Raspbian Lite still highly recommended due to more available memory)<br>
-Added network connectivity check before attempting to update server - skips update if no connection available to prevent .jar corruption<br>
-Service now waits up to 20 seconds for network connectivity before starting up to prevent service starting before server gets an IP address<br>
-Fixed typo in stop.sh that was causing server to say it wasn't running when it was<br>
-Removed unnecessary sleep time on stop.sh script so it returns as soon as the minecraft server closes<br>
-Added automatic backups performed when server starts (located in minecraft/backups)<br>
<h3>February 9th 2019</h3>
-Added check to make sure service isn't already running when started<br>
<h3>February 3rd 2019</h3>
-Added optional service configuration to start minecraft automatically on boot<br>
-Added optional daily reboot configuration via Cron in setup script<br>
-Added a check in the installer to make sure Java was installed properly before continuing<br>
-Installer script now goes into the started screen window after installation<br>
-Server now checks for updates to the server on startup<br>
<h3>February 2nd 2019</h3>
-Script now checks to make sure we are running on the ARMv7 CPU architecture with 1024MB of RAM to ensure Java 9 works<br>
-Script helps you overclock SD card and change gpu_mem to 16MB<br>
-Increased memory usage of server from 800MB to 850MB due to gpu_mem tweak<br>
-Improved reliability and validation checks on setup script<br>