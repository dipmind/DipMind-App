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
#import <CoreBluetooth/CoreBluetooth.h>

@interface HomeViewController : UITableViewController <VideoTCPDelegate, CBCentralManagerDelegate>


- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@property (nonatomic) IBOutlet UITableViewCell *wifiCell;
@property (nonatomic) IBOutlet UITableViewCell *bluetoothCell;
@property (nonatomic) IBOutlet UITableViewCell *mindwaveCell;
@property (nonatomic) IBOutlet UITableViewCell *serverCell;


@end
