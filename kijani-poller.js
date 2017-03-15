const forever = require('forever-monitor');
const request = require("request");

// start with
// forever start -o out.log -e err.log -f --spinSleepTime 500 kijani-poller.js; forever logs kijani-poller.js -f

// use mock streamlink script if not on resin.io rpi "production"
// const path = process.env.RESIN_APP_NAME ? '/usr/local/bin/' : process.env.PWD;
const command = process.env.RESIN_APP_NAME ? 'streamlink' : './streamlink-mock.sh';

// global state vars (naughty)
var LIGHT_STATE = 'ON'
var oldLux = 100;
var luxAvr = 100;

// const streamlink = forever.start([command, path], {
const streamlink = forever.start(command, {
  max: 1,
  // env: {'URL_LAUNCHER_URL': 'http://example.com', 'STREAMLINK_QUALITY': 'mobile_720p'},
  // sourceDir: path,
  command: command,
  args: ['--player "omxplayer --timeout 20 --live --aspect-mode fill" --player-fifo --retry-open 2 --retry-streams 2 --stream-segment-timeout 2 --stream-segment-attempts 6 $URL_LAUNCHER_URL $STREAMLINK_QUALITY'],
});

streamlink.on('start', function () {
  console.log(`started ${command}`);
});

streamlink.on('stop', function () {
  console.log(`stopped ${command}`);
});

streamlink.on('exit:code', function (code) {
  console.log(`exited ${command} with code ${code}`);
});

streamlink.on('error:err', function (err) {
  console.log(`streamlink error: ${err}`);
});

// streamlink.start();

const getLux = function(){
  var options = {
      uri: 'http://api.kijanigrows.com/v2/device/sensors/json/manylabs',
      method: 'GET',
      json:true
  }
  request(options, function(error, response, body){
      if(error) console.log(error);
      else {
        let lux = oldLux;
        try {
          lux = body.pins.photocell_sensor.value;
        } catch (err) {
          console.log('error parsing kijanigrows JSON. Response: \n' + body);
        }
        luxAvr = (oldLux + lux) / 2;
        oldLux = lux;
        return luxAvr;
      }
  });
}

const poll = function(){
  // asynch req sets luxAvr
  getLux();

  // state machine
  switch (LIGHT_STATE) {

    case 'ON':
      if (luxAvr < 70) {
        LIGHT_STATE = 'OFF';
        console.log(`start.js: LUX < 70 (${luxAvr}), stopping ${command}`);
        streamlink.stop();
      }
      //
      break

    case 'OFF':
      if (luxAvr > 70) {
        LIGHT_STATE = 'ON';
        console.log(`start.js: LUX > 70 (${luxAvr}), starting ${command}`);
        streamlink.start();
      }
      break

    default:
      LIGHT_STATE = 'ON';

  }
}

// main loop - call poll() every 20 seconds
setInterval(poll, 20000);
