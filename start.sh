#!/bin/bash

# set hostname (requires INITSYSTEM)
# https://docs.resin.io/runtime/runtime/#change-the-device-hostname
DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket \
  dbus-send \
  --system \
  --print-reply \
  --reply-timeout=2000 \
  --type=method_call \
  --dest=org.freedesktop.hostname1 \
  /org/freedesktop/hostname1 \
  org.freedesktop.hostname1.SetStaticHostname \
  string:$URL_HOSTNAME boolean:true

echo "start.sh: set hostname from \$URL_HOSTNAME to $URL_HOSTNAME"
echo "start.sh: forever.js starting kijani-poller + streamlink"

forever start -o out.log -e err.log -f --spinSleepTime 500 kijani-poller.js
forever logs kijani-poller.js -f
