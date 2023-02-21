#!/bin/bash

domain='http://127.0.0.1:2000' # Domain of the server (CHANGE HERE)
page='fetchIP.php'


# Get IP address
MYIP=$(curl https://api.ipify.org --silent)
# If the above fails, try this
if [ -z "$MYIP" ]; then
    MYIP=$(curl https://wtfismyip.com/text --silent)
    if [ -z "$MYIP"]; then
        echo "Error: Could not get IP address"
        exit 1
    fi
fi

curl "${domain}/${page}?x=${MYIP}"

