//
//  VideoTCP.m
//  hello.world
//
//  Created by X Y on 18/05/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "VideoTCP.h"

@implementation VideoTCP

@synthesize delegate;

- (id)initWithServerIP:(NSString*) address {
    self = [super init];
    
    if (self) {
        self.SERVER_PORT = 3005;
        self.SERVER_ADDR = address;
        
        self.tcp_connected = false;
    }
    
    self.tcpConnectionTimer = [NSTimer timerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(connect)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.tcpConnectionTimer forMode:NSRunLoopCommonModes];
    
    return self;
}


-(void) connect {
    if (!self.tcp_connected) {
        
        //CFWriteStreamRef writeStream;
        CFReadStreamRef readStream;
        
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.SERVER_ADDR, self.SERVER_PORT, &readStream, NULL);
        self.inputStream = (__bridge NSInputStream *)(readStream);
        //self.outputStream = (__bridge NSOutputStream *)(writeStream);
    
        [self.inputStream setDelegate:self];
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        //[self.outputStream setDelegate:self];
        //[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    
        [self.inputStream open];
        //[self.outputStream open];
    
    } else {
        [self.tcpConnectionTimer invalidate];
    
    }
}

-(void)stream:(NSStream *)s handleEvent:(NSStreamEvent)eventCode {
    //NSLog(@"Event code:%d", eventCode);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Porta 3005 Stream event: OpenCompleted");
            self.tcp_connected = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTcp_true" object:self];
           // [self.outputStream write:"ciao" maxLength:4];
            //[self.delegate videotcp_connection_opened:self]; //this will call the method implemented in your other class
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Porta 3005 Stream event: HasSpace");
            break;
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"Porta 3005 Stream event: HasBytes");
            uint8_t buffer[2048];
            int len = [self.inputStream read:buffer maxLength:2048];
            //NSLog(@"%d",len);

            //NSString *result = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
            
            NSError *jsonError;
            NSData *objectData = [NSData dataWithBytes:buffer length:len];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];

            //NSLog(result);
            
            if (json != nil) {
                if ([json[@"command"] isEqualToString:@"start"]) {
                    [self.delegate videotcp_connection_opened:self];
                } else if ([json[@"command"] isEqualToString:@"stop"]) {
                    [self.delegate videotcp_connection_closed:self];
                } else {
                    [self.delegate videotcp_command:self withJSON:json];
                }
            } else {
                NSLog(@"** videoTCP: unrecognized command '%@'", [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding]);
            }
            
            break;
        }
        case NSStreamEventEndEncountered:
            NSLog(@"Porta 3005Stream event: EndEncountered");
            [self terminateTcpConn];
            [self.delegate videotcp_connection_closed:self];
            self.tcpConnectionTimer = [NSTimer timerWithTimeInterval:2.0
                                                              target:self
                                                            selector:@selector(connect)
                                                            userInfo:nil repeats:YES];
            
            [[NSRunLoop mainRunLoop] addTimer:self.tcpConnectionTimer forMode:NSRunLoopCommonModes];
            break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Porta 3005 Stream event: ErrorOccurred");
            NSError *theError =[s streamError];
            NSLog(@"Porta 3005 %@", [NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]]);
            if([theError code] == 32) {// Error 32: The operation couldn’t be completed. Broken pipe
                [self terminateTcpConn];
                self.tcpConnectionTimer = [NSTimer timerWithTimeInterval:2.0
                                                                  target:self
                                                                selector:@selector(connect)
                                                                userInfo:nil repeats:YES];
                
                [[NSRunLoop mainRunLoop] addTimer:self.tcpConnectionTimer forMode:NSRunLoopCommonModes];
            }
            
            break;
        }
        default:
            NSLog(@"Porta 3005 Stream event: altro");
            break;
    }
}


-(void)terminateTcpConn {
    [self.inputStream close];
    //[self.outputStream close];
    self.tcp_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTcp_false" object:self];
    // [self.tcpConnectionTimer invalidate];
}

-(void)stopTcpConn {
    [self.inputStream close];
    //[self.outputStream close];
    self.tcp_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTcp_false" object:self];
    [self.tcpConnectionTimer invalidate];
}


@end
