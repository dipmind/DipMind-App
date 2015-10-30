//
//  MindwaveTCP.h
//  hello.world
//
//  Created by X Y on 27/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MindwaveTCP : NSObject <NSStreamDelegate>

@property NSString* SERVER_ADDR;
@property int SERVER_PORT;
@property bool tcp_connected;

@property NSOutputStream *outputStream;


-(id)initWithServerIP:(NSString*) address;

-(void)initNetworkCommunication;

-(void)terminateTcpConn;

-(void)sendData:(NSDictionary*) data;


@end
