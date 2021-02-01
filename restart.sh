#!/bin/bash
# Author: James A. Chambers - https://jamesachambers.com/
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft
# Minecraft Server restart script - primarily called by minecraft service but can be ran manually with ./restart.sh

# Check if server is running
if ! screen -list | grep -q "\.minecraft"; then
    echo "Server is not currently running!"
    echo "Starting up server now..."
    ./start.sh
fi

echo "Sending restart notifications to server..."

# Minecraft Server restart and pi reboot.
counter="30"
while [ ${counter} -gt 0 ]; do
	if [[ "${counter}" =~ ^(30|7|6|5|4|3|2)$ ]]; then
		screen -Rd minecraft -X stuff "say Server is restarting in ${counter} seconds! $(printf '\r')"
	fi
	if [[ "${counter}" = 1 ]]; then
		screen -Rd minecraft -X stuff "say Server is restarting in ${counter} second! $(printf '\r')"
	fi
	counter=$((counter-1))
	sleep 1s
done
screen -Rd minecraft -X stuff "say Closing server...$(printf '\r')"
screen -Rd minecraft -X stuff "stop $(printf '\r')"

# Wait up to 30 seconds for server to close
echo "Closing server..."
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "\.minecraft"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

echo "Restarting now."
sudo reboot
