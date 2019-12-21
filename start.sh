#!/bin/bash
# James Chambers - December 20th 2019
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service-1-13/
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft
# Minecraft Server startup script using screen

# Flush out memory to disk so we have the maximum available for Java allocation
sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
sync

# Check if server is already running
if screen -list | grep -q "minecraft"; then
    echo "Server is already running!  Type screen -r minecraft to open the console"
    exit 1
fi

# Check if network interfaces are up
NetworkChecks=0
DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
while [ -z "$DefaultRoute" ]; do
    echo "Network interface not up, will try again in 1 second";
    sleep 1;
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    NetworkChecks=$((NetworkChecks+1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Waiting for network interface to come up timed out - starting server without network connection ..."
        break
    fi
done

# Switch to server directory
cd dirname/minecraft/

# Back up server
if [ -d "world" ]; then 
    echo "Backing up server (to minecraft/backups folder)"
    tar -pzvcf backups/$(date +%Y.%m.%d.%H.%M.%S).tar.gz world world_nether world_the_end
fi

# Paper / Spigot / Bukkit Optimization settings
# Original guide by Celebrimbor: https://www.spigotmc.org/threads/guide-server-optimization%E2%9A%A1.283181/

# Configure paper.yml options
if [ -f "paper.yml" ]; then
    # early-warning-delay, early-warning-every
    # Disables constant error spam of chunk unloading warnings
    sed -i "s/early-warning-delay: 10000/early-warning-delay: 120000/g" paper.yml
    sed -i "s/early-warning-every: 5000/early-warning-every: 60000/g" paper.yml
    # optimize-explosions
    # Paper applies a custom and far more efficient algorithm for explosions. It has no impact on gameplay.
    sed -i "s/optimize-explosions: false/optimize-explosions: true/g" paper.yml
    # mob-spawner-tick-rate
    # This is the delay (in ticks) before an activated spawner attempts to spawn mobs. Doubling the rate to 2 should have no impact on spawn rates. 
    # Only go higher if you have severe load from ticking spawners. Keep below 10.
    sed -i "s/mob-spawner-tick-rate: 1/mob-spawner-tick-rate: 3/g" paper.yml
    # container-update-tick-rate
    # This changes how often your containers/inventories are refreshed while open. Do not go higher than 3.
    sed -i "s/container-update-tick-rate: 1/container-update-tick-rate: 2/g" paper.yml
    # max-entity-collisions
    # Crammed entities (grinders, farms, etc.) will collide less and consume less TPS in the process.
    sed -i "s/max-entity-collisions: 8/max-entity-collisions: 2/g" paper.yml
    # fire-physics-event-for-redstone
    # This stops active redstone from firing BlockPhysicsEvent and can salvage some TPS from a cosmetic task.
    # Note: If you have a rare plugin that listens to BlockPhysicsEvent, leave this on.
    sed -i "s/fire-physics-event-for-redstone: true/fire-physics-event-for-redstone: false/g" paper.yml
    # use-faster-eigencraft-redstone
    # This setting eliminates redundant redstone updates by as much as 95% without breaking vanilla mechanics/devices (pretty sure). Empirical testing shows a speedup by as much as 10x!
    sed -i "s/use-faster-eigencraft-redstone: false/use-faster-eigencraft-redstone: true/g" paper.yml
    # grass-spread-tick
    # The time (in ticks) before the server attempts to spread grass in loaded chunks. This will have minimal gameplay impact on most game types.
    sed -i "s/grass-spread-tick-rate: 1/grass-spread-tick-rate: 3/g" paper.yml
    # despawn-ranges 
    # Soft = The distance (in blocks) from a player where mobs will be periodically removed.
    # Hard = Distance where mobs will be removed instantly.
    sed -i "s/soft: 32/soft: 28/g" paper.yml
    sed -i "s/hard: 128/hard: 96/g" paper.yml
    # hopper.disable-move-event
    # This will significantly reduce hopper lag by preventing InventoryMoveItemEvent being called for EVERY slot in a container.
    # Warning: If you have a plugin that listens to InventoryMoveItemEvent, do not set true.
    sed -i "s/hopper.disable-move-event: false/hopper.disable-move-event: true/g" paper.yml
    # non-player-arrow-despawn-rate, creative-arrow-despawn-rate
    # Similar to arrow-despawn-rate in Spigot, but targets skeleton arrows. Since players cannot retrieve mob-fired arrows, this setting is only a cosmetic change.
    sed -i "s/creative-arrow-despawn-rate: -1/creative-arrow-despawn-rate: 60/g" paper.yml
    sed -i "s/non-player-arrow-despawn-rate: -1/non-player-arrow-despawn-rate: 60/g" paper.yml
    # prevent-moving-into-unloaded-chunks
    # Prevents players from entering an unloaded chunk (due to lag), which causes more TPS loss. The true setting will rubberband them back to a "safe" area.
    # Note: If you did not pregenerate your world (what's wrong with you?!), this setting might be a godsend.
    sed -i "s/prevent-moving-into-unloaded-chunks: false/prevent-moving-into-unloaded-chunks: true/g" paper.yml
    # disable-chest-cat-detection
    # By default, chests scan for a cat/ocelot on top of it when opened. While this eliminates a vanilla mechanic (cats block chest opening), do you really need this silly mechanic?
    sed -i "s/disable-chest-cat-detection: false/disable-chest-cat-detection: true/g" paper.yml
    # bungee-online-mode
    # disable Bungee online mode
    sed -i "s/bungee-online-mode: true/bungee-online-mode: false/g" paper.yml
    # keep-spawn-loaded, keep-spawn-loaded-range
    # This causes the nether and the end to be ticked and save so we are going to disable it
    # This setting makes sense on high player count servers but for the Pi it just wastes resources
    sed -i "s/keep-spawn-loaded: true/keep-spawn-loaded: false/g" paper.yml
    sed -i "s/keep-spawn-loaded-range: 10/keep-spawn-loaded-range: -1/g" paper.yml
fi

# Configure bukkit.yml options
if [ -f "bukkit.yml" ]; then
    # monster-spawns
    # This dictates how often (in ticks) the server will attempt to spawn a monster in a legal location. Doubling the time between attempts helps performance without hurting spawn rates. 
    sed -i "s/monster-spawns: 1/monster-spawns: 2/g" bukkit.yml
    # autosave
    # This enables Bukkit's world saving function and how often it runs (in ticks). It should be 6000 (5 minutes) by default.
    # This is causing 10 second lag spikes in 1.14 so we are going to increase it to 18000 (15 minutes).
    sed -i "s/autosave: 6000/autosave: 18000/g" bukkit.yml
    # warn-on-overload
    # Disables annoying server is overloaded messages
    sed -i "s/warn-on-overload: true/warn-on-overload: false/g" bukkit.yml
fi

# Configure spigot.yml options
if [ -f "spigot.yml" ]; then
    # Merging items has a huge impact on tick consumption for ground items. Higher values allow more items to be swept into piles and allow you to avoid plugins like ClearLag.
    # Note: Merging items will lead to the occasional illusion of items disappearing as they merge together a few blocks away. A minor annoyance.
    sed -i "s/exp: 3.0/exp: 6.0/g" spigot.yml
    sed -i "s/item: 2.5/item: 4.0/g" spigot.yml
    # max-entity-collisions
    # Crammed entities (grinders, farms, etc.) will collide less and consume less TPS in the process.
    sed -i "s/max-entity-collisions: 8/max-entity-collisions: 2/g" spigot.yml
    # mob-spawn-range
    # Crammed entities (grinders, farms, etc.) will collide less and consume less TPS in the process.
    sed -i "s/mob-spawn-range: 8/mob-spawn-range: 6/g" spigot.yml
    # entity-activation-range:
    sed -i -z "s/entity-activation-range:\n      animals: 32\n      monsters: 32\n      raiders: 48\n      misc: 16\n      tick-inactive-villagers: true/entity-activation-range:\n      animals: 24\n      monsters: 24\n      raiders: 48\n      misc: 12\n      tick-inactive-villagers: false/g" spigot.yml
fi

# Configure server.properties options
if [ -f "server.properties" ]; then
    # Configure server.properties
    # network-compression-threshold
    # This option caps the size of a packet before the server attempts to compress it. Setting it higher can save some resources at the cost of more bandwidth, setting it to -1 disables it.
    # Note: If your server is in a network with the proxy on localhost or the same datacenter (<2 ms ping), disabling this (-1) will be beneficial.
    sed -i "s/network-compression-threshold=256/network-compression-threshold=512/g" server.properties
    # Disable Spawn protection
    sed -i "s/spawn-protection=16/spawn-protection=0/g" server.properties
    # Disable snooper
    sed -i "s/snooper-enabled=true/snooper-enabled=false/g" server.properties
    # Increase server watchdog timer to prevent it from shutting itself down without restarting
    sed -i "s/max-tick-time=60000/max-tick-time=120000/g" server.properties

fi

# Update paperclip.jar
echo "Updating to most recent paperclip version ..."

# Test internet connectivity first
wget --spider --quiet https://papermc.io/api/v1/paper/verselect/latest/download
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    wget -O paperclip.jar https://papermc.io/api/v1/paper/verselect/latest/download
fi

echo "Starting Minecraft server.  To view window type screen -r minecraft."
echo "To minimize the window and let the server run in the background, press Ctrl+A then Ctrl+D"
screen -dmS minecraft java -jar -Xms400M -XmxmemselectM dirname/minecraft/paperclip.jar
