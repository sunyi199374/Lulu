//
//  Todo.h
//  Lulu
//
//  Created by Dingzhong Weng on 7/29/12.
//  Copyright (c) 2012 Worcester Polytechnic Institute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Todolist;

@interface Todo : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSNumber * isDone;
@property (nonatomic, retain) Todolist *todolist;

@end
