//
//  ToDoItemTableViewController.m
//  hello.world
//
//  Created by X Y on 02/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "ToDoItemTableViewController.h"
#import "ToDoItem.h"
#import "AddItemViewController.h"
#import "VideoPlayerViewController.h"
#import "Reachability.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CameraServer.h"
/*#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>*/
#import "AsyncSocket.h"
#import "ifaddrs.h"
#import "arpa/inet.h"
#import "AsyncUdpSocket.h"

@interface ToDoItemTableViewController ()
@property NSMutableArray *toDoItems;
@property (nonatomic) Reachability *wifiReachability;
@property (nonatomic) CBCentralManager *bluetoothManager;
@property (nonatomic) CameraServer *rtspServer;
@property (nonatomic) AsyncSocket *listenSocket;
@property (nonatomic) NSMutableArray *connectedSockets;
@property bool isRunning;
@property (nonatomic) NSString *serverIP;
@property (nonatomic) AsyncUdpSocket *ssdpSock;
@end


@implementation ToDoItemTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serverIP = nil;
    /*self.rtspServer = [CameraServer server];
    self.mindwaveTCP = [[MindwaveTCP alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videotcp_connection_changed:) name:@"VideoTcp_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videotcp_connection_changed:) name:@"VideoTcp_true" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_changed:) name:@"mindwaveTcp_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_changed:) name:@"mindwaveTcp_true" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavebluetooth_connection_changed:) name:@"mindwaveBluetooth_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavebluetooth_connection_changed:) name:@"mindwaveBluetooth_true" object:nil];*/
    
    //Creo un oggetto reachability che permette di vedere se c'e' connesione wifi o meno la notification permette di vedere cambiamenti di stato e quindi di instanziare i vari oggetti o meno
    //AVVIO VERIFICA SOLO SU WIFI PER RENDERE VISIBILE MIO IP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    //[self detectBluetooth];
    
    
    
    //self.toDoItems = [[NSMutableArray alloc] init];
    
      //[self loadInitialData];
    
    
    
    /*self.videoTCP = [[VideoTCP alloc] init];
    //crea delegato per videoTCP che si accorge di eventi in base a come e' costruito il delegato, quando si "attiva" chiama la funzione implementata nel delegante(QUI)
    //che il delegato ha la facolta' di compiere
    [ self.videoTCP setDelegate:self];*/
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //INIZIALIZZO SOCKET ASCOLTO
    self.listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
    self.connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    self.isRunning = NO;
    //LO METTO SU RUNLOOP PER ASPETTARE UNA CONNESSIONE
    [self.listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    //AVVIO SOCKET
    [self startStop:self];
    NSLog(@"********Fine viewDIDLOAD");
    
    [NSTimer scheduledTimerWithTimeInterval: 10 target: self
                                   selector:@selector(discoverDevices) userInfo: self repeats: YES];
}

-(void)discoverDevices {
    self.ssdpSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [self.ssdpSock enableBroadcast:TRUE error:nil];
    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMan: \"ssdp:discover\"\r\nST: mydev\r\n\r\n";
    [self.ssdpSock bindToPort:0 error:nil];
    [self.ssdpSock joinMulticastGroup:@"239.255.255.250" error:nil];
    [self.ssdpSock sendData:[str dataUsingEncoding:NSUTF8StringEncoding]
                     toHost: @"239.255.255.250" port: 1900 withTimeout:-1 tag:1];
    [self.ssdpSock receiveWithTimeout: -1 tag:1];
    [NSTimer scheduledTimerWithTimeInterval: 5 target: self
                                   selector:@selector(completeSearch:) userInfo: self repeats: NO]; }


-(void) completeSearch: (NSTimer *)t {
    NSLog(@"%s",__FUNCTION__);
    [self.ssdpSock close];
    self.ssdpSock = nil;}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"%s %ld %@ %d", __FUNCTION__ ,tag,host,port);
    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",aStr);
    return YES;
    
}

/*static void handleConnect ( CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info ){
    NSLog(@"***************Socket Callback");
};*/

