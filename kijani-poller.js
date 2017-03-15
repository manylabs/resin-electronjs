const forever = require('forever-monitor');
const request = require("request");

// `npm start`:
// forever start --spinSleepTime 500 kijani-poller.js; forever logs kijani-poller.js -f

// mock streamlink script for testing if not on resin.io rpi "production"
const command = process.env.RESIN_APP_NAME ? 'streamlink' : './streamlink-mock.sh';
const POLL_FREQUENCY = process.env.KIJANI_POLL_FREQUENCY || 30000;
const LUX_THRESHOLD = process.env.KIJANI_LUX_THRESHOLD || 75;

// these defaults cause immediate OFF -> ON transition, starting streamlink
var LIGHT_STATE = 'OFF';
var oldLux = LUX_THRESHOLD;
var luxAvr = LUX_THRESHOLD + 1;

const streamlink_args = [`${command} --config .streamlinkrc ${process.env.URL_LAUNCHER_URL} ${process.env.STREAMLINK_QUALITY}`];
const streamlink = new (forever.Monitor)( streamlink_args, {
  'silent': true,
  'minUptime': 2000,
  'spinSleepTime': 10000
});

streamlink.on('start', function () {
  console.log(`started ${command}`);
});

streamlink.on('stop', function () {
  console.log(`stopped ${command}`);
});

streamlink.on('restart', function() {
    if(! streamlink.times % 50) {
      console.error(`Forever has restarted ${command} ${streamlink.times} times`);
    }
});

// streamlink.on('exit:code', function (code) {
//   console.log(`exited ${command} with code ${code}`);
// });

streamlink.on('error:err', function (err) {
  console.error(`streamlink error: ${err}`);
});

const getLux = function(){
  const options = {
      uri: 'http://api.kijanigrows.com/v2/device/sensors/json/manylabs',
      method: 'GET',
      json:true
  }
  request(options, function(error, response, body){
      if(error){
        console.error(error);
      }
      else {
        let lux = oldLux;
        let oldLuxAvr = luxAvr;

        try {
          lux = body.pins.photocell_sensor.value;
          if (process.env.NODE_DEBUG) console.log(`${(lux > luxAvr) ? '🔆' : '🔅'}  ${lux} lux`)
        }
        catch (err) {
          console.error('error parsing kijanigrows JSON response: \n' + body);
        }

        luxAvr = (oldLux + lux) / 2;
        oldLux = lux;
        if (Math.abs(oldLuxAvr - luxAvr) > 100) console.log(`💡 ${oldLuxAvr} => ${luxAvr}`);
      }
  });
}

const poll = function(){
  // asynch req to set luxAvr (averge of last two successful requests)
  getLux();

  // state machine
  switch (LIGHT_STATE) {

    case 'ON':
      if (luxAvr < LUX_THRESHOLD) {
        LIGHT_STATE = 'OFF';
        console.log(`🌃  ${luxAvr} < ${LUX_THRESHOLD} lux; stopping ${command}`);
        streamlink.stop();
      }
      break

    case 'OFF':
      if (luxAvr > LUX_THRESHOLD) {
        LIGHT_STATE = 'ON';
        console.log(`🌇  ${luxAvr} > ${LUX_THRESHOLD} lux; starting ${command}`);
        streamlink.start();
      }
      break

    default:
      LIGHT_STATE = 'ON';
      luxAvr = LUX_THRESHOLD +1;
      streamlink.start();
  }
}

// main loop - call poll() every 20 seconds
setInterval(poll, 30000);
