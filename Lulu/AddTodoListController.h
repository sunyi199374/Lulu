//
//  addTodoListController.h
//  Lulu
//
//  Created by Dingzhong Weng on 6/17/12.
//  Copyright (c) 2012 Worcester Polytechnique Institute. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import "Todolist.h"
#import "Todo.h"
@protocol AddTodoDelegate;

#define kNumOfSections 2
#define kTitleSection 0
#define kTodosSection 1
@interface AddTodoListController : UIViewController <UIActionSheetDelegate,UIGestureRecognizerDelegate,UITextViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) NSManagedObjectContext *context;
@property (nonatomic,strong) IBOutlet UITextField *titleField;
@property (nonatomic,strong) IBOutlet UITextView *content;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong,nonatomic) IBOutlet UIView * inputAccessoryView;
@property (nonatomic,strong) IBOutlet UIGestureRecognizer *gestureRecognizer;
@property (nonatomic,strong) IBOutlet UIButton *btnPrev;
@property (nonatomic,strong) IBOutlet UIButton *btnNext;
@property (nonatomic,strong) Todolist *todoList;
@property (nonatomic,strong) id <AddTodoDelegate> delegate;
@property BOOL isTextViewEditing;
//sound
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	closeFileObject;

// Text Field Methods
- (void)textFieldOnReturn;
//Button Support
- (IBAction)buttonTapped:(id)sender;
- (IBAction)gotoPrevEntry:(id)sender;
- (IBAction)gotoNextEntry:(id)sender;
- (IBAction)accept:(id)sender;
- (IBAction)decline:(id)sender;
//miscs
- (BOOL)hasNext:(NSRange) nextLine;
- (BOOL)hasPrev:(NSRange) prevLine;
- (void)save;
- (void)addTodo:(NSString*)aEvent Order:(NSInteger) displayOrder;
- (void)cancel;
- (void)dismissView;
-(NSRange)findReturnInString:(NSString *)string withSelectedRange:(NSRange) selectedRange toTheEnd:(BOOL) to;
-(void)enableButton:(UIButton*)button enabled:(BOOL)enabled;
@end


@protocol AddTodoDelegate <NSObject>
//todoList nil on cancel
-(void)addTodoListController:(AddTodoListController *)addTodoListController didAddTodoList:(Todolist *)todoList;

@end