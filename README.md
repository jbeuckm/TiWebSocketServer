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
});

server.start();

```

### Bonus! ###

This module has an auxilliary accelerometer reader that can be set to a faster interval than the stock Titanium one.

```javascript

server.startAccelerometer({ updateInterval: .05 });

server.addEventListener('accelerometer', function(data){
    Ti.API.info(data.x+','+data.y+','+data.z)
});

```
