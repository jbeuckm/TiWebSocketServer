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

-(void) initServer:(id)args
{
	NSLog(@"[INFO] websocketserver.initServer() %@", args);

//    ENSURE_UI_THREAD_1_ARG(args);
    
    ENSURE_SINGLE_ARG(args, NSDictionary);
/*
    id receive = [args objectForKey:@"receive"];
    
    RELEASE_TO_NIL(receiveCallback);

    receiveCallback = [receive retain];
*/    
    
    NSInteger port = [TiUtils intValue:[args objectForKey:@"port"]];
    NSString *protocol = [TiUtils stringValue:[args objectForKey:@"protocol"]];
    
    server = [[BLWebSocketsServer alloc] initWithPort:port andProtocolName:protocol];

    [server setHandleRequestBlock:^NSData *(NSData *data) {
        NSLog(@"[INFO] data received");
//        [self _fireEventToListener:@"receive" withObject:data listener:receiveCallback thisObject:nil];
        return data;
    }];

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

@end
