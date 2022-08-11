This script will automatically download and configure the Paper Minecraft server!<br>
For the full article and guide visit https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/<br>

<h2>Installation Instructions</h2>
To get started / install the server type:<br>
<pre>curl https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/SetupMinecraft.sh | bash</pre><br>

<h2>Getting Help</h2>
To get help you may open an issue here or visit my web site at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/ which contains lots of comments from myself and users helping each other out!

<h2>Changing Minecraft Server Versions</h2>
If a new version of Minecraft is out and the script hasn't been updated yet you can change it in the SetupMinecraft.sh script.  If you use the command nano SetupMinecraft.sh it will be the first line in the file like this:<br>
<br>
Version="1.18.1"<br>
AllowLocalCopy="1"<br>
<br>
Make sure to change AllowLocalCopy="1" to tell the script you want to actually run the local copy instead of the latest version.<br>
Note that for this to work the Paper Minecraft server must also have released the latest version or the download will fail.  You can check here: <a href="https://papermc.io/downloads">https://papermc.io/downloads</a><br>

<h2>Check Java Version</h2>

<p>Sometimes if you have multiple versions of Java installed the wrong version of Java will be selected as the default.  If the server didn't start check that the right version of Java is selected with this command:</p>
<p>If you get the message "<em>update-alternatives: error: no alternatives for java</em>" then you only have one version of Java installed and can skip to the next section.</p>
<p>If you are presented with a list of choices then your machine has multiple versions of Java installed.  It will look like this:</p>

<pre><code>update-alternatives: warning: /etc/alternatives/java has been changed (manually or by a script); switching to manual updates only
There are 2 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                            Priority   Status
------------------------------------------------------------
  0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1101      auto mode
  1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1101      manual mode
  2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode
</code></pre>
<p>You will usually want to just select the newest version of OpenJDK that is listed so you would type 0 and press enter.  In some cases on some platforms you may want to switch to the official Oracle JDK although I strongly recommend sticking with OpenJDK!</p>

<h2>Tested Distributions</h2>
<ul>
<li>Raspberry Pi OS - Bullseye/Buster/Stretch</li>
<li>Ubuntu / Ubuntu Server 21.10 / 20.04 (LTS)</li>
<li>Debian 11 Bullseye / Debian 10 Buster / Debian 9 Stretch</li>
<li>Arch Linux</li>
<li>TinkerOS Stretch</li>
</ul>

<h3>Buy A Coffee / Donate</h3>
<p>People have expressed some interest in this (you are all saints, thank you, truly)</p>
<ul>
 <li>PayPal: 05jchambers@gmail.com</li>
 <li>Venmo: @JamesAChambers</li>
 <li>CashApp: $theremote</li>
 <li>Bitcoin (BTC): 3H6wkPnL1Kvne7dJQS8h7wB4vndB9KxZP7</li>
</ul>

<h2>Update History</h2>

<h3>August 10th 2022</h3>
<ul>
  <li>Moved custom directories to the top of SetupMinecraft.sh to eliminate confusion about how to use the feature (and almost nobody should unless you are storing your server on a separate drive)</li>
    <li>Improve JRE update detection in SetupMinecraft.sh</li>
</ul>

<h3>August 6th 2022</h3>
<ul>
  <li>Upgrade to 1.19.2</li>
</ul>

<h3>August 4th 2022</h3>
<ul>
  <li>Script now removes non-alphanumeric characters from the servername variable (to prevent using quotes and other symbols that will break it)</li>
</ul>

