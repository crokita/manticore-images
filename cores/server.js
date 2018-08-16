const WebSocket = require('ws');
const ts = require('tail-stream');
const FILE_PATH = '/usr/build/bin/SmartDeviceLinkCore.log';

const wss = new WebSocket.Server({
    port: 8888
});

wss.on('connection', function (ws) {
	const buffer = [];
	//tail stream the contents of the file
    const tstream = ts.createReadStream(FILE_PATH, {
        beginAt: 0,
        endOnError: false
    });
    //update the contents of the file in a buffer
    tstream.on('data', function (data) {
    	buffer.push(data);
    	sendData();
    });

    ws.on('message', function () {
    });

    function sendData () {
		if (buffer.length > 0) {
    		ws.send(buffer.shift());
    	}    	
    }
});