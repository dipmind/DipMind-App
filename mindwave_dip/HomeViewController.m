//
//  HomeViewController.m
//  hello.world
//
//  Created by X Y on 09/07/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoPlayerViewController.h"
#import "Reachability.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CameraServer.h"


@interface HomeViewController ()
@property (nonatomic) Reachability *wifiReachability;
@property (nonatomic) CBCentralManager *bluetoothManager;
@property (nonatomic) CameraServer *rtspServer;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*Creo un oggetto reachability che permette di vedere se c'e' connesione wifi o meno
     * la notification permette di vedere cambiamenti di stato e quindi di instanziare i vari oggetti o meno
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    [self detectBluetooth];
    
    self.rtspServer = [CameraServer server];
    
    
    self.mindwaveTCP = [[MindwaveTCP alloc] init];
    
    /*self.videoTCP = [[VideoTCP alloc] init];
     //crea delegato per videoTCP che si accorge di eventi in base a come e' costruito il delegato, quando si "attiva" chiama la funzione implementata nel delegante(QUI)
     //che il delegato ha la facolta' di compiere
     [ self.videoTCP setDelegate:self];*/
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    int status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        NSLog(@"** WIfi not Reachable");
        if (self.videoTCP != nil) {
            [self.videoTCP stopTcpConn];
            self.videoTCP = nil;
        }
        
        if (self.rtspServer != nil) {
            [self.rtspServer shutdown];
        }
        
        /*if (self.mindwaveTCP != nil) {
         [self.mindwaveTCP stopTcpConn];
         self.mindwaveTCP = nil;
         }*/
        self.mindwaveTCP.wifiActive = false;
        if (self.mindwaveTCP.mindwave_connected == true) {
            [self.mindwaveTCP stopTcpConn];
        }
        
        
    } else if (status == ReachableViaWiFi) {
        NSLog(@"** WIfi OK");
        if (self.videoTCP == nil) {
            self.videoTCP = [[VideoTCP alloc] init];
            [ self.videoTCP setDelegate:self];
        }
        
        
        [self.rtspServer startup];
        NSLog([self.rtspServer getURL]);
        
        
        self.mindwaveTCP.wifiActive = true;
        [self.mindwaveTCP initNetworkCommunication];
        /*if (self.mindwaveTCP == nil) {
         self.mindwaveTCP = [[MindwaveTCP alloc] init];
         }*/
        
    }
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    /*UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Bluetooth state"
     message:stateString
     delegate:nil
     cancelButtonTitle:@"Okay" otherButtonTitleArray:nil] autorelease];
     [alert show];*/
    NSLog(stateString);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) videotcp_connection_opened:(id)videoTCP {
    // NSLog([self debugDescription]);
    [self performSegueWithIdentifier:@"segueToVideo" sender:self];
}

-(void) videotcp_command:(NSObject *)sender withJSON:(NSDictionary *)contents {
    // NSLog([self debugDescription]);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"segueToVideo"]) {
        VideoPlayerViewController* v = (VideoPlayerViewController*)[segue destinationViewController];
        v.videoTCP = self.videoTCP;
    }
}


- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    [self.videoTCP setDelegate:self];
    
    //    AddItemViewController *source = [segue sourceViewController];
    //    ToDoItem *item = source.toDoItem;
    //    if (item != nil) {
    //        [self.toDoItems addObject:item];
    //        [self.tableView reloadData];
    //    }
    
}

@end
