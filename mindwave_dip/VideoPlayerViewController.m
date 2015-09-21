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

	//!!!!!!!!IPAD LEGGE SOLO M3U8 CON CODEC VIDEO H264 E AUDIO AAC ----> OK SU WINDOWS SU MAC USARE -bsf:v h264_mp4toannexb!!!!!!!


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.videoTCP setDelegate:self];
    // Do any additional setup after loading the view.
    
 //NSURL *streamURL = [NSURL URLWithString:@"http://10.20.10.69:3000/videos/quantum.m3u8"];
    NSURL *streamURL = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"];
    
//    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"vid" ofType:@"mp4"];
//    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
//    
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.absoluteString]) {
//        NSLog(@"yes");
//    } else {
//        NSLog(@"no");
//    }
//    
//    NSLog(@"%@",[streamURL absoluteString] );
//    
    self.player = [AVPlayer playerWithURL:streamURL];
    //[self.player play];
    
    
    
   


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

-(void) videotcp_connection_closed:(id)videoTCP {
    //NSLog([self debugDescription]);
    [self performSegueWithIdentifier:@"segueFromVideo" sender:self];
}

-(void ) videotcp_command:(NSObject *)sender withJSON:(NSDictionary *)json {
    

    /*if([contents isEqualToString:@"playalo"]) {
        NSLog(@"** video player: play");
        [self.player play];
    } else if ([contents isEqualToString:@"pausalo"]) {
        NSLog(@"** video player: pause");
        [self.player pause];
    } else if ([contents length] > 5 && [[contents substringToIndex:5] isEqualToString:@"seek:"]) {
        NSString *temp = [contents substringFromIndex:5];
        NSLog(@"** video player: seeking to %f seconds", [temp floatValue]);
        [self.player seekToTime:CMTimeMakeWithSeconds([temp floatValue], 1) toleranceBefore:CMTimeMakeWithSeconds(1.0, 1) toleranceAfter:CMTimeMakeWithSeconds(1.0, 1)];
    } else if ([contents length] > 4 && [[contents substringToIndex:4] isEqualToString:@"url:"]) {
        NSString *temp = [@"http://10.20.10.69:3000" stringByAppendingString:[contents substringFromIndex:4]];
        NSLog(@"** video player: switching to '%@'", temp);
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:temp]]];
    } else {
        NSLog(@"** video player: unrecognized command '%@'", contents);
    }*/
    
    
    //NSLog(@"My dictionary is %@", json);
            if (![[(AVURLAsset *)self.player.currentItem.asset URL ] isEqual:[NSURL URLWithString:json[@"url"]]]) {
           // NSString *temp = [@"http://10.20.10.69:3000" stringByAppendingString:[contents substringFromIndex:4]];
            NSLog(@"** video player: switching to '%@'", json[@"url"]);
            [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:json[@"url"]]]];
        }
        
        [self.player seekToTime:CMTimeMakeWithSeconds([json[@"time"] floatValue], 1) toleranceBefore:CMTimeMakeWithSeconds(0.5, 1) toleranceAfter:CMTimeMakeWithSeconds(0.5, 1)];
        
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
