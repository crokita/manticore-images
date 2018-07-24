#!/bin/bash
echo "Changing Flags.js Broker ServerAddress to ${BROKER_ADDR}"
echo "Changing Nginx file proxy address to ${CORE_FILE_ADDR}"
# Replace IP and Port in Controller file with the address to the broker
# The address for the broker is REQUIRED to include the protocol (ex. ws://localhost:80)
perl -pi -e "s/ws:\/\/localhost:8087/$BROKER_ADDR/g" /usr/app/webapp/build/bundle.js
# The HMI doesn't specify a subprotocol! We need it to specify echo-protocol when requesting
# a connection, otherwise the sdl_broker will deny the connection!
perl -pi -e "s/WebSocket\(url\)/WebSocket\(url, \['echo-protocol'\]\)/g" /usr/app/webapp/build/bundle.js
# Replace XXXXX in the nginx conf file with the address of sdl_core
perl -pi -e "s/XXXXX/$CORE_FILE_ADDR/g" /etc/nginx/nginx.conf
# Start nginx
/usr/sbin/nginx
