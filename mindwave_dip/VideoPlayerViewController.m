//
//  VideoPlayerViewController.m
//  hello.world
//
//  Created by X Y on 03/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "VideoPlayerViewController.h"
@import AVFoundation;


@implementation VideoPlayerViewController

const NSString *FILE_SERVER_PORT = @":3004";
const NSString *ADDR_BASE = @"http://";

/* iPad legge solo HLS standard (m3u8 con video h264 e audio aac) */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.videoTCP setDelegate:self];
    NSURL *streamURL = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"];
    
    self.player = [AVPlayer playerWithURL:streamURL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) videotcp_connection_opened:(NSObject *)sender
{
}

-(void) videotcp_connection_closed:(id)videoTCP {
    [self performSegueWithIdentifier:@"segueFromVideo" sender:self];
}

-(void ) videotcp_command:(NSObject *)sender withJSON:(NSDictionary *)json {
    
    NSURL *requestURL = [NSURL URLWithString:[ADDR_BASE stringByAppendingString:[self.videoTCP.SERVER_ADDR stringByAppendingString:[FILE_SERVER_PORT stringByAppendingString: json[@"url"]]]]];
    
    if(![[(AVURLAsset *)self.player.currentItem.asset URL] isEqual:requestURL]) {
        NSLog(@"** Player video: '%@' in riproduzione.", json[@"url"]);
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:requestURL]];
    }
        
    [self.player seekToTime:CMTimeMakeWithSeconds([json[@"time"] floatValue], 1)
            toleranceBefore:CMTimeMakeWithSeconds(0.5, 1) toleranceAfter:CMTimeMakeWithSeconds(0.5, 1)];
        
    if ([json[@"command"] isEqualToString:@"play"]) {
        NSLog(@"** Player video: comando 'play' di '%@'.", [requestURL absoluteString]);
        [self.player play];
    } else if ([json[@"command"] isEqualToString:@"pause"]) {
        NSLog(@"** Player video: comando 'pause' di '%@'.", [requestURL absoluteString]);
        [self.player pause];
    }
}


@end
