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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_closed) name:@"mindwaveTcp_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkError) name:@"networkError" object:nil];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) mindwavetcp_connection_closed {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"segueFromVideo" sender:self];
}

-(void) networkError {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"segueFromVideo" sender:self];
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
    //[self.videoTCP stopTcpConn];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"segueFromVideo" sender:self];
}

-(void ) videotcp_command:(NSObject *)sender withJSON:(NSDictionary *)json {
    
    if(![[(AVURLAsset *)self.player.currentItem.asset URL] isEqual:[NSURL URLWithString:json[@"url"]]]) {
        NSLog(@"** Player video: '%@' in riproduzione.", json[@"url"]);
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:json[@"url"]]]];
    }
        
    [self.player seekToTime:CMTimeMakeWithSeconds([json[@"time"] floatValue], 1)
            toleranceBefore:CMTimeMakeWithSeconds(0.5, 1) toleranceAfter:CMTimeMakeWithSeconds(0.5, 1)];
        
    if ([json[@"command"] isEqualToString:@"play"]) {
        NSLog(@"** Player video: comando 'play' di '%@'.", json[@"url"]);
        [self.player play];
    } else if ([json[@"command"] isEqualToString:@"pause"]) {
        NSLog(@"** Player video: comando 'pause' di '%@'.", json[@"url"]);
        [self.player pause];
    }
}


@end
