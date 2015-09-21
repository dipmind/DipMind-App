//
//  MindwaveTCP.h
//  hello.world
//
//  Created by X Y on 27/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGAccessoryDelegate.h"

@interface MindwaveTCP : NSObject <NSStreamDelegate, TGAccessoryDelegate>
    
     //= CFSTR("10.20.10.69");
    // = 3003;
    
    



@property CFStringRef SERVER_ADDR;
@property int SERVER_PORT;

@property bool mindwave_connected;// = false
@property bool tcp_connected ;//= false;
@property bool wifiActive;

extern NSString *kReachabilityChangedNotification;


@property (retain) NSOutputStream *outputStream;
@property (retain) NSTimer *tcpConnectionTimer;

-(id)init;

- (void)initNetworkCommunication;
/*- (void) offBluetoothConn;
- (void) onBluetoothConn;*/
-(void)stopTcpConn;


@end
