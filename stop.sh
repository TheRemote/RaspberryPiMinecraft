#!/bin/bash
# Randomblock1 and James Chambers - October 5th 2019
# NukkitX Minecraft Server stop script - primarily called by nukkitx service but can be ran manually

# Check if server is running
if ! screen -list | grep -q "nukkitx"; then
  echo "Server is not currently running!"
  exit 1
fi

# Stop the server
echo "Stopping NukkitX Minecraft server ..."
screen -Rd nukkitx -X stuff "say Closing server (stop.sh called)...$(printf '\r')"
screen -Rd nukkitx -X stuff "stop$(printf '\r')"

# Wait up to 30 seconds for server to close
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "nukkitx"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

# Force quit if server is still open
if screen -list | grep -q "nukkitx"; then
  echo "NukkitX Minecraft server still hasn't closed after 30 seconds, closing screen manually"
  screen -S nukkitx -X quit
fi

echo "NukkitX Minecraft server stopped."

# Sync all filesystem changes out of temporary RAM
sync
