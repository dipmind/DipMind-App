//
//  MindwaveTCP.h
//  hello.world
//
//  Created by X Y on 27/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MindwaveTCP : NSObject <NSStreamDelegate>

@property (retain) NSString* SERVER_ADDR;
@property int SERVER_PORT;

@property bool tcp_connected ;//= false;

//extern NSString *kReachabilityChangedNotification;


@property (retain) NSOutputStream *outputStream;
@property (retain) NSTimer *tcpConnectionTimer;

-(id)initWithServerIP:(NSString*) address;

-(void)initNetworkCommunication;

-(void) terminateTcpConn;

-(void)sendData:(NSDictionary*) data;


@end
