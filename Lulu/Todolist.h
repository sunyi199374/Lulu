//
//  Todolist.h
//  Lulu
//
//  Created by Dingzhong Weng on 7/31/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Todo;

@interface Todolist : NSManagedObject

@property (nonatomic, retain) NSDate * alarm;
@property (nonatomic, retain) NSNumber * onGoing;
@property (nonatomic, retain) NSDate * timeCreated;
@property (nonatomic, retain) NSDate * timeFinished;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * allDone;
@property (nonatomic, retain) NSSet *todos;
@end

@interface Todolist (CoreDataGeneratedAccessors)

- (void)addTodosObject:(Todo *)value;
- (void)removeTodosObject:(Todo *)value;
- (void)addTodos:(NSSet *)values;
- (void)removeTodos:(NSSet *)values;

@end
