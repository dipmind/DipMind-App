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
    //NSLog([self debugDescription]);
    [self performSegueWithIdentifier:@"segueFromVideo" sender:self];
}

-(void ) videotcp_command:(NSObject *)sender withJSON:(NSDictionary *)json {
    
    if(![[(AVURLAsset *)self.player.currentItem.asset URL] isEqual:[NSURL URLWithString:json[@"url"]]]) {
        // NSString *temp = [@"http://10.20.10.69:3000" stringByAppendingString:[contents substringFromIndex:4]];
        NSLog(@"** video player: switching to '%@'", json[@"url"]);
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:json[@"url"]]]];
    }
        
    [self.player seekToTime:CMTimeMakeWithSeconds([json[@"time"] floatValue], 1)
            toleranceBefore:CMTimeMakeWithSeconds(0.5, 1) toleranceAfter:CMTimeMakeWithSeconds(0.5, 1)];
        
    if ([json[@"command"] isEqualToString:@"play"]) {
        NSLog(@"** video player: play");
        NSLog(@"** video player: of '%@'", json[@"url"]);
        [self.player play];
    } else if ([json[@"command"] isEqualToString:@"pause"]) {
        NSLog(@"** video player: pause");
        NSLog(@"** video player: of '%@'", json[@"url"]);
        [self.player pause];
    }
}


@end
