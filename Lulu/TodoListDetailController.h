//
//  todoListDetailController.h
//  Lulu
//
//  Created by Dingzhong Weng on 6/10/12.
//  Copyright (c) 2012 Worcester Polytechnique Institute. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "Todolist.h"
#import "Todo.h"
#import "Settings.h"
#import "AutosizeTableView.h"
#define kNumberOfSections 1
#define kTextViewTodoTextWidth 143.0f
#define kLabelTextWidth 170.0f
#define kAlarmClockFrame CGRectMake(0, 0, 35, 35)
#define kTitleColor [UIColor colorWithRed:188.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:1]

@protocol TodoListDetailDelegate;

@interface TodoListDetailController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,AppDelegateDelegate>{
#define kFullAlphaScrollPoint 43
}

@property (strong,nonatomic) Todolist * todoList;
@property NSInteger totalRows;
@property (strong,nonatomic) NSMutableArray *todos;
@property (strong,nonatomic) NSIndexPath *parentCellIndexPath;
@property BOOL debugMode;
@property (strong,nonatomic) Settings *settings;
@property (strong,nonatomic) id <TodoListDetailDelegate> delegate;
@property (strong,nonatomic) IBOutlet AutosizeTableView *tableView;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) IBOutlet UITextView *titleView;
@property (strong,nonatomic) IBOutlet UIView *addingView;
@property (strong,nonatomic) IBOutlet UIButton *addTodoBtn;
@property (strong,nonatomic) IBOutlet UIButton *deleteList;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UILabel *leftQuo;
@property (strong, nonatomic) IBOutlet UILabel *rightQuo;
//alarm clock
@property (strong,nonatomic) IBOutlet UIButton *alarmClock;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIView *alarmView;
@property (strong, nonatomic) NSDate *temperaryDate;
//return
@property (strong,nonatomic) IBOutlet UIView *pullView;
@property (strong, nonatomic) IBOutlet UIImageView *letters;
@property (strong, nonatomic) IBOutlet UIImageView *pull;
//sound
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	closeFileObject;
@property (readonly)    SystemSoundID   deleteFileObject;
//image
//@property (strong, nonatomic) IBOutlet UIView *addImageAccessoryView;
//@property (strong, nonatomic) IBOutlet UIButton *addImageBtn;
//guide
@property (strong, nonatomic) IBOutlet UIView *guideView;
@property (strong, nonatomic) IBOutlet UIImageView *tap;
@property (strong, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) IBOutlet UIImageView *prompt;
//AccidentProtection
@property (strong, nonatomic) NSString* addingMSG;


//IBActions
-(IBAction)acceptNewTodo:(id)sender;
-(IBAction)declineTodo:(id)sender;
-(IBAction)invokeKeyboard:(id)sender;
-(IBAction)resignKeyBoard:(id)sender;
-(IBAction)setButtonClicked:(id)sender;
-(IBAction)cancelBtnClicked:(id)sender;
-(IBAction)changeAlarm:(id)sender;
-(IBAction)setEdit:(id)sender;
-(IBAction)scrollToTop:(id)sender;
-(IBAction)scrollToBottom:(id)sender;
//Miscs
-(void)debug:(id)object orFunctionOrNil:(NSString *)function withItsStringOrNil:(NSString *)itsString;
-(void)save:(NSManagedObject *)object;
-(CGSize)sizeForString:(NSString *)string WithWidth:(CGFloat) width;
-(UIFont*) getFontTofitInRect:(CGRect) rect forText:(NSString*) texts;
-(void)showAddingTextField;
-(void)hideAddingTextField;
-(void)deleteTodoList;
-(void)deleteTodoAtRow:(NSInteger)row;
-(void)addTodoForEvent:(NSString*)aEvent;
-(void)resizeScrollView;
-(void)sortTodos;
-(void)resetDisplayOrderFromSourceRow:(NSInteger)sourceRow ToDestinationRow:(NSInteger)destinationRow;
-(void)listEmptyCheckAfterDeletion:(NSString*)aEvent;
-(void)reloadTableView;
//Alarm Clock Support
-(void)addNewAlarm;
-(void)deleteOldAlarm;
-(void)modifyCurrentAlarm;
-(void)presentAlarmView;
-(void)dismissAlarmView;
-(void)createAlarmClock;
-(void)createAddAlarmClock;
-(void)createDeleteAlarmClock;
-(void)setLabel:(NSDate *)date;
-(void)scheduleLocalNotificationForDate:(NSDate*)date;
-(void)cancelLocalNotificationOfTodoList:(Todolist*)aList;
//Image Support
//-(IBAction)addImageButtonTapped:(id)sender;

@end

@protocol TodoListDetailDelegate <NSObject>
-(void)todoListDetailController:(TodoListDetailController*)todoListDetailController updateParentCellAtIndexPath:(NSIndexPath*)indexPath isDeleted:(BOOL)deleted;

@end


