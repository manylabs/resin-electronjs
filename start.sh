#!/bin/bash

echo "in" pwd
echo "Dockerfile CMD exec: bash start.sh"

forever start -o /app/out.log --spinSleepTime 500 kijani-poller.js
forever logs kijani-poller.js
