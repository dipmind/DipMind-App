//
//  MindwaveTCP.m
//  hello.world
//
//  Created by X Y on 27/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "MindwaveTCP.h"


@implementation MindwaveTCP

- (id)initWithServerIP:(NSString*) address {
    self = [super init];
    
    if (self) {
        self.SERVER_PORT = 3003;
        self.SERVER_ADDR = address;
        
        self.tcp_connected = false;
    }
    
    return self;
}

- (void)initNetworkCommunication {
    if(!self.tcp_connected) {
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) self.SERVER_ADDR, self.SERVER_PORT, NULL, &writeStream);
        self.outputStream = (__bridge NSOutputStream *)(writeStream);
    
        [self.outputStream setDelegate:self];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
        [self.outputStream open];
    }
}

-(void)stream:(NSStream *) s handleEvent:(NSStreamEvent)eventCode {
    //NSLog(@"Event code:%d", eventCode);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"** Evento stream su porta %d: Open Completed", self.SERVER_PORT);
            self.tcp_connected = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveTcp_true" object:self];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"** Evento stream su porta %d: Has Space Available", self.SERVER_PORT);
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"** Evento stream su porta %d: End Encountered", self.SERVER_PORT);
            self.tcp_connected = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveTcp_false" object:self];
            break;
        case NSStreamEventErrorOccurred: {
            NSError *theError =[s streamError];
            NSLog(@"** Evento stream su porta %d: Error Occurred: error %d - %@", self.SERVER_PORT, [theError code], [theError localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"networkError" object:self];
            break;
        }
        default:
            break;
    }
}


-(void)terminateTcpConn {
    [self.outputStream close];
    self.tcp_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveTcp_false" object:self];
}


- (void)sendData:(NSDictionary *)data {
    
    if(self.tcp_connected) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
       [self.outputStream write:[jsonData bytes] maxLength:[jsonData length]];
        
        // NSLog(@"Dati MindWave:\n%@", [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding]);
        NSLog(@"** Dati MindWave: ... ...");
    }
    
}



@end
