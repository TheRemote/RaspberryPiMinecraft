
bash stop.sh

answer="n" 
    # nested loop for version authentication and user input
    while [[ "$answer" != "y" ]]
    do
        while [[ "$answer" != "y" ]]
        do
            read -p "Enter the version of minecraft you want to run: " mcVer


            read -p "Do you want minecraft: $mcVer? [y/n]" answer
        done

        Print_Style "Getting Paper Minecraft server v$mcVer..." "$YELLOW"

        # d/l url
        URL="https://papermc.io/api/v1/paper/$mcVer/latest/download"
        # will return code 0 if paper version d/l's with no issue 
        # else will inform user that version entered is invalid and they need to try again
        wget --spider --quiet "$URL"
        if [ $? -ne 0 ] 
        then 
            sed -i "s:verselect:$mcVer:g" start.sh
        fi
    done


# Update paperclip.jar
echo "Updating to paperclip v$mcVer..."
wget -O paperclip.jar "$URL"

bash start.sh