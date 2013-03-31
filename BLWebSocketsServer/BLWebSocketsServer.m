//
//  BLWebSocketServer.m
//  LibWebSocket
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "BLWebSocketsServer.h"

static int pollingInterval = 20;
static char * http_only_protocol = "http-only";

struct libwebsocket *_wsi;

id <WebSocketServerDelegate> cDelegate;


//BLWebSocketsHandleRequestBlock _handleRequestBlock;
/* Context representing the server*/
struct libwebsocket_context *context;
int callback(struct libwebsocket_context * this,
             struct libwebsocket *wsi,
             enum libwebsocket_callback_reasons reason,
             void *user, void *in, size_t len);


static int callback_http(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{
    return 0;
}

@interface BLWebSocketsServer()

@property (nonatomic, assign) int port;
@property (nonatomic, assign) NSString *protocolName;
/*Using atomic in our case is sufficient to ensure thread safety*/
@property (atomic, assign, readwrite) BOOL isRunning;

@end

@implementation BLWebSocketsServer

@synthesize delegate;

/*
#pragma mark - Custom getters and setters
- (void)setHandleRequestBlock:(BLWebSocketsHandleRequestBlock)block {
    _handleRequestBlock = block;
}
*/

- (void)setCDelegate:(id <WebSocketServerDelegate>)d
{
    cDelegate = d;
}


#pragma mark - Initialization
- (id)init {
    return [self initWithPort:9000 andProtocolName:@""];
}

/*Designated initializer*/
- (id)initWithPort:(int)port andProtocolName:(NSString *)protocolName {
    self = [super init];
    if (self) {
//        _handleRequestBlock = nil;
        self.port = port;
        self.protocolName = protocolName;
    }
    return self;
}

#pragma mark - Server management
- (void)start {
    
    NSLog(@"%@", @"Starting server");
    
    if (self.isRunning) {
        return;
    }
    else {
        self.isRunning = YES;
    }
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    dispatch_async(queue, ^{
        
        struct libwebsocket_protocols protocols[] = {
            /* first protocol must always be HTTP handler */
            {
                http_only_protocol,
                callback_http,
                0
            },
            {
                [self.protocolName cStringUsingEncoding:NSASCIIStringEncoding],
                callback,   // callback
                0            // we don't use any per session data
                
            },
            {
                NULL, NULL, 0   /* End of list */
            }
        };
        context = libwebsocket_create_context(self.port, NULL, protocols,
                                              libwebsocket_internal_extensions,
                                              NULL, NULL, NULL, -1, -1, 0, NULL);
        
        if (context == NULL) {
            NSLog(@"[ERROR] Initialization of the websockets server failed");
        }
        
        /*For now infinite loop which proceses events and wait for n ms. See how we could use poll() or select()*/
        while (self.isRunning && context) {
            libwebsocket_service(context, pollingInterval);
        }
        
        NSLog(@"[INFO] Stopping server");
        libwebsocket_context_destroy(context);
        context = NULL;
        
    });
    
}


unsigned char *send_buf;
int data_length;
bool data_ready = false;

- (void)asyncSend:(NSData *)data
{
    send_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + data.length +LWS_SEND_BUFFER_POST_PADDING);

    bcopy([data bytes], &send_buf[LWS_SEND_BUFFER_PRE_PADDING], data.length);
    
    data_length = data.length;

    data_ready = true;
}



- (void)send:(NSData *)data
{
    send_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + data.length +LWS_SEND_BUFFER_POST_PADDING);
    
    bcopy([data bytes], &send_buf[LWS_SEND_BUFFER_PRE_PADDING], data.length);
    
    libwebsocket_write(_wsi, &send_buf[LWS_SEND_BUFFER_PRE_PADDING], data.length, LWS_WRITE_TEXT);

    free(send_buf);
}



- (void)stop {
    
    if (!self.isRunning) {
        return;
    }
    else {
        self.isRunning = NO;
    }
}

@end

int callback(struct libwebsocket_context * this,
             struct libwebsocket *wsi,
             enum libwebsocket_callback_reasons reason,
             void *user, void *in, size_t len) {

    switch (reason) {
        
        case LWS_CALLBACK_ESTABLISHED:
            NSLog(@"[INFO] Connection established");
            [cDelegate performSelector:@selector(connectionEstablished)];
            _wsi = wsi;
            break;
        
        case LWS_CALLBACK_RECEIVE: {
            unsigned char *response_buf;
            NSData *data = [NSData dataWithBytes:(const void *)in length:len];
            
            [data retain];
            [cDelegate received:data];

/*
            NSData *response = nil;
            if (_handleRequestBlock) {
                response = _handleRequestBlock(data);
            }
            response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + response.length +LWS_SEND_BUFFER_POST_PADDING);
            bcopy([response bytes], &response_buf[LWS_SEND_BUFFER_PRE_PADDING], response.length);
            libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_TEXT);
            free(response_buf);
*/
            break;
        }
            
        case LWS_CALLBACK_SERVER_WRITEABLE: {
            if (!data_ready) {
                libwebsocket_callback_on_writable(context, wsi);
                return 0;
            }

            libwebsocket_write(wsi, &send_buf[LWS_SEND_BUFFER_PRE_PADDING], data_length, LWS_WRITE_TEXT);
            free(send_buf);
            data_ready = false;
            
            libwebsocket_callback_on_writable(context, wsi);
            break;
        }

        default:
            break;
    }
    
    return 0;
}

