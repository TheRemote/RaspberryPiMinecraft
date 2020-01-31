This script will automatically download and configure the Paper Minecraft 1.15.1 server on your Raspberry Pi!<br>
For the full article and guide visit https://www.jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service-1-13/<br>

<h2>Installation Instructions</h2>
To get started type:<br>
wget https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh<br>
chmod +x SetupMinecraft.sh<br>
./SetupMinecraft.sh<br>

<h2>Tested Distributions</h2>
<ul>
<li>Raspbian / Raspian Lite Buster/Stretch</li>
<li>Ubuntu Server 18.04.3</li>
<li>Debian 9 Buster Preview</li>
<li>Armbian 9 Stretch</li>
<li>Arch Linux</li>
<li>TinkerOS Stretch 2.0.8</li>
</ul>

<h2>Getting Help</h2>
To get help you may open an issue here or visit my web site at https://www.jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service-1-13/ which contains lots of comments from myself and users helping each other out!

<h2>Update History</h2>

<h3>January 25th 2020</h3>
<ul>
<li>Update to 1.15.2</li>
</ul>

<h3>December 28th 2019</h3>
<ul>
<li>Backup system now takes a backup of your entire server folder (minus logs and cache) instead of just the world folders.  This mean it now backs up things like server.properties and other worlds if you are running a multiverse setup.</li>
</ul>

<h3>December 20th 2019</h3>
<ul>
<li>Updated to version 1.15.1</li>
<li>Added more information to script installation warnings to help with initial configuration</li>
<li>Added warning to 2700MB limit on 32 bit operating systems explaining that you can lift the 3 GB limit by using a 64 bit Pi distribution</li>
<li>Cleaned up Java installation in setup script</li>
</ul>

<h3>August 26th 2019</h3>
<ul>
<li>Fixed a silly bug causing recommended memory to be stuck at 2700</li>
</ul>

<h3>August 25th 2019</h3>
<ul>
<li>Improved server startup detection after running SetupMinecraft</li>
<li>Added terminal colors to improve visibility</li>
<li>Cleaned up script substantially by breaking out duplicate code to functions</li>
<li>Fixed issue where when reconfiguring an existing server you would not be prompted to configure daily reboots</li>
<li>Removed /boot/config.txt tweaks as they are no longer compatible with Pi 4</li>
</ul>

<h3>August 24th 2019</h3>
<ul>
<li>To prevent startup failure on 32bit ARM the maximum memory for the Minecraft server is capped at 2700MB. This is a per process limitation of 32 bit on ARM and Linux. This restriction can be lifted by using a 64 bit operating system.</li>
</ul>

<h3>July 19th 2019</h3>
<ul>
<li>Updated development version to 1.14.4</li>
<li>Added OpenJDK 13 support</li>
</ul>

<h3>July 2nd 2019</h3>
<ul>
<li>Removed bc dependency to improve portability</li>
</ul>

<h3>June 30th 2019</h3>
<ul>
<li>Raspberry Pi 4 support (all memory sizes)</li>
<li>Updated development version to 1.14.3</li>
<li>Fixed issue that could cause 1.13.2 servers to crash when going to the Nether</li>
</ul>

<h3>June 1st 2019</h3>
<ul>
<li>Added option to select stable or development version</li>
<li>Current stable version of the Paper Minecraft server is 1.13.2</li>
<li>If you want to install 1.14.2 you may select to do so during installation</li>
<li>Be aware that 1.14.2 continues to have severe performance issues for the entire Minecraft server/hosting community.  After playing on it myself and talking to the Paper developers I can personally state that performance on 1.14.2 is really bad right now and highly recommend sticking with the stable version.</li>
</ul>

<h3>May 31st 2019</h3>
<ul>
<li>OpenJDK 12 and OpenJDK 10 package checks added into the script</li>
<li>Script will attempt to install OpenJDK 10 from package on Raspbian if it isn't in apt</li>
<li>Added many paper.yml, bukkit.yml and spigot.yml changes to server config files to help with the ongoing lag affecting all Minecraft servers in 1.14</li>
<li>To configure them open start.sh in nano after running SetupMinecraft and you will see the different options and what they do</li>
<li>Updated Java certificates installer link</li>
<li>Fixed bug where changing GPU memory wasn't being applied</li>
</ul>

<h3>May 30th 2019</h3>
<ul>
<li>Updated to 1.14.2</li>
</ul>

