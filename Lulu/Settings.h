//
//  Settings.h
//  Lulu
//
//  Created by Dingzhong Weng on 9/29/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSNumber * firstTimeShowInFirstLevel;
@property (nonatomic, retain) NSNumber * firstTimeShowInListsView;
@property (nonatomic, retain) NSNumber * firstTimeShowInDetailsView;

@end
