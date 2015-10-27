//
//  ToDoItemTableViewController.m
//  hello.world
//
//  Created by X Y on 02/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoPlayerViewController.h"
#import "Reachability.h"
#import "CameraServer.h"
#import "AsyncSocket.h"
#import "MindwaveBluetooth.h"

// usati per ottenere l'ip
#import "ifaddrs.h"
#import "arpa/inet.h"

#import <CoreBluetooth/CoreBluetooth.h>


@interface HomeViewController ()
@property (nonatomic, retain) MindwaveTCP *mindwaveTCP;
@property (nonatomic, retain) MindwaveBluetooth *mindwaveBluetooth;
@property (nonatomic, retain) VideoTCP *videoTCP;

@property (nonatomic, retain) Reachability *wifiReachability;
@property (nonatomic, retain) CBCentralManager *bluetoothManager;
@property (nonatomic, retain) CameraServer *rtspServer;
@property (nonatomic, retain) AsyncSocket *listenSocket;
@property (nonatomic, retain) NSMutableArray *connectedSockets;
@property (nonatomic, retain) NSString *serverIP;
@property bool networkErrorManaged;
@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.mindwaveBluetooth = [[MindwaveBluetooth alloc] init];
    [self detectBluetooth];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavebluetooth_connection_changed:) name:@"mindwaveBluetooth_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavebluetooth_connection_changed:) name:@"mindwaveBluetooth_true" object:nil];

    
    // Crea un oggetto Reachability che permette di controllare se e' presente una connessione wifi,
    // e la notification indica quando c'e' stato un cambiamento di stato della reachability.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    
    
    // Inizializza il socket in ascolto
    
    self.listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
    self.connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self fetchIPFromServer];
    
}

-(void) fetchIPFromServer {
    self.serverIP = nil;
    
    NSError *error = nil;
    if(![self.listenSocket acceptOnPort:FIRSTCONNECTION_PORT error:&error]) {
        NSLog(@"** Error trying to listen on port %d for a connection: %@", FIRSTCONNECTION_PORT, error);
        return;
    }

}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [self.connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"** Accepted client %@:%hu", host, port);
    
    // Memorizza l'indirizzo del server
    self.serverIP = host;
    // Chiude il socket in ascolto, non e' piu' necessario
    [self.listenSocket disconnect];
    
    // Stop any client connections
    for(NSUInteger i = 0; i < [self.connectedSockets count]; i++) {
        // Call disconnect on the socket,
        // which will invoke the onSocketDidDisconnect: method,
        // which will remove the socket from the list.
        [[self.connectedSockets objectAtIndex:i] disconnect];
    }
    
    NSLog(@"** Stop listening on port %d for connections", port);
    
    // Avvia tutto il resto (mindwaveTCP, videoTCP, rtspServer)
    [self startUpAll];
    
}

- (void) startUpAll
{
    self.networkErrorManaged = false;
    self.rtspServer = [CameraServer server];
    [self.rtspServer startup];
    
    //Creo oggetto per invio dati mindwave su porta 3003 e associo a connessione bluetooth mindwave
    self.mindwaveTCP = [[MindwaveTCP alloc] initWithServerIP:self.serverIP];
    self.mindwaveBluetooth.tcp_connection = self.mindwaveTCP;
    [self.mindwaveTCP initNetworkCommunication];
    
    //creo oggetto per ricezione comandi su porta 3005
    self.videoTCP = [[VideoTCP alloc] initWithServerIP:self.serverIP];
    [self.videoTCP setDelegate:self];
    [self.videoTCP initNetworkCommunication];
    
    // Indica callback per connessioni/disconnessioni
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videotcp_connection_changed:) name:@"VideoTcp_false" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videotcp_connection_changed:) name:@"VideoTcp_true" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_changed:) name:@"mindwaveTcp_false" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mindwavetcp_connection_changed:) name:@"mindwaveTcp_true" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkError) name:@"networkError" object:nil];
    
    // L'update della reachability wifi fa partire
    [self updateLogicWithReachability:self.wifiReachability];
   
}

