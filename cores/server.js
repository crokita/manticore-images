const WebSocket = require('ws');
const ts = require('tail-stream');
const FILE_PATH = '/usr/build/bin/SmartDeviceLinkCore.log';

const wss = new WebSocket.Server({
    port: 8888
});

wss.on('connection', function (ws) {
	const buffer = [];
	let requestedData = true;
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
    //pass the contents in the buffer to the client only on request
    ws.on('message', function () {
    	requestedData = true;
    	sendData();
    });

    function sendData () {
		if (buffer.length > 0 && requestedData) {
    		ws.send(buffer.shift());
    		requestedData = false;
    	}    	
    }
});