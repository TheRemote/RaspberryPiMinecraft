This script will automatically download and configure the Paper Minecraft 1.13.1 server on your Raspberry Pi!<br>
For the full article and guide visit https://www.jamesachambers.com/2018/03/fast-raspberry-pi-minecraft-server-install-script/<br>
To add Crontab server scheduled restart support check out the new crontab file committed by Marc.<br>
<br>
<b>German (DE) version and article by Marc Tönsing:</b><br>
Eine deutsche Anleitung für die Konfigration eines Raspberry Pi mit Paper als stabiler Minecraft Server findet ihr hier:<br>
http://marc.tv/stabiler-minecraft-server-raspberry-pi<br>
<br>
<b>Version History</b><br>
<br>
February 2nd 2019<br>
-Script now checks to make sure we are running on the ARMv7 CPU architecture with 1024MB of RAM to ensure Java 9 works<br>
-Script helps you overclock SD card and change gpu_mem to 16MB<br>
-Increased memory usage of server from 800MB to 850MB due to gpu_mem tweak<br>
-Improved reliability and validation checks on setup script<br>
