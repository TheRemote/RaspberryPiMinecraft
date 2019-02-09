#!/bin/bash
# James Chambers - February 9th 2019
# Minecraft Server stop script - primarily called by minecraft service but can be ran manually

# Check if server is already running
if screen -list | grep -q "minecraft"; then
    echo "Server is not currently running!"
    exit 1
fi

# Stop the server
screen -Rd minecraft -X stuff "say Closing server (stop.sh called)...$(printf '\r')"
screen -Rd minecraft -X stuff "stop $(printf '\r')"
sleep 20s

if screen -list | grep -q "minecraft"; then
  echo "Minecraft server still hasn't closed after 20 seconds, closing screen manually"
  screen -S minecraft -X quit
fi

# Sync all filesystem changes out of temporary RAM
sync