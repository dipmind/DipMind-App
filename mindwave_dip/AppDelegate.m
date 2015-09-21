//
//  AppDelegate.m
//  hello.world
//
//  Created by X Y on 02/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//
//#import "TGAccessoryDelegate.h"
//#import "TGAccessoryManager.h"
#import "AppDelegate.h"
//#import "CameraServer.h"
@import Foundation;



@implementation AppDelegate

//NSDate *timeOld;
//
//
//const float MINDWAVE_INTERVAL = 5.0;

//CFStringRef  SERVER_ADDR = CFSTR("10.20.10.69");
//const int SERVER_PORT = 3003;
//
//
//
//
//bool mindwave_connected = false;
//
//bool tcp_connected = false;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    
    //[[CameraServer server] startup];
    
//    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate: self];
//    [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.2];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    
    return YES;
}

//- (void)initNetworkCommunication {
//    NSLog(@"initCommunication");
//    CFWriteStreamRef writeStream;
//    
//    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)SERVER_ADDR, SERVER_PORT, NULL, &writeStream);
//    self.outputStream = (__bridge NSOutputStream *)(writeStream);
//    
//    [self.outputStream setDelegate:self];
//    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    
//    [self.outputStream open];
//    
//    while (self.outputStream.streamStatus == NSStreamStatusOpening);
//    
//    if (self.outputStream.streamStatus == NSStreamStatusOpen) {
//        tcp_connected = true;
//    }
//}

//-(void)stream:(NSStream *) s handleEvent:(NSStreamEvent)eventCode {
//    NSLog(@"Event code:%d", eventCode);
//    switch (eventCode) {
//        case NSStreamEventOpenCompleted:
//            NSLog(@"Stream event: OpenCompleted");
//            NSLog(@"Mindwave_data: Created TCP connection to %@:%d", SERVER_ADDR, SERVER_PORT);
//            tcp_connected = true;
//            break;
//        case NSStreamEventHasSpaceAvailable:
//            NSLog(@"Stream event: HasSpace");
//            break;
//        case NSStreamEventEndEncountered:
//            NSLog(@"Stream event: EndEncountered");
//            tcp_connected = false;
//            break;
//        case NSStreamEventErrorOccurred: {
//            NSLog(@"Stream event: ErrorOccurred");
//            NSError *theError =[s streamError];
//            NSLog(@"%@", [NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]]);
//            if([theError code] == 32) {// Error 32: The operation couldn’t be completed. Broken pipe
//                [self terminateTcpConn];
//            }
//            
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (void)accessoryDidConnect:(EAAccessory *)accessory {
//    while (!tcp_connected) {
//        [self initNetworkCommunication];
//        NSLog(@"Stato stream: %d",self.outputStream.streamStatus);
//        /*if (self.outputStream.streamStatus != NSStreamStatusOpening)
//            NSLog(@"APro");
//            [self.outputStream open];*/
//    }
//    
//    mindwave_connected = true;
//  
//    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
//      
//    NSLog(@"%s", "*** MindWave connesso.");
//
//    
//}
//
//-(void)terminateTcpConn {
//    [self.outputStream close];
//    tcp_connected = false;
//}
//
//- (void)accessoryDidDisconnect {
//    mindwave_connected = false;
//    
//    [[TGAccessoryManager sharedTGAccessoryManager] stopStream];
//
//    [self terminateTcpConn];
//    
//    NSLog(@"%s", "*** MindWave disconnesso.");
//}
//
//- (void)dataReceived:(NSDictionary *)data {
//    
//    NSLog(@"Stato stream: %d",self.outputStream.streamStatus);
//   
//    if(tcp_connected) {
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *result = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
//    [self.outputStream write:[jsonData bytes] maxLength:[jsonData length]];
//    //[outputStream write:[[@"aaaaaa" dataUsingEncoding:NSUTF8StringEncoding] bytes] maxLength:6 ];
//    NSLog(@"Tempo trascorso dagli ultimi dati ricevuti: %f s",[[NSDate date] timeIntervalSinceDate:timeOld]);
//    
//    timeOld = [NSDate date];
//    NSLog(@"Dati MindWave:\n%@", result);
//    }
//    
//    
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
