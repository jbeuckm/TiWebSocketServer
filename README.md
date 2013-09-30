TiWebSocketServer
=================

Titanium module wrapper for Benjamin Loulier's BLWebSocketsServer

### Usage: ###

```javascript

var server = require('websocketserver');

server.initServer({
    port: 9000,
    protocol: 'sensor',
    receive: function(data) {
        Ti.API.info('received '+JSON.stringify(data));
    }
});

server.addEventListener('connectionEstablished', function(){
    Ti.API.info('connectionEstablished');
    server.startAccelerometer({ updateInterval: .05 });
});

server.start();


server.addEventListener('accelerometer', function(data){
    Ti.API.info(data.x+','+data.y+','+data.z)
});

```
