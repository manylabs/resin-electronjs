# resin-electronjs-piscreen

A resin.io + electronjs app for raspberry pi that streams the [live ustream video feed](http://www.ustream.tv/channel/iss-hdev-payload) from NASA's [High Definition Earth-Viewing System](https://eol.jsc.nasa.gov/ESRS/HDEV/) payload on the ISS.

Forked from [resin.io electronJS application template](https://github.com/resin-io/resin-electronjs)

## piscreen setup - ISS HDEV stream

1. work on the `ISS` branch

2. set [environment variables](https://docs.resin.io/management/env-vars/) via resin dashboard
  ```
  URL_LAUNCHER_WIDTH=1280
  URL_LAUNCHER_KIOSK=1
  URL_LAUNCHER_TITLE=ISS HDEV payload - USTREAM
  URL_LAUNCHER_HEIGHT=1024
  URL_LAUNCHER_URL=http://ustream.tv/channel/iss-hdev-payload/pop-out
  URL_HOSTNAME=piscreen-ISS-HDEV
  URL_LAUNCHER_CONSOLE=0
  RESIN_HOST_CONFIG_gpu_mem=160
  ```

3. notes

  - usb wifi dongle: `74:DA:38:41:B7:A1`
  - iss ustream: http://ustream.tv/channel/iss-hdev-payload/pop-out
  - spacex live webcast: https://www.youtube.com/embed/lZmqbL-hz7U?rel=0&autoplay=1&loop=1
  - yule log: https://www.youtube.com/embed/97g1krDkzNI?rel=0&autoplay=1&loop=1&playlist=97g1krDkzNI
  - see `[streamlink](https://github.com/manylabs/resin-electronjs-piscreen/tree/streamlink)` branch for experimental headless (skip electronjs) omxplayer build. omxplayer (only?) video player that can decode video on pi w/ hardware acceleration. depends on livestreamer / streamlink package, neither of which currently work reliably w/ ustream.com streams.

## Getting started

- access devices via Manylab's [resin.io](https://dashboard.resin.io/) acct
- learn about resin.io IoT management platform by reading the [getting started guide](http://docs.resin.io/raspberrypi/nodejs/getting-started/)
- clone this repository to your local workspace
- add the _resin remote_ to your local workspace using the useful shortcut in the dashboard UI ![remoteadd](https://raw.githubusercontent.com/resin-io-playground/boombeastic/master/docs/gitresinremote.png)
- work in the `ISS` branch.
- deploy to device with `git push resin ISS:master`
- see the magic happening, your device is getting updated Over-The-Air!
- *optional:* get updates made to the main [resin-electronjs repo](https://github.com/resin-io/resin-electronjs). Add it as a [remote fork](https://help.github.com/articles/configuring-a-remote-for-a-fork/):

  1. `git remote add upstream https://github.com/resin-io/resin-electronjs.git`
  2. `git fetch upstream` (checks out into local `upstream/master` branch)
  3. `git checkout master`
  4. `git merge upstream/master` (merge upstream fork into local `master`)
  5. `git checkout ISS`
  6. `git merge upstream/master` (merge upstream fork into local `ISS`)


### URL LAUNCHER config via ENV VARS

simply set these [environment varables](http://docs.resin.io/#/pages/management/env-vars.md) in your app via "Environment Variables" panel in the resin dashboard to configure the behaviour of your devices.

Manylabs-specific:

* **`URL_HOSTNAME`** set device hostname

Included in resin-electronjs template:

* **`URL_LAUNCHER_URL`** *string* - the URL to be loaded. use `file:////usr/src/app/data/index.html` to load a local electronJS (or any website) app - *defaults to* `file:////usr/src/app/data/index.html`
* **`URL_LAUNCHER_NODE`** *bool* (converted from *string*) - whether or not enable nodejs - *defaults to* `0`
* **`URL_LAUNCHER_KIOSK`** *bool* (converted from *string*) - whether or not enter KIOSK mode - *defaults to* `1`
* **`URL_LAUNCHER_TITLE`** *string* - the title of the window. Seen only with `URL_LAUNCHER_FRAME`=`true` - *defaults to* `RESIN.IO`
* **`URL_LAUNCHER_FRAME`** *bool* (converted from *string*) - set to "true" to display the window frame. Seen only with `URL_LAUNCHER_KIOSK`=`false` - *defaults to*  `0`
* **`URL_LAUNCHER_CONSOLE`** *bool* (converted from *string*) - set to "true" to display the debug console -  *defaults to*  `0`
* **`URL_LAUNCHER_WIDTH`**  *int* (converted from *string*) -  - *defaults to* `1920`
* **`URL_LAUNCHER_HEIGHT`**  *int* (converted from *string*) -  - *defaults to* `1080`
* **`URL_LAUNCHER_TOUCH`** *bool* (converted from *string*) - enables touch events if your device supports them  - *defaults to* `0`
* **`URL_LAUNCHER_TOUCH_SIMULATE`** *bool* (converted from *string*) - simulates touch events - might be useful for touchscreen with partial driver support - be aware this could be a performance hog  - *defaults to* `0`
* **`URL_LAUNCHER_ZOOM`** *float* (converted from *string*) - The default zoom factor of the page, 3.0 represents 300%  - *defaults to* `1.0`
* **`URL_LAUNCHER_OVERLAY_SCROLLBARS`** *bool* (converted from *string*) - enables overlay scrollbars  - *defaults to* `0`
