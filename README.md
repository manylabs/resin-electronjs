# Manylabs iss-streamer

A resin.io app for raspberry pi that streams the [live ustream video feed](http://www.ustream.tv/channel/iss-hdev-payload) from NASA's [High Definition Earth-Viewing System](https://eol.jsc.nasa.gov/ESRS/HDEV/) payload on the ISS.

Adapted from Miguel Grinberg's post "[Watch Live Video of Earth on your Raspberry Pi](https://blog.miguelgrinberg.com/post/watch-live-video-of-earth-on-your-raspberry-pi)". He shows how to use `livestreamer`

The ISS completes a full orbit roughly every 90 minutes. The video transmission is only active when the ISS is above the day-side of the earth, so expect the video feed to alternate from live to gray screen every 45 minutes. Find out where the ISS is with [ESA ISS tracker](http://wsn.spaceflight.esa.int/iss/index_portal.php) or [isstracker.com](http://www.isstracker.com).

**Note:** this branch is currently not working well because the ustream plugin in [streamlink](https://github.com/streamlink/streamlink) (the active fork of livestreamer) is not reliable. The following forks of streamlink have work-in-progress ustream plugins that *may* work. This branch currently uses [beardypig websockets](https://github.com/beardypig/streamlink/tree/ustream-websockets).
- [beardypig/streamlink:ustream-websockets](https://github.com/beardypig/streamlink/tree/ustream-websockets) ([ustream plugin src](https://github.com/beardypig/streamlink/blob/ustream-websockets/src/streamlink/plugins/ustreamtv.py))
- [Tristanx/streamlink:master](https://github.com/Tristanx/streamlink) ([ustream plugin src](https://github.com/Tristanx/streamlink/blob/master/src/streamlink/plugins/ustreamtv.py))
- [Tristanx vs. beardypig comparison](https://github.com/Tristanx/streamlink/compare/master...beardypig:ae149acd)
- [beardypig PR discussion](https://github.com/streamlink/streamlink/pull/137)

### related RPI web kiosk display projects
- DIY Smart Television with RaspberryPi and Node.js http://blog.donaldderek.com/2013/06/build-your-own-google-tv-using-raspberrypi-nodejs-and-socket-io/
- HOWTO: Boot your Raspberry Pi into a fullscreen browser kiosk https://blogs.wcode.org/2013/09/howto-boot-your-raspberry-pi-into-a-fullscreen-browser-kiosk/
- boot rpi into web browser kiosk w/ and w/o desktop https://github.com/MobilityLab/TransitScreen/wiki/Raspberry-Pi
- [Urthecast live stream](https://www.urthecast.com/live/) (may be more stable than ustream)
  > "I've found another stream that has probably better availability. It is from urthecast.com project.
  > The chunks have to be grabbed from: https://d2ai41bknpka2u.cloudfront.net/live/iss.stream_source/chunklist.m3u8
  > Then the chunk link will look like: https://d2ai41bknpka2u.cloudfront.net/live/iss.stream_source/media-upp83ggdj_25765.ts"

## setup
1. follow the setup instructions in the README of the `master` or `ISS` branches.
2. set the following environment variable on resin.io device dashboard:
  - `STREAMLINK_QUALITY`: `mobile_720p`
  - note: this build of streamlink will also support "desktop streams" from ustream, but they are slower w/ the pi (crappy wifi dongle?). to try, use `720p` or `best` instead of `mobile_720p`.

### Dev notes
ssh access:
- get ip from resin.io dashboard
- ssh root@<ip-address> (p=resin)
- don't forget to change passwd
- SSH refuse to connect, mentioning MTM worry?
  - remove key from local machine
  - ssh-keygen -R <YOUR-DEVICE'S-IP>
  - https://github.com/resin-io-projects/resin-openssh
- env variables not showing up in ssh terminal session?
  - https://docs.resin.io/runtime/runtime/#using-resin-ssh-from-the-cli

python virtual environments - handy for local dev testing
- create local: `python3 -m venv streamlinkenv`
- activate: `. streamlinkenv/bin/activate.fish`
- install package dev mode & save install paths in case of screw up: `python3 setup.py develop --record files.txt`
- remove all installed files: `cat files.txt | xargs rm -rf`

#### rpi + omxplayer
- needs config.txt gpu_mem set > 64mb
  - set resin Device Config Variables like so: `RESIN_HOST_CONFIG_gpu_mem=128`
  - see https://docs.resin.io/configuration/advanced/#modifying-config-txt-remotely-
- see this issue for more omxplayer-specifc rpi config.txt settings:
  - https://github.com/popcornmix/omxplayer/issues/454

### streamlink command examples
```bash
streamlink --stream-segment-threads 2 -l debug --player "omxplayer --timeout 20 --win \"0 0 1600 1200\"" --player-fifo http://www.ustream.tv/channel/iss-hdev-payload  mobile_480p

streamlink -l debug --verbose-player --player "omxplayer --timeout 20 --win \"0 0 1600 1200\"" --player-fifo http://www.ustream.tv/channel/iss-hdev-payload best

streamlink -l debug --verbose-player --stdout http://www.ustream.tv/channel/iss-hdev-payload mobile_480p
```

### KijaniGrows ML light sensor
- seems to be >100 lumens when lights are on
- seems to be <75 (~50) lumens when lights are off at night
- json api:
```
curl 'http://api.kijanigrows.com/v2/device/sensors/json/manylabs' -H 'If-None-Match: W/"111e-kiUKqL33fAiDd0Uuujy/ww"' -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept: application/json' -H 'Referer: http://github.com/manylabs/resin-electronjs-piscreen/' --compressed
```
