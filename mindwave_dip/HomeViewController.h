//
//  HomeViewController.h
//  hello.world
//
//  Created by X Y on 09/07/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//
#import "MindwaveTCP.h"
#import "VideoTCP.h"
#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (retain) MindwaveTCP *mindwaveTCP;
@property (retain) VideoTCP *videoTCP;

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue;


@end