- (IBAction)startStop:(id)sender
{
    if(!self.isRunning)
    {
        //SE LO DEVO AVVIARE LO METTO SU PORTA 6969
        int port = 6969;//[portField intValue];
        
        if(port < 0 || port > 65535)
        {
            port = 0;
        }
        
        NSError *error = nil;
        if(![self.listenSocket acceptOnPort:port error:&error])
        {
            NSLog(@"Error starting server: %@", error);
            return;
        }
        
        //[self logInfo:FORMAT(@"Echo server started on port %hu", [self.listenSocket localPort])];
        self.isRunning = YES;
        
        ///[portField setEnabled:NO];
        //[startStopButton setTitle:@"Stop"];
    }
    else
    {
        //SE LO DEVO FERMARE DISCONNETTO SOCKET E SUOI HOST
        // Stop accepting connections
        [self.listenSocket disconnect];
        
        // Stop any client connections
        NSUInteger i;
        for(i = 0; i < [self.connectedSockets count]; i++)
        {
            // Call disconnect on the socket,
            // which will invoke the onSocketDidDisconnect: method,
            // which will remove the socket from the list.
            [[self.connectedSockets objectAtIndex:i] disconnect];
        }
        
        NSLog(@"Stopped Echo server");
        self.isRunning = false;
        
        //AVVIO METODO PER INIZIALIZZARE TUTTO IL RESTO (mindwaveTCP, videoTCP, rtspServer)
        [self startUpAll];
        
        //[portField setEnabled:YES];
        //[startStopButton setTitle:@"Start"];
    }
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [self.connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Accepted client %@:%hu", host, port);
    
    //QUANDO ACCETTO SOCKET SU PORTA NE MEMORIZZO L'INDIRIZZO
    self.serverIP = host;
    //RIFACCIO METODO STARTSTOP PER STOPPARE TUTTO (ORAMI HO L'IP DI SERVER)
    [self startStop:self];
    
    //[sock writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
    //[sock readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}


- (void) startUpAll {
    
    
    self.rtspServer = [CameraServer server];
    self.mindwaveTCP = [[MindwaveTCP alloc] init];
    
    //INDICO CALLBACK PER NOTIFICHE SU CONNESSIONI/DISCONNESSIONI VARI OGGETTI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videotcp_connection_changed:) name:@"VideoTcp_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videotcp_connection_changed:) name:@"VideoTcp_true" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_changed:) name:@"mindwaveTcp_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_changed:) name:@"mindwaveTcp_true" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavebluetooth_connection_changed:) name:@"mindwaveBluetooth_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavebluetooth_connection_changed:) name:@"mindwaveBluetooth_true" object:nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];*/
    
    //FACCIO UPDATE PER WIFI PER AVVIARE videoTCP
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    [self detectBluetooth];

}

- (void) videotcp_connection_changed: (NSNotification *) note {
    if ([[note name] isEqualToString:@"VideoTcp_false"]) {
        self.serverCell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([[note name] isEqualToString:@"VideoTcp_true"]) {
        self.serverCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void) mindwavetcp_connection_changed: (NSNotification *) note {
    if ([[note name] isEqualToString:@"mindwaveTcp_false"]) {
        self.mindwaveCell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([[note name] isEqualToString:@"mindwaveTcp_true"] && self.mindwaveTCP.mindwave_connected) {
        self.mindwaveCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void) mindwavebluetooth_connection_changed: (NSNotification *) note {
    if ([[note name] isEqualToString:@"mindwaveBluetooth_false"]) {
        self.mindwaveCell.accessoryType = UITableViewCellAccessoryNone;} else if ([[note name] isEqualToString:@"mindwaveBluetooth_true"] && self.mindwaveTCP.tcp_connected) {
        self.mindwaveCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
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
        
        self.wifiCell.accessoryType = UITableViewCellAccessoryNone;
        self.serverCell.accessoryType = UITableViewCellAccessoryNone;
        self.wifiCell.detailTextLabel.text = @" ";

        
    } else if (status == ReachableViaWiFi) {
        NSLog(@"** WIfi OK");
        if (self.videoTCP == nil && self.serverIP != nil) {
            //LO FACCIO SOLO SE HO RICEVUTO IP DA SERVER
            self.videoTCP = [[VideoTCP alloc] init];
            [ self.videoTCP setDelegate:self];
            [self.rtspServer startup];
            self.mindwaveTCP.wifiActive = true;
            [self.mindwaveTCP initNetworkCommunication];
        }
        
        
        
        
        //MA PERMETTO CHE SI VEDA IL MIO IP PER SCRIVERLO
        /*UITableViewCell* new = [[UITableViewCell alloc] init];
        
        new.accessoryType = UITableViewCellAccessoryCheckmark;
        new.detailTextLabel.text = [self getIPAddress];
        
        self.wifiCell = new;*/
        
        /*self.wifiCell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSString *a = [self getIPAddress];
        NSLog(@"CIAO BEL %@", a);
        self.wifiCell.detailTextLabel.text = @"ESISTE WIFI";*/
        self.wifiCell.detailTextLabel.text = [self getIPAddress];
        self.wifiCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //self.wifiCell.textLabel.text = @"COAIS";
        


        
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
        case CBCentralManagerStatePoweredOff: {
            stateString = @"Bluetooth is currently powered off.";
            //[self.mindwaveTCP offBluetoothConn];
            self.bluetoothCell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case CBCentralManagerStatePoweredOn: {
            stateString = @"Bluetooth is currently powered on and available to use.";
            //[self.mindwaveTCP onBluetoothConn];
            self.bluetoothCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
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



- (void)loadInitialData {
    ToDoItem *item1 = [[ToDoItem alloc] init];
    item1.itemName = @"Buy milk";
    [self.toDoItems addObject:item1];
    ToDoItem *item2 = [[ToDoItem alloc] init];
    item2.itemName = @"Buy eggs";
    [self.toDoItems addObject:item2];
    ToDoItem *item3 = [[ToDoItem alloc] init];
    item3.itemName = @"Read a book";
    [self.toDoItems addObject:item3];
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.toDoItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    
    if (toDoItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
    
    tappedItem.completed = !tappedItem.completed;
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
               withRowAnimation:UITableViewRowAnimationNone];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"segueToVideo"]) {
        VideoPlayerViewController* v = (VideoPlayerViewController*)[segue destinationViewController];
        v.videoTCP = self.videoTCP;
    }
}


- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    [self.videoTCP setDelegate:self];
    
//    AddItemViewController *source = [segue sourceViewController];
//    ToDoItem *item = source.toDoItem;
//    if (item != nil) {
//        [self.toDoItems addObject:item];
//        [self.tableView reloadData];
//    }
    
}

- (NSString*) getIPAddress
{
    NSString* address;
    struct ifaddrs *interfaces = nil;
    
    // get all our interfaces and find the one that corresponds to wifi
    if (!getifaddrs(&interfaces))
    {
        for (struct ifaddrs* addr = interfaces; addr != NULL; addr = addr->ifa_next)
        {
            if (([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) &&
                (addr->ifa_addr->sa_family == AF_INET))
            {
                struct sockaddr_in* sa = (struct sockaddr_in*) addr->ifa_addr;
                address = [NSString stringWithUTF8String:inet_ntoa(sa->sin_addr)];
                break;
            }
        }
    }
    freeifaddrs(interfaces);
    
    return address;
}

@end
