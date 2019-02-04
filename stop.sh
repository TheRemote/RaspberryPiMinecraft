#!/bin/bash
# James Chambers - February 3rd 2019
# Minecraft Server stop script - primarily called by minecraft service but can be ran manually
screen -Rd minecraft -X stuff "say Closing server (stop.sh called)...$(printf '\r')"
screen -Rd minecraft -X stuff "stop $(printf '\r')"
sleep 10s
sync