<h3>May 19th 2019</h3>
<ul>
<li>Updated to 1.14.1</li>
</ul>

<h3>April 18th 2019</h3>
<ul>
<li>Changed StopChecks++ to StopChecks=$((StopChecks+1)) to improve portability (thanks Jason B.)</li>
<li>Added TimeoutStartSec=600 to server to prevent it being killed if taking longer than usual to download paperclip</li>
</ul>

<h3>March 31st 2019</h3>
<ul>
<li>Added x86_64 support</li>
</ul>

<h3>March 9th 2019</h3>
<ul>
<li>Changed Paper download URL to use API (Issue #7 Fix)</li>
<li>Added \n to beginning of printf to config.txt to prevent adding our line to the end of another config line</li>
</ul>

<h3>March 7th 2019</h3>
<ul>
<li>Added support for OpenJDK 8 to improve portability</li>
<li>Added Armbian support</li>
<li>Tinkerboard platform now supported.  Other Armbian capable boards should also work</li>
<li>Added ca<li>certificates<li>java OpenJDK 11 fix for a broken package on some platforms</li>
<li>Added checks for paper.yml and world backup folders before attempting to back up</li>
<li>Fixed portability issue with route vs /sbin/route</li>
</ul>

<h3>March 4th 2019</h3>
<ul>
<li>Shared GPU memory reduction and MicroSD overclock now supported on distros that use /boot/firmware/config.txt such as Ubuntu Server and Debian</li>
<li>Removed vcgencmd usage for portability to other distros</li>
<li>Added check for sudo for compatibility with more distros</li>
<li>Improved MicroSD clock detection</li>
<li>Setup now sets paper.yml option for watchdog warnings to wait until 120 seconds after the server starts to suppress excessive warnings</li>
</ul>

<h3>March 2nd 2019</h3>
<ul>
<li>Added a configuration option for memory to dedicate to the Minecraft server (along with a recommended amount)</li>
<li>Added support for Debian and Ubuntu Server Raspberry Pi distros</li>
<li>Server now installs OpenJDK<li>11<li>jre<li>headless if it is available, otherwise OpenJDK 9 will be selected</li>
<li>Improved CPU architecture detection</li>
<li>Added sudo, net<li>tools, wget to server dependencies to improve portability</li>
<li>Removed absolute paths from scripts to improve portability</li>
<li>MicroSD overclock and GPU memory split config are now split if vcgencmd is not present (non<li>Raspbian systems)</li>
</ul>

<h3>February 18th 2019</h3>
<ul>
<li>The SetupMinecraft.sh script will now update all of your scripts to the latest version when ran and reinstall the startup service</li>
<li>Implemented a workaround for Java 9 installation since the ca<li>certificates<li>java package broke in Raspbian on the 16th</li>
</ul>

<h3>February 15th 2019</h3>
<ul>
<li>Server now starts correctly on Raspbian Full (Raspbian Lite still highly recommended due to more available memory)</li>
<li>Added network connectivity check before attempting to update server <li> skips update if no connection available to prevent .jar corruption</li>
<li>Service now waits up to 20 seconds for network connectivity before starting up to prevent service starting before server gets an IP address</li>
<li>Fixed typo in stop.sh that was causing server to say it wasn't running when it was</li>
<li>Removed unnecessary sleep time on stop.sh script so it returns as soon as the minecraft server closes</li>
<li>Added automatic backups performed when server starts (located in minecraft/backups)</li>
</ul>

<h3>February 9th 2019</h3>
<ul>
<li>Added check to make sure service isn't already running when started</li>
</ul>

<h3>February 3rd 2019</h3>
<ul>
<li>Added optional service configuration to start minecraft automatically on boot</li>
<li>Added optional daily reboot configuration via Cron in setup script</li>
<li>Added a check in the installer to make sure Java was installed properly before continuing</li>
<li>Installer script now goes into the started screen window after installation</li>
<li>Server now checks for updates to the server on startup</li>
</ul>

<h3>February 2nd 2019</h3>
<ul>
<li>Script now checks to make sure we are running on the ARMv7 CPU architecture with 1024MB of RAM to ensure Java 9 works</li>
<li>Script helps you overclock SD card and change gpu_mem to 16MB</li>
<li>Increased memory usage of server from 800MB to 850MB due to gpu_mem tweak</li>
<li>Improved reliability and validation checks on setup script</li>
</ul>