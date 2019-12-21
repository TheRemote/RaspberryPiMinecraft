#!/bin/bash
# James Chambers - December 20th 2019
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service-1-13/
# Minecraft Server stop script - primarily called by minecraft service but can be ran manually

# Check if server is running
if ! screen -list | grep -q "minecraft"; then
  echo "Server is not currently running!"
  exit 1
fi

# Stop the server
echo "Stopping Minecraft server ..."
screen -Rd minecraft -X stuff "say Closing server (stop.sh called)...$(printf '\r')"
screen -Rd minecraft -X stuff "stop$(printf '\r')"

# Wait up to 30 seconds for server to close
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "minecraft"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

# Force quit if server is still open
if screen -list | grep -q "minecraft"; then
  echo "Minecraft server still hasn't closed after 30 seconds, closing screen manually"
  screen -S minecraft -X quit
fi

echo "Minecraft server stopped."

# Sync all filesystem changes out of temporary RAM
sync