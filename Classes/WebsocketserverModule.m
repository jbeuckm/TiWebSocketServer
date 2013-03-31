/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "WebsocketserverModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import "IPAddress.h"


@implementation WebsocketserverModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"9efeedd0-c294-4e1c-8691-ed25ed69cce5";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"websocketserver";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs


- (id)networkAddress
{
    NSLog(@"[INFO] getting network address");

    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    int i;
    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;        // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        NSLog(@"[INFO] Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        
        //decided what adapter you want details for
        if (strncmp(if_names[i], "en", 2) == 0)
        {
            NSLog(@"[INFO] Adapter en has a IP of %s", ip_names[i]);
            return [NSString stringWithCString:ip_names[i] encoding:NSUTF8StringEncoding];
        }
    }
    
    return nil;

}


-(void) initServer:(id)args
{
	NSLog(@"[INFO] websocketserver.initServer() %@", args);

    ENSURE_SINGLE_ARG(args, NSDictionary);

    id receive = [args objectForKey:@"receive"];
    
    RELEASE_TO_NIL(receiveCallback);

    receiveCallback = [receive retain];

 
    NSInteger port = [TiUtils intValue:[args objectForKey:@"port"]];
    NSString *protocol = [TiUtils stringValue:[args objectForKey:@"protocol"]];
    
    [protocol retain];
    
    server = [[BLWebSocketsServer alloc] initWithPort:port andProtocolName:protocol];
    
    [server setCDelegate:self];
    
}


-(void) send:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    NSString *string = [TiUtils stringValue:[args objectForKey:@"data"]];
    [server send:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void) start:(id)args
{
	NSLog(@"[INFO] websocketserver.start()");
    [server start];
}

-(void) stop:(id)args
{
	NSLog(@"[INFO] websocketserver.stop()");
    [server stop];
}


-(void) startAccelerometer:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    if (!server.isRunning) {
        return;
    }
    
    accelerometer = [UIAccelerometer sharedAccelerometer];

    CGFloat updateInterval = [TiUtils floatValue:[args objectForKey:@"updateInterval"]];
    
    accelerometer.updateInterval = updateInterval;
    accelerometer.delegate = self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {

    NSString *event = [NSString stringWithFormat:@"{\"x\":%f,\"y\":%f,\"z\":%f}", acceleration.x,acceleration.y,acceleration.z];
    [server send:[event dataUsingEncoding:NSUTF8StringEncoding]];
}





#pragma Delegate Methods

-(void) connectionEstablished
{
    [self fireEvent:@"connectionEstablished" withObject:nil];
}
-(void) received:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: str, @"data", nil];
    [self _fireEventToListener:@"received" withObject:event listener:receiveCallback thisObject:nil];
}


@end