<h3>August 2nd 2022</h3>
<ul>
  <li>Fix ARM link for Adoptium OpenJDK
   (thanks zqigolden, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/pull/42">PR #42</a></li>
  <li>OpenJDK will now detect if you have an older version than SetupMinecraft is installing (or a broken Java install) and reinstall the newest version</li>
</ul>

<h3>July 31st 2022</h3>
<ul>
  <li>Upgrade Adoptium OpenJDK to 18.0.2 -- if you want to upgrade your Adoptium you can remove the ~/minecraft/jre folder and run SetupMinecraft.sh again to upgrade to the latest one</li>
</ul>

<h3>July 27th 2022</h3>
<ul>
  <li>Update to 1.19.1 (always make sure you've copied some backups out of the backups folder first!)</li>
</ul>

<h3>June 15th 2022</h3>
<ul>
  <li>Fix Paper 1.19 version upgrades (thanks Meganium97, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/issues/41">issue #41</a>)</li>
</ul>

<h3>June 11th 2022</h3>
<ul>
  <li>Update to Paper experimental 1.19 release as default installation</li>
  <li>Make sure you have backups of your server from your "backups" folder stored separately before upgrading</li>
  <li>If you have problems with 1.19 you need to restore a backup to go back to 1.18 as it will not take your server data files on 1.18 once the 1.19 structures/data have been added</li>
  <li>Change update.sh to /bin/bash instead of /bin/sh</li>
  <li>Add PATH variable to update.sh</li>
</ul>

<h3>May 22nd 2022</h3>
<ul>
  <li>Update OpenJDK installation paths</li>
</ul>

<h3>May 21st 2022</h3>
<ul>
  <li>Switched from JDK to JRE to save space</li>
  <li>Added Adoptium OpenJDK support for s390x and ppc64le architectures</li>
</ul>

<h3>May 16th 2022</h3>
<ul>
  <li>Add -DPaper.IgnoreJavaVersion=true to allow OpenJDK 17 to run the older Paper Minecraft versions (thanks NotMick, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/issues/39">issue #39</a>)</li>
</ul>

<h3>May 15th 2022</h3>
<ul>
  <li>Added screen -wipe to beginning of start.sh to prevent a startup issue that could occur if there was a "dead" screen instance (thanks grimholme)</li>
</ul>

<h3>May 11th 2022</h3>
<ul>
<li>Fix Adoptium arm and aarch64 OpenJDK links (thanks 407pilot, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/issues/38">issue #38</a></li>
</ul>

<h3>May 10th 2022</h3>
<ul>
<li>Update Adoptium OpenJDK version</li>
<li>Add safety check for backups to make sure folder exists before pruning</li>
</ul>

<h3>May 8th 2022</h3>
<ul>
<li>Fixed a problem with restart.sh having a #!/bin/sh at the top which could cause restart.sh to run in a POSIX shell that doesn't recognize the [[ operator (thanks jmswan, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/issues/37">issue #37</a></li>
</ul>

<h3>May 4th 2022</h3>
<ul>
<li>Fixed "route" command used to detect internet access to be compatible with Debian</li>
</ul>

<h3>April 24th 2022</h3>
<ul>
<li>Fixed mistake in new multicore compression (thanks pmcmorris) and related mistake in SetupMinecraft.sh dependency check</li>
</ul>

<h3>April 16th 2022</h3>
<ul>
<li>Remove "jre" folder if JDK installation fails so it will attempt to download a fresh copy upon running SetupMinecraft.sh again</li>
<li>Added support for the tar command to use multiple CPU cores instead of a single core.  This should speed up backups and reduce instances of when it takes longer to back up than the server's startup time (thanks SudosFTW, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/issues/36">issue #36</a>)</li>
</ul>

<h3>April 6th 2022</h3>
<ul>
<li>Fixed issue that prevented detecting a broken OpenJDK installation</li>
<li>Added language headers to OpenJDK download</li>
</ul>

<h3>March 24th 2022</h3>
<ul>
<li>Dedicated OpenJDK 17 install is now used (stored in your server's directory) to avoid apt / snap issues</li>
<li>Create "logs" folder for new servers to avoid harmless error messages (cleanup)</li>
<li>Add new "jre" folder to backup command's ignore list to avoid bloated backups</li>
</ul>

<h3>March 23rd 2022</h3>
<ul>
<li>Removed snapd installation as the snapd repository will only install OpenJDK 18 or higher which won't work with Paper</li>
<li>Paper still does not support OpenJDK 18 and will give errors using a version that high</li>
<li>Working on a new more reliable method to install OpenJDK 17</li>
</ul>

<h3>March 23rd 2022</h3>
<ul>
<li>Removed obsolete requirement not allowing OpenJDK versions above 17 as Paper now supports this</li>
</ul>

<h3>March 5th 2022</h3>
<ul>
<li>Update to 1.18.2 -- make sure you have backups first if you are upgrading from an existing server!</li>
</ul>

<h3>December 12th 2021</h3>
<ul>
<li>Update to 1.18.1 -- make sure you have backups first if you are upgrading from an existing server!</li>
</ul>
Update_Sudoers
<h3>November 30th 2021</h3>
<ul>
<li>Update to 1.18 -- make sure you have backups first if you are upgrading from an existing server!</li>
</ul>

<h3>September 15th 2021</h3>
<ul>
<li>Update to allow OpenJDK 17 which is now the default "snap"</li>
</ul>

<h3>September 2nd 2021</h3>
<ul>
<li>Update to Paper Minecraft Server API v2</li>
</ul>

<h3>August 1st 2021</h3>
<ul>
<li>Fixed a missing -A parameter for a curl command (thanks davie2000, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/issues/27">issue #27</a>)</li>
</ul>

<h3>July 27th 2021</h3>
<ul>
<li>Added PATH variable to scripts to improve compatibility on some distros</li>
<li>Server now fixes permissions upon startup</li>
</ul>

<h3>July 21st 2021</h3>
<ul>
<li>Switched from wget to curl to fix spacing issues experienced by some users</li>
<li>Added error redirection to crontab line to help diagnose failures during scheduled restarts</li>
</ul>

<h3>July 19th 2021</h3>
<ul>
<li>Fixed an issue where SetupMinecraft.sh could throw an error if no Java version was installed</li>
</ul>

<h3>July 17th 2021</h3>
<ul>
    <li>Fixed server name prompt</li>
    <li>Added username missing to fix service issue</li>
    <li>Reduced memory recommendation by 100MB to allow more space for the OS / other processes since newer versions of Minecraft are requiring more memory.  Remember, if you don't leave enough memory for other things the Minecraft server will crash for memory issues, but it's because you set it too high (counterintuitive I know) and didn't leave enough for the OS and it killed your Minecraft server to prevent the entire OS from crashing.</li>
    <li>Added in check to ensure start.sh and other scripts are not being ran as root.  If this happens you have to use sudo screen -r to find the screen and the permissions will be wrong since root isn't the owner of the server files</li>
    <li>If you know you ran the script/server as root (which starts creating files owned by root instead of the regular user) and your server won't start/is wonky run the fixpermissions script from your server folder with ./fixpermissions.sh and it will correct them for you!</li>
</ul>

<h3>July 15th 2021</h3>
<ul>
<li>Added safety check for path to server -- please use the default path of ~ if you aren't familiar with fully qualified Linux paths/directories -- you really don't want to change the safe defaults unless you have a really specific need.</li>
</ul>

<h3>July 14th 2021</h3>
<ul>
<li>Fixed a issue that was causing backups to not rotate (it should only keep 10).  Thanks Olli</li>
</ul>

<h3>July 8th 2021</h3>
<ul>
<li>Update to 1.17.1</li>
<li>Update documentation to explain new AllowLocalCopy="1" flag.  This flag tells the script not to run the latest online version and to run the local copy.  You want to use this if you are changing the version or making any modifications to the script itself before running it.</li>
<li>Added update.sh convenience script that calls the latest version of SetupMinecraft.sh</li>
<li>Fixed a bug where having an OpenJDK greater than 16 was not triggering the snap configuration (usually only seen on the cutting edge Ubuntu flavors)</li>
</ul>

<h3>July 5th 2021</h3>
<ul>
<li>Fixed an issue with SetupMinecraft.sh saving scripts to the home folder instead of the minecraft folder (thanks Ryan A J.)</li>
</ul>

<h3>July 3rd 2021</h3>
<ul>
<li>Add option to choose a custom directory instead of forcing the home path</li>
</ul>

<h3>June 24th 2021</h3>
<ul>
<li>Removed installation of OpenJDK above OpenJDK 16 as the Paper Minecraft server is not working with versions higher than 16</li>
<li>If you have a higher version of Java installed use the following command: sudo update-alternatives –config java and select OpenJDK 16</li>
</ul>

<h3>June 19th 2021</h3>
<ul>
<li>1.17 Release</li>
<li>Make sure you have backups and take copies of your backups and place them outside the Minecraft folder to be 100% safe</li>
<li>Once running the new version you can't go back to the old one without restoring a backup because it writes new stuff in your server the old version doesn't understand and crashes on</li>
<li>As long as you have backups you should be okay!</li>
</ul>

<h3>June 16th 2021</h3>
<ul>
<li>Raised minimum OpenJDK requirement to 16 in preparation for the 1.17 Paper Minecraft server release</li>
<li>If a new enough OpenJDK is not available in apt (Raspberry Pi OS is on OpenJDK 11 for example) it will be installed via snapd</li>
<li>If snapd is not installed it will ask you if you want to install it (reboot required) or abort</li>
<li>After the reboot run SetupMinecraft.sh again and it will finish installing OpenJDK 16!  Be patient, it can take some time, even 10-15 minutes on a good connection and longer on a bad one</li>
<li>Sorry for the inconvenience, there isn't an easier way to get it until the Raspberry Pi OS apt repositories are updated!</li>
</ul>

<h3>June 12th 2021</h3>
<ul>
<li>Fixed syntax error (thanks aruthir!)</li>
</ul>

<h3>June 10th 2021</h3>
<ul>
<li>Added OpenJDK 17 and 18 placeholders for prerequisite installations</li>
<li>Added a fallback to the non-headless JRE for platforms that don't offer that metapackage</li>
<li>Paper Minecraft 1.17 is not yet available but should be soon.  If you go to https://papermc.io/api/v1/paper/ and see 1.17 in the list it's available and you can change the version variable at the very top of SetupMinecraft.sh otherwise it hasn't been released yet.  Should be soon!</li>
</ul>

<h3>March 22nd 2021</h3>
<ul>
<li>Lowered amount of recommended memory by a flat 200MB due to so many people having "Out of Memory" errors</li>
<li>Note:  Nobody has ever really been "out of memory" on the Pi since like the Pi 1.  The problem is you're using TOO MUCH.</li>
<li>If you're getting memory related crashes you need to turn your memory DOWN.  The server will recommend lower amounts going forward.</li>
</ul>

<h3>March 16th 2021</h3>
<ul>
<li>Added backup rotation - server keeps the last 10 backups by default</li>
<li>If you want to change the amount of backups held it is located in the "start.sh" script with a comment of '# Rotate backups -- keep most recent 10'</li>
<li>This adds a little responsibility for saving really old backups but fixes the issue I and many others have had of the server getting filled with backups and crashing</li>
</ul>

<h3>January 31st 2021</h3>
<ul>
<li>Update to 1.16.5</li>
<li>Server now takes ownership of server files on each start to prevent folks a whole heap of trouble and heartache when restoring backups/moving files/etc.</li>
<li>Added check to make sure script isn't being ran as sudo to prevent installing to the /root folder</li>
</ul>

<h3>December 5th 2020</h3>
<ul>
<li>Update to 1.16.4</li>
<li>Fixed a bug where if your username on the Pi was Minecraft it would cause the script to break (thanks Minecraftschurli, <a href="https://github.com/TheRemote/RaspberryPiMinecraft/pull/20">pull request #20</a>)</li>
<li>Fixed a bug that could cause OpenJDK 10 to try to be installed even if OpenJDK 11 installation was successful</li>
</ul>

<h3>September 25th 2020</h3>
<ul>
<li>Update to 1.16.3</li>
</ul>

<h3>August 28th 2020</h3>
<ul>
<li>Update to 1.16.2</li>
</ul>

<h3>July 4th 2020</h3>
<ul>
<li>Update to 1.16.1</li>
</ul>

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