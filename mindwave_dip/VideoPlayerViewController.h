//
//  VideoPlayerViewController.h
//  hello.world
//
//  Created by X Y on 03/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//
#import "VideoTCP.h"
#import <AVKit/AVKit.h>

@interface VideoPlayerViewController : AVPlayerViewController <VideoTCPDelegate>

//@property CFStringRef SERVER_ADDR;
//@property int SERVER_PORT;
@property (retain) VideoTCP *videoTCP;

@end