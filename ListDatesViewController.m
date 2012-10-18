//
//  ListDatesViewController.m
//  Lulu
//
//  Created by Dingzhong Weng on 7/26/12.
//  Copyright (c) 2012 Worcester Polytechnic Institute. All rights reserved.
//

#import "ListDatesViewController.h"
#define kOneDateHeightFont13 90
#define kTwoDatesHeightFont13 140
#define kLineWidthFont13 180

@interface ListDatesViewController ()

@end

@implementation ListDatesViewController
@synthesize timeCreated;
@synthesize timeFinished;
@synthesize alarm;
@synthesize viewSize;

- (id)initWithCreationDateOfList:(NSDate *)time1 andFinishDate:(NSDate *)time2 andAlarm:(NSDate *)alarm1{
    self = [super init];
    if (self){
        self.timeCreated = time1;
        self.timeFinished = time2;
        self.alarm = alarm1;
        
        self.title = @"";
        // Do any additional setup after loading the view.
        CGFloat height = kOneDateHeightFont13;
        if (timeFinished||alarm)
            height = kTwoDatesHeightFont13;
        UITextView * textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, kLineWidthFont13, height)];
        textView.backgroundColor = [self.view backgroundColor];
        textView.textColor = [UIColor whiteColor];
        textView.font = [UIFont boldSystemFontOfSize:13];
        textView.scrollEnabled =NO;
        textView.editable = NO;
        
        //set up date
        NSString *creation;
        NSString *finishOrAlarm;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        
        NSString *timeCreatedStr = [dateFormatter stringFromDate:timeCreated];
        NSString* format = NSLocalizedString(@"It is created on \n%@", @"todo list creation time tag");
        creation = [NSString stringWithFormat:format,timeCreatedStr];
        
        if (timeFinished != nil){
            NSString *timeFinishedStr = [dateFormatter stringFromDate:timeFinished];
            format = NSLocalizedString(@"It is finished on \n%@", @"todo list finish time tag");
            finishOrAlarm = [NSString stringWithFormat:format,timeFinishedStr];
            textView.text = [NSString stringWithFormat:@"%@\n\n%@",finishOrAlarm, creation];
        } else if (alarm != nil){
            NSString *timeAlarmStr = [dateFormatter stringFromDate:alarm];
            format = NSLocalizedString(@"The alarm is on \n%@", @"todo list alarm time tag");
            finishOrAlarm = [NSString stringWithFormat:format,timeAlarmStr];
            textView.text = [NSString stringWithFormat:@"%@\n\n%@",finishOrAlarm, creation];
        }else{
            textView.text = [NSString stringWithFormat:@"%@",creation];
        }
        
        //display text
        [self.view addSubview:textView];
        
        viewSize = textView.frame.size;
        
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
