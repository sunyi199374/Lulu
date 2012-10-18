//
//  ListDatesViewController.h
//  Lulu
//
//  Created by Dingzhong Weng on 7/26/12.
//  Copyright (c) 2012 Worcester Polytechnic Institute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListDatesViewController : UIViewController
@property (strong, nonatomic) NSDate* timeCreated;
@property (strong, nonatomic) NSDate* timeFinished;
@property (strong, nonatomic) NSDate* alarm;
@property CGSize viewSize;
-(id)initWithCreationDateOfList:(NSDate*)time1 andFinishDate:(NSDate*)time2 andAlarm:(NSDate *)alarm1;
@end
