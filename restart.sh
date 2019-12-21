#!/bin/sh
# James Chambers - December 20th 2019
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service-1-13/

# Check if server is running
if ! screen -list | grep -q "minecraft"; then
    echo "Server is not currently running!"
    exit 1
fi

echo "Sending restart notifications to server..."

# Minecraft Server restart and pi reboot.
screen -Rd minecraft -X stuff "say Server is restarting in 30 seconds! $(printf '\r')"
sleep 23s
screen -Rd minecraft -X stuff "say Server is restarting in 7 seconds! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Server is restarting in 6 seconds! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Server is restarting in 5 seconds! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Server is restarting in 4 seconds! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Server is restarting in 3 seconds! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Server is restarting in 2 seconds! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Server is restarting in 1 second! $(printf '\r')"
sleep 1s
screen -Rd minecraft -X stuff "say Closing server...$(printf '\r')"
screen -Rd minecraft -X stuff "stop $(printf '\r')"

# Wait up to 30 seconds for server to close
echo "Closing server..."
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "minecraft"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

echo "Restarting now."
sudo reboot
