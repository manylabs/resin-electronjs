#!/bin/bash

echo 'streamlink mock bash script'
echo 'iss-streamer.sh: entering infinite restart loop'

args=("$@")
echo $# arguments passed
echo args[0] ${args[0]}
echo args[1] ${args[1]}
echo args[2] ${args[2]}
echo URL_LAUNCHER_URL $URL_LAUNCHER_URL
echo STREAMLINK_QUALITY $STREAMLINK_QUALITY

while true
do
  # TODO add non-root user to exec this script
  # stream source: http://www.ustream.tv/channel/iss-hdev-payload
  # streamlink --player "omxplayer --timeout 20 --live --aspect-mode fill" --player-fifo --retry-open 2 --retry-streams 2 --stream-segment-timeout 2 --stream-segment-attempts 6 $URL_LAUNCHER_URL $STREAMLINK_QUALITY
  echo "streamlink running (fake; sleep 2)"
  sleep 2
done
