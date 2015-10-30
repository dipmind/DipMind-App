//
//  MindwaveBluetooth.h
//  mindwave_dip
//
//  Created by X Y on 27/10/15.
//  Copyright © 2015 X Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGAccessoryDelegate.h"
#import "MindwaveTCP.h"

@interface MindwaveBluetooth : NSObject <TGAccessoryDelegate>

@property bool mindwave_connected;
@property MindwaveTCP *tcp_connection;



@end
