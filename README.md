This script will automatically download and configure the Paper Minecraft 1.13 server on your Raspberry Pi!<br>
For the full article and guide visit https://www.jamesachambers.com/2019/02/raspberry-pi-minecraft-server-script-with-startup-service-1-13/<br>
<br>
<b>German (DE) version and article by Marc Tönsing:</b><br>
Eine deutsche Anleitung für die Konfigration eines Raspberry Pi mit Paper als stabiler Minecraft Server findet ihr hier:<br>
http://marc.tv/stabiler-minecraft-server-raspberry-pi<br>
<br>
<b>Version History</b><br>
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
