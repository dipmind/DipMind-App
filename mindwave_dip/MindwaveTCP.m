//
//  MindwaveTCP.m
//  hello.world
//
//  Created by X Y on 27/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "MindwaveTCP.h"
#import "TGAccessoryManager.h"


@implementation MindwaveTCP

- (id)init {
    self = [super init];
    
    if (self) {
        self.SERVER_PORT = 3003;
        self.SERVER_ADDR = CFSTR("10.20.10.69");
        
        self.mindwave_connected = false;
        self.tcp_connected = false;
        self.wifiActive = false;
        
        [[TGAccessoryManager sharedTGAccessoryManager] setDelegate: self];
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.2];
    }
    
    return self;
}

- (void)initNetworkCommunication {
    NSLog(@"initNetworkCommunication");
    
    if(!self.tcp_connected && self.wifiActive == true) {
         NSLog(@"Non connesso.");
        
    
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)self.SERVER_ADDR, self.SERVER_PORT, NULL, &writeStream);
        self.outputStream = (__bridge NSOutputStream *)(writeStream);
    
        [self.outputStream setDelegate:self];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
        [self.outputStream open];
    
    } else {
        [self.tcpConnectionTimer invalidate];
    }
}

-(void)stream:(NSStream *) s handleEvent:(NSStreamEvent)eventCode {
    //NSLog(@"Event code:%d", eventCode);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream event: OpenCompleted");
            self.tcp_connected = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveTcp_true" object:self];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream event: HasSpace");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"Stream event: EndEncountered");
            self.tcp_connected = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveTcp_false" object:self];
            break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream event: ErrorOccurred");
            NSError *theError =[s streamError];
            NSLog(@"%@", [NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]]);
            if([theError code] == 32) {// Error 32: The operation couldn’t be completed. Broken pipe
                [self terminateTcpConn];
                self.tcpConnectionTimer = [NSTimer timerWithTimeInterval:2.0
                                                                  target:self
                                                                selector:@selector(initNetworkCommunication)
                                                                userInfo:nil repeats:YES];
                
                [[NSRunLoop mainRunLoop] addTimer:self.tcpConnectionTimer forMode:NSRunLoopCommonModes];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)accessoryDidConnect:(EAAccessory *)accessory {
    self.tcpConnectionTimer = [NSTimer timerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(initNetworkCommunication)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.tcpConnectionTimer forMode:NSRunLoopCommonModes];
    
    self.mindwave_connected = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveBluetooth_true" object:self];
    
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    
    NSLog(@"%s", "*** MindWave connesso.");
}

-(void)terminateTcpConn {
    [self.outputStream close];
    self.tcp_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveTcp_false" object:self];
}

-(void)stopTcpConn {
    [self accessoryDidDisconnect];
}

- (void)accessoryDidDisconnect {
    self.mindwave_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveBluetooth_true" object:self];
    
    [[TGAccessoryManager sharedTGAccessoryManager] stopStream];
    
    [self terminateTcpConn];
    [self.tcpConnectionTimer invalidate];
    
    NSLog(@"%s", "*** MindWave disconnesso.");
}

- (void)dataReceived:(NSDictionary *)data {
    
    NSLog(@"Stato stream: %d",self.outputStream.streamStatus);
    
    if(self.tcp_connected) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
        NSString *result = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        [self.outputStream write:[jsonData bytes] maxLength:[jsonData length]];
        
        NSLog(@"Dati MindWave:\n%@", result);
    }
    
}


@end
