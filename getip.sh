#!/bin/bash

domain='http://127.0.0.1:2000' # Domain of the server (CHANGE HERE)
page='fetchIP.php'

websites=( 'https://api.ipify.org' 'https://wtfismyip.com/text' )

# Get IP address
for website in "${websites[@]}"; do
    if  curl -I "${website}" 2>&1 | grep -w "200\|301\|405" -q ; then
        MYIP=$(curl "${website}" --silent)
        break
    fi
done


# If the above fails, try this
if [ -z "$MYIP" ]; then
    echo "Error: Could not get IP address"
    exit 1
fi

curl "${domain}/${page}?x=${MYIP}"