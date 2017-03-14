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
echo "start.sh: entering infinite loop (restarts streamlink when it crashes)"

while true
do
  # TODO add non-root user to exec this script
  # stream source: http://www.ustream.tv/channel/iss-hdev-payload
  streamlink --player "omxplayer --timeout 20 --live" --player-fifo --retry-open 2 --retry-streams 2 --stream-segment-timeout 2 --stream-segment-attempts 6 $URL_LAUNCHER_URL $STREAMLINK_QUALITY
done

# livestreamer -l debug --verbose-player --hls-segment-threads 2 --hls-live-edge 8 --yes-run-as-root --player "omxplayer --timeout 10" --player-no-close --fifo http://ustream.tv/channel/iss-hdev-payload mobile_720p
