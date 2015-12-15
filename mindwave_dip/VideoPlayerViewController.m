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
    
    self.lastCommandId = @"";
    
    self.player = [AVPlayer playerWithURL:streamURL];
    
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
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
    NSLog(@"** Player video: '%@' ", json[@"command"]);
    
    Boolean changed = false;
    
    if(![[(AVURLAsset *)self.player.currentItem.asset URL] isEqual:requestURL]) {
        changed = true;
        NSLog(@"** Player video: '%@' in riproduzione.", json[@"url"]);
        
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:requestURL]];
        if(![json[@"id"] isEqualToString:@"0"]) {
            //NSLog(@"%@", json[@"id"]);
            self.lastCommandId = json[@"id"];
            
            //NSLog(@"%@", commandId);
            //[self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:(__bridge void * _Nullable)(json[@"id"])];
            [self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:@""];
        } else {
            NSLog(@"NO id");
            //[self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        }
        
    }
    
    if([json[@"command"] isEqualToString:@"seeked"]) {
        changed = true;
        NSLog(@"** Player video: '%@' in riproduzione.", json[@"url"]);
        
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        //[self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:requestURL]];
        if(![json[@"id"] isEqualToString:@"0"]) {
            //NSLog(@"%@", json[@"id"]);
            self.lastCommandId = json[@"id"];
            
            //NSLog(@"%@", commandId);
            //[self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:(__bridge void * _Nullable)(json[@"id"])];
            [self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:@""];
        } else {
            NSLog(@"NO id");
            //[self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        }
        
    }

        
    [self.player seekToTime:CMTimeMakeWithSeconds([json[@"time"] floatValue], 1)
            toleranceBefore:CMTimeMakeWithSeconds(0.5, 1) toleranceAfter:CMTimeMakeWithSeconds(0.5, 1)];
        
    if ([json[@"command"] isEqualToString:@"play"]) {
        NSLog(@"** Player video: comando 'play' di '%@'.", [requestURL absoluteString]);
        if(!changed)
            [self.videoTCP sendData:[[NSDictionary alloc] initWithObjectsAndKeys: @"true", @"ready", json[@"id"], @"id", nil]];
        [self.player play];
    } else if ([json[@"command"] isEqualToString:@"pause"]) {
        NSLog(@"** Player video: comando 'pause' di '%@'.", [requestURL absoluteString]);
        [self.player pause];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.player.currentItem && [keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"READY TO PLAY");
            if(context != nil) {
                //NSLog(@"%@", context);
                /*NSString * commandId = (__bridge NSString *)(context);
                NSLog(@"%@", commandId);*/
                [self.videoTCP sendData:[[NSDictionary alloc] initWithObjectsAndKeys: @"true", @"ready", self.lastCommandId, @"id", nil]];
            }
        } else {
            NSLog(@"ALTRO STATUS");
        }
    }
}


@end
