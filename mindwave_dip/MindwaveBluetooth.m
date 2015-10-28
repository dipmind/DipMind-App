//
//  MindwaveBluetooth.m
//  mindwave_dip
//
//  Created by X Y on 27/10/15.
//  Copyright © 2015 X Y. All rights reserved.
//

#import "MindwaveBluetooth.h"
#import "TGAccessoryManager.h"

@interface MindwaveBluetooth()

@property (retain) NSTimer *heartBeat;
@property NSDictionary *hb;

@end

@implementation MindwaveBluetooth



- (id)init {
    self = [super init];
    
    if (self) {
        
        self.mindwave_connected = false;
        self.tcp_connection = nil;
        self.hb = [NSDictionary dictionaryWithObject:@"alive" forKey:@"hb"];
        
        self.heartBeat = [NSTimer timerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(sendHeartBeatData)
                                               userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.heartBeat forMode:NSRunLoopCommonModes];

        
        
        [[TGAccessoryManager sharedTGAccessoryManager] setDelegate: self];
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:1.0];
        
    }
    
    return self;
}

- (void)accessoryDidConnect:(EAAccessory *)accessory {
    
    self.mindwave_connected = true;
    [self.heartBeat invalidate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveBluetooth_true" object:self];
    
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    
    
    
    NSLog(@"%s", "** MindWave connesso.");
}

- (void)accessoryDidDisconnect {
    self.mindwave_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveBluetooth_false" object:self];
    
    [[TGAccessoryManager sharedTGAccessoryManager] stopStream];
    
    self.heartBeat = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(sendHeartBeatData)
                                           userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.heartBeat forMode:NSRunLoopCommonModes];
    
    NSLog(@"%s", "** MindWave disconnesso.");
}

- (void)dataReceived:(NSDictionary *)data {
    
    //NSLog(@"! DATI MINDWAVE");
    if(self.tcp_connection != nil)
        [self.tcp_connection sendData:data];
}

-(void) sendHeartBeatData {
    
    //NSLog(@"! HEARTBEAT");
    if(self.tcp_connection != nil)
        [self.tcp_connection sendData:self.hb];
}

@end
