#!/bin/bash

# using local electron module instead of the global electron lets you
# easily control specific version dependency between your app and electron itself.
# the syntax below starts an X istance with ONLY our electronJS fired up,
# it saves you a LOT of resources avoiding full-desktops envs

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

rm /tmp/.X0-lock &>/dev/null || true
startx /usr/src/app/node_modules/electron/dist/electron /usr/src/app --enable-logging
