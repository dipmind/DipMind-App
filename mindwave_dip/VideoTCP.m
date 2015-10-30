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
    
    return self;
}

-(void) initNetworkCommunication {
    if (!self.tcp_connected) {
        CFReadStreamRef readStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.SERVER_ADDR, self.SERVER_PORT, &readStream, NULL);
        self.inputStream = (__bridge NSInputStream *)(readStream);
        
        [self.inputStream setDelegate:self];
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        [self.inputStream open];
    }
}

-(void)stream:(NSStream *)s handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"** Evento stream su porta %d: Open Completed", self.SERVER_PORT);
            self.tcp_connected = true;
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTcp_true" object:self];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"** Evento stream su porta %d: Has Space Available", self.SERVER_PORT);
            break;
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"** Evento stream su porta %d: Has Bytes Available", self.SERVER_PORT);
            uint8_t buffer[2048];
            int len = [self.inputStream read:buffer maxLength:2048];
            
            NSError *jsonError;
            NSData *objectData = [NSData dataWithBytes:buffer length:len];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];

            if (json != nil) {
                if ([json[@"command"] isEqualToString:@"start"]) {
                    [self.delegate videotcp_connection_opened:self];
                } else if ([json[@"command"] isEqualToString:@"stop"]) {
                    [self.delegate videotcp_connection_closed:self];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"restartConnections" object:self];
                } else {
                    [self.delegate videotcp_command:self withJSON:json];
                }
            } else {
                NSLog(@"** Comando video non riconosciuto: '%@'.", [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding]);
            }
            
            break;
        }
        case NSStreamEventEndEncountered:
             NSLog(@"** Evento stream su porta %d: End Encountered", self.SERVER_PORT);
            [self.delegate videotcp_connection_closed:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"restartConnections" object:self];
            break;
        case NSStreamEventErrorOccurred: {
            NSError *theError =[s streamError];
            NSLog(@"** Evento stream su porta %d: Error Occurred: error %d - %@", self.SERVER_PORT, [theError code], [theError localizedDescription]);
            
            [self.delegate videotcp_connection_closed:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"networkError" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"restartConnections" object:self];
            break;
        }
        default:
            break;
    }
}


-(void)terminateTcpConn {
    [self.inputStream close];
    self.tcp_connected = false;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTcp_false" object:self];
}


@end
