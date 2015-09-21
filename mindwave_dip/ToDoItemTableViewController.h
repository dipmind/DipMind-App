//
//  ToDoItemTableViewController.h
//  hello.world
//
//  Created by X Y on 02/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//
#import "MindwaveTCP.h"
#import "VideoTCP.h"
#import <UIKit/UIKit.h>

@interface ToDoItemTableViewController : UITableViewController <VideoTCPDelegate>
@property (retain) MindwaveTCP *mindwaveTCP;
@property (retain) VideoTCP *videoTCP;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@property (nonatomic) IBOutlet UITableViewCell *wifiCell;
@property (nonatomic) IBOutlet UITableViewCell *bluetoothCell;
@property (nonatomic) IBOutlet UITableViewCell *mindwaveCell;
@property (nonatomic) IBOutlet UITableViewCell *serverCell;


@end
