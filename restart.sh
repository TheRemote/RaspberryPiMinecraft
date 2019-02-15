#!/bin/sh
# James Chambers - February 15th 2019
# Marc Tönsing - 18.05.2018

# Minecraft Server restart and pi reboot.
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 30 seconds! $(printf '\r')"
/bin/sleep 23s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 7 seconds! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 6 seconds! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 5 seconds! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 4 seconds! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 3 seconds! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 2 seconds! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Server is restarting in 1 second! $(printf '\r')"
/bin/sleep 1s
/usr/bin/screen -Rd minecraft -X stuff "say Closing server...$(printf '\r')"
/usr/bin/screen -Rd minecraft -X stuff "stop $(printf '\r')"
/bin/sleep 15s

echo "Restarting now."
sudo /sbin/reboot
