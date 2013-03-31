//
//  BLWebSocketServer.h
//  LibWebSocket
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libwebsockets.h"

typedef NSData *(^BLWebSocketsHandleRequestBlock)(NSData * requestData);


@protocol WebSocketServerDelegate <NSObject>

-(void) connectionEstablished;
-(void) received:(NSData *)data;

@end



@interface BLWebSocketsServer : NSObject {
    
    id <WebSocketServerDelegate> delegate;
}
@property (nonatomic,assign) id<WebSocketServerDelegate> delegate;



@property (atomic, assign, readonly) BOOL isRunning;

- (id)initWithPort:(int)port andProtocolName:(NSString *)protocolName;
- (void)start;

- (void)send:(NSData *)data;
- (void)asyncSend:(NSData *)data;

- (void)stop;

- (void)setCDelegate:(id <WebSocketServerDelegate>)d;


@end
