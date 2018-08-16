#!/bin/bash
# Replaces the IP address in smartDeviceLink.ini with the machine's IP address and then runs SmartDeviceLink Core.
# The IP is required to be replaced for the websocket connection with the HMI to function.

# Get the machine's IP address
DOCKER_IP="$(ip addr show ${CORE_NETWORK_INTERFACE} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)"
echo "Changing smartDeviceLink.ini HMI ServerAddress to ${DOCKER_IP}"
echo "Running core version ${CORE_VERSION}"

# Replace the IP address in smartDeviceLink.ini with the machines IP address
perl -pi -e 's/127.0.0.1/'$DOCKER_IP'/g' /usr/build/bin/smartDeviceLink.ini

# Set the default preloaded policy table to allow access to everything....... everything
perl -pi -e 's/\[\"Base-4\"\]/\[\"Base-4\", \"Location-1\", \"Notifications\", \"DrivingCharacteristics-3\", \"VehicleInfo-3\", \"PropriataryData-1\", \"PropriataryData-2\", \"ProprietaryData-3\", \"Emergency-1\", \"Navigation-1\", \"Base-6\", \"OnKeyboardInputOnlyGroup\", \"OnTouchEventOnlyGroup\", \"DiagnosticMessageOnly\", \"DataConsent-2\", \"BaseBeforeDataConsent\", \"SendLocation\", \"WayPoints\", \"BackgroundAPT\", \"Notifications-RC\", \"RemoteControl\", \"HapticGroup\"\],\n\"moduleType\"\: \[\"CLIMATE\", \"RADIO\"\] /g' /usr/build/bin/sdl_preloaded_pt.json

# Add the ability to send logs to stdout. Do not write logs to file
perl -pi -e 's/ALL, SmartDeviceLinkCoreLogFile/ALL, SmartDeviceLinkCoreLogFile/g' /usr/build/bin/log4cxx.properties

# Replace IP and Port in broker index.js file with the DOCKER_IP
perl -pi -e "s/localhost:8087/$DOCKER_IP:8087/g" /usr/web/broker/index.js

#Start supervisord
/usr/bin/supervisord
