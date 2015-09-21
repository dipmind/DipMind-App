//
//  TodoItem.h
//  hello.world
//
//  Created by X Y on 03/04/15.
//  Copyright (c) 2015 X Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject
@property NSString *itemName;
@property BOOL completed;
@property (readonly) NSDate *creationDate;
@end
