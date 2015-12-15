//
//  VideoTCP.h
//  hello.world
//
//  Created by X Y on 18/05/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Crea delegato per videoTCP
 */

@protocol VideoTCPDelegate <NSObject>
@optional
//metodi che il delegato ha la possibilita' di eseguire su richiesta del delegante
- (void)videotcp_connection_opened:(NSObject*) sender;
- (void)videotcp_connection_closed:(NSObject*) sender;
- (void)videotcp_command:(NSObject*) sender withJSON:(NSDictionary*) contents;

// ... other methods here
@end


@interface VideoTCP : NSObject <NSStreamDelegate>

//attacca a VideoTCP un delegato
@property id <VideoTCPDelegate> delegate;




@property NSString* SERVER_ADDR;
@property int SERVER_PORT;


@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;

@property bool tcp_connected ;//= false;

-(id)initWithServerIP:(NSString*) address ;
-(void)terminateTcpConn;
-(void) initNetworkCommunication;
-(void)sendData:(NSDictionary*) data;


@end


