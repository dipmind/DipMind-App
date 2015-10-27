//
//  MindwaveBluetooth.m
//  mindwave_dip
//
//  Created by X Y on 27/10/15.
//  Copyright © 2015 X Y. All rights reserved.
//

#import "MindwaveBluetooth.h"
#import "TGAccessoryManager.h"

@implementation MindwaveBluetooth

- (id)init {
    self = [super init];
    
    if (self) {
        
        self.mindwave_connected = false;
        self.tcp_connection = nil;
        
        [[TGAccessoryManager sharedTGAccessoryManager] setDelegate: self];
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.2];
    }
    
    return self;
}

- (void)accessoryDidConnect:(EAAccessory *)accessory {
    
    self.mindwave_connected = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveBluetooth_true" object:self];
    
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    
    NSLog(@"%s", "*** MindWave connesso.");
}

- (void)accessoryDidDisconnect {
    self.mindwave_connected = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mindwaveBluetooth_false" object:self];
    
    [[TGAccessoryManager sharedTGAccessoryManager] stopStream];
        
    NSLog(@"%s", "*** MindWave disconnesso.");
}

- (void)dataReceived:(NSDictionary *)data {
        
    if(self.tcp_connection != nil)
        [self.tcp_connection sendData:data];
}

@end
