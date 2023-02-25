#!/usr/bin/env bash
#
# Install script for the Dyanmic Remote IP Address Service
#
# February 2023  - Adam Moreira & Michele Giugliano


rm -f ./dyndns.sh > /dev/null 2>&1
rm -f ./getip.sh > /dev/null 2>&1
rm -f ./*.php > /dev/null 2>&1

TS=$(date +%s)      # Unix time stamp

echo ""
echo "Dynamic Remote IP Address Service"
echo "A hack to report the IP address of a PC to a web server."
echo ""

echo "This installer creates:"
echo "- a custom PHP script (to be placed on your own web server);"
echo "- a custom script on your remote PC to report its IP to the web server;"
echo "- a custom script to recover the IP address from the web server, from any other PC;"
echo ""
echo ""

echo "Please enter the following information:"
echo ""
read -p "- URL (cloud) path to the php script [https://www.example.com/scretflder]: " ENDPOINT
#echo $ENDPOINT

# Let's make sure the URL is not empty!
if [ -z "${ENDPOINT}" ];
then
    echo "Please enter a valid URL"
    exit 1
fi

# Let's make sure the URL ends with a slash
[[ "${ENDPOINT}" != */ ]] && ENDPOINT="${ENDPOINT}/"

read -p "- a name for this host [$HOSTNAME]: " HOST
HOST=${HOST:-$HOSTNAME}

TMP="$(echo -ne $TS | sha256sum | head -c10)"
read -p "- a random string [$TMP]: " SHARED_KEY
SHARED_KEY=${SHARED_KEY:-$TMP}

TMP=$HOST$TS$SHARED_KEY
KEY="$(echo -ne $TMP| sha256sum | head -c16)";

# Let's create the PHP script to be uploaded to the web server -----------------
echo ""
echo ""
echo "Creating PHP script..."

echo "<?php"                                                  > $SHARED_KEY.php
echo ""                                                       >> $SHARED_KEY.php
echo "\$filename = './$SHARED_KEY.txt';"                      >> $SHARED_KEY.php
echo "\$content  = \$_GET[\"x\"];  //"                        >> $SHARED_KEY.php
echo "\$sharedkey= \$_GET[\"SIG\"];"                          >> $SHARED_KEY.php
echo ""                                                       >> $SHARED_KEY.php
echo "if (strcmp(\$sharedkey, \"$KEY\") === 0) {"             >> $SHARED_KEY.php
echo ""                                                       >> $SHARED_KEY.php
echo "if (!\$fp = fopen(\$filename, 'w')) {"                  >> $SHARED_KEY.php
echo "	 echo \"Cannot open the output file on the server!\";" >> $SHARED_KEY.php
echo "     exit;"                                             >> $SHARED_KEY.php
echo "}"                                                      >> $SHARED_KEY.php
echo ""                                                       >> $SHARED_KEY.php
echo "if (fwrite(\$fp, \$content) === FALSE) {"               >> $SHARED_KEY.php
echo "   echo '<script language="javascript">';"              >> $SHARED_KEY.php
echo "    echo 'alert(\"Problem writing output file on the server!\")';" >> $SHARED_KEY.php
echo "    echo \"window.close();</script>\";"                 >> $SHARED_KEY.php
echo "   exit;"                                               >> $SHARED_KEY.php
echo "}"                                                      >> $SHARED_KEY.php
echo ""                                                       >> $SHARED_KEY.php
#echo "echo '<script language=\"javascript\">';"               >> $SHARED_KEY.php
#echo "echo \"window.close();</script>\";"                     >> $SHARED_KEY.php
echo ""                                                       >> $SHARED_KEY.php
echo "fclose(\$fp);"                                          >> $SHARED_KEY.php
echo "}"                                                      >> $SHARED_KEY.php
echo "?>"                                                     >> $SHARED_KEY.php

echo "Done!"
echo ""
echo ""
# ------------------------------------------------------------------------------

# Check if curl or wget is installed
if command -v wget &> /dev/null
then
    CMD="wget -q -O -"
else
    CMD="curl -s "
fi


# Let's create the dyndns.sh bash script to be run on the remote PC ------------
echo "Creating bash script to update IP address to the cloud..."

echo "#!/usr/bin/env bash"                                          > dyndns.sh
echo ""                                                             >> dyndns.sh
#echo "MYIP=$(hostname -I | awk '{print $1}')"                       >> dyndns.sh
echo "MYIP=\$($CMD https://api.ipify.org)"                          >> dyndns.sh
echo "echo Updating IP address to \$MYIP..."                        >> dyndns.sh
echo "$CMD \"$ENDPOINT$SHARED_KEY.php?x=\$MYIP&SIG=$KEY\""          >> dyndns.sh

echo "Done!"
echo ""
echo ""
# ------------------------------------------------------------------------------

# Let's create the getip.sh bash script to be run on any other PC ---------------
echo "Creating bash script to recover IP address..."

echo "#!/usr/bin/env bash"                                      > getip_$HOST.sh
echo "#"                                                       >> getip_$HOST.sh
echo "# This is to get the IP of $HOST"                        >> getip_$HOST.sh
echo ""                                                        >> getip_$HOST.sh
echo "echo \$($CMD $ENDPOINT$SHARED_KEY.txt)"                  >> getip_$HOST.sh
echo ""                                                        >> getip_$HOST.sh

echo "Done!"
echo ""
echo ""
# ------------------------------------------------------------------------------

echo "Install script completed!!"
echo ""
echo "Please complete the final steps:"
echo "1) Upload $SHARED_KEY.php to your web server,"
echo "   so it can be reached at $ENDPOINT$SHARED_KEY.php"
echo ""
echo "2) Place dyndns.sh on your remote PC (in root ~/) to send the IP to the cloud."
echo ""
echo "3) Move and use getip_$HOST.sh to any other PC to recover the IP address of $HOST."
echo "e.g. alias $HOST='source getip_$HOST.sh'"
echo "e.g. alias $HOST=$(source getip_$HOST.sh); ssh user@$HOST"
echo ""
echo "4) Add a cron job to run dyndns.sh every hour."
echo "e.g. sudo (crontab -l ; echo \"0 * * * * ~/dyndns.sh\") 2>&1 | grep -v \"no crontab\" | sort | uniq | crontab -"

# We finally add a cron job to update IP every hour
echo "Adding cron job to update IP every hour..."
echo "Done!"


# Let's test whether it works... ----------------------------------------------
echo ""
echo "To test the script, run dyndns.sh and then getip_$HOST.sh"
echo "You should see the IP address of $HOST in both cases."
# echo "testing dyndns.sh..."
# source dyndns.sh
# echo "testing getip.sh..."
# source getip.sh
