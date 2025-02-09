#!/bin/bash
cd /home/container

# Output Current Java Version
java -version

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1`

# Check auto update is on
if [ "${AUTO_UPDATE}" == "1" ]; then
	echo "Checking for updates..."

	LATEST_HASH=`curl -s https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/${UPDATE_BRANCH}/lastSuccessfulBuild/api/xml?xpath=//lastBuiltRevision/SHA1 | sed 's/.*>\(.*\)<.*/\1/'`
	CURRENT_HASH=`cat .currenthash 2>/dev/null`

	if [ "$LATEST_HASH" != "$CURRENT_HASH" ]; then
		echo "Update available!"
		echo "Updating from '$CURRENT_HASH' -> '$LATEST_HASH'"
		curl -s -o ${SERVER_JARFILE} https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/${UPDATE_BRANCH}/lastSuccessfulBuild/artifact/bootstrap/standalone/target/Geyser.jar

		echo "$LATEST_HASH" > ".currenthash"
		echo "Updated!"
	else
		echo "No update available"
	fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
