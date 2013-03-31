/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "BLWebSocketsServer.h"



@interface WebsocketserverModule : TiModule <WebSocketServerDelegate, UIAccelerometerDelegate>
{
    KrollCallback *receiveCallback;

    BLWebSocketsServer *server;
    
    UIAccelerometer *accelerometer;
}


@end