- (void) mindwavetcp_connection_changed: (NSNotification *) note {
    //[self unwindIfNecessary];
    
    if ([[note name] isEqualToString:@"mindwaveTcp_false"]) {
        self.serverCell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([[note name] isEqualToString:@"mindwaveTcp_true"]) {
        self.serverCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void) mindwavebluetooth_connection_changed: (NSNotification *) note {
    if ([[note name] isEqualToString:@"mindwaveBluetooth_false"]) {
        self.mindwaveCell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([[note name] isEqualToString:@"mindwaveBluetooth_true"]) {
        self.mindwaveCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

-(void) networkError {
    if (!self.networkErrorManaged){
        
        //[self unwindIfNecessary];
        
        
        self.networkErrorManaged = true;
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Errore"
                                                                       message:@"Si è verificato un imprevisto nella comunicazione con il server.\nÈ necessario rieseguire la procedura di connessione."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self disconnectAll];
        
        [self fetchIPFromServer];
    }
    
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    //[self unwindIfNecessary];
    [self updateInterfaceWithReachability:curReach];
    [self updateLogicWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    
    if (status == NotReachable) {
        NSLog(@"** Wifi not reachable");
        // Rimuove le spunte e l'ip dalle cells
        self.wifiCell.accessoryType = UITableViewCellAccessoryNone;
        self.wifiCell.detailTextLabel.text = @" ";
        
    } else if (status == ReachableViaWiFi) {
        NSLog(@"** Wifi reachable");
     // Mostra l'ip come label di wifiCell
        self.wifiCell.detailTextLabel.text = [self getIPAddress];
        self.wifiCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

-(void)updateLogicWithReachability:(Reachability *)reachability {
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        
        if (self.serverIP != nil){
            //E' gia' avvenuta la connessione iniziale riporto a aspettare connessione
            [self disconnectAll];
            
            [self fetchIPFromServer];
        }
        
    }
}

-(void) disconnectAll {
    
    [self.rtspServer shutdown];
    self.rtspServer = nil;
    
    [self.videoTCP terminateTcpConn];
    self.videoTCP = nil;
    
    [self.mindwaveTCP terminateTcpConn];
    self.mindwaveTCP = nil;

}



- (void)detectBluetooth
{
    if(!self.bluetoothManager) {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.bluetoothManager.state) {
        case CBCentralManagerStateResetting:
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off.";
            self.bluetoothCell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case CBCentralManagerStatePoweredOn:
            stateString = @"Bluetooth is currently powered on and available to use.";
            self.bluetoothCell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        default:
            stateString = @"State unknown, update imminent.";
            break;
    }
    
    NSLog(@"** Bluetooth status: %@", stateString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) videotcp_connection_opened:(id)videoTCP {
   // NSLog([self debugDescription]);
    [self performSegueWithIdentifier:@"segueToVideo" sender:self];
}

-(void) videotcp_connection_closed:(NSObject *)sender {
    
}

#pragma mark - Table view data source

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"segueToVideo"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        VideoPlayerViewController* v = (VideoPlayerViewController*)[segue destinationViewController];
        v.videoTCP = self.videoTCP;
    }
}

-(void) unwindIfNecessary {
    
    if ([self.presentedViewController isKindOfClass:[VideoPlayerViewController class]]) {
        [self.presentedViewController performSegueWithIdentifier:@"segueFromVideo" sender:nil];
    }
}

// Torna dal video alla home
- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    //[self.videoTCP setDelegate:self];
    //[self.videoTCP stopTcpConn];
    //[self.mindwaveTCP stopTcpConn];
    
    //[self.rtspServer shutdown];
    
    
    [self disconnectAll];
    
    [self fetchIPFromServer];
    
}


- (NSString*) getIPAddress
{
    NSString* address;
    struct ifaddrs *interfaces = nil;
    
    // get all our interfaces and find the one that corresponds to wifi
    if (!getifaddrs(&interfaces)) {
        for (struct ifaddrs* addr = interfaces; addr != NULL; addr = addr->ifa_next) {
            if (([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) &&
                (addr->ifa_addr->sa_family == AF_INET)) {
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
