//
//  todoListDetailController.m
//  Lulu
//
//  Created by Dingzhong Weng on 6/10/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//


// For further development, Detail view will have a circle button in the bottom that allows user to add todos, also when not in editing mode, cell label resizes to fit the text, when in editing mode, cell textView automatically adjust its size when editing.

#import "TodoListDetailController.h"
#include <stdlib.h>

#define kEditTag 0
#define kDoneTag 1

@interface TodoListDetailController ()
@end

@implementation TodoListDetailController
@synthesize editButton;
@synthesize settings,debugMode;
@synthesize pull,letters,pullView;
@synthesize todoList,totalRows,todos,parentCellIndexPath,delegate,tableView;
@synthesize datePicker,dateLabel,alarmView,temperaryDate;
@synthesize alarmClock,deleteList,addTodoBtn,scrollView;
@synthesize addingView,addingMSG;
@synthesize titleView,leftQuo,rightQuo;
@synthesize closeFileObject,soundFileURLRef,deleteFileObject;
@synthesize tap,arrow,prompt,guideView;
//@synthesize addImageBtn,addImageAccessoryView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}
- (void) viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	//set titleView text
	titleView.delegate = self;
	titleView.text = [NSString stringWithFormat:@"%@",self.todoList.title];
	titleView.font = [self getFontTofitInRect:titleView.frame forText:titleView.text];
	leftQuo.font = rightQuo.font = [UIFont fontWithName:@"GillSans-Bold" size:titleView.font.pointSize*2];
	
	self.view.alpha =1;
	[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:NO];
	
	if (todoList.alarm == nil)
		alarmClock.hidden = YES;
	
	NSLog(@"detailView: viewWillAppear!");
	
}

- (void) viewWillDisappear:(BOOL)animated{
	[self save:todoList];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	//set alarm properties
	[[NSBundle mainBundle]loadNibNamed:@"AlarmClockModal" owner:self options:nil];
	datePicker.minimumDate = [NSDate date];
	temperaryDate = nil;
	alarmView.alpha = 0.0f;
	
	//set alarm button view
	if (todoList.alarm){
		[self createAlarmClock];
		alarmClock.hidden = NO;
	} else
		alarmClock.hidden = YES;
	
	//set add todo text as well as the button
	addingView.hidden = YES;
	[addTodoBtn addTarget:self action:@selector(showAddingTextField) forControlEvents:UIControlEventTouchUpInside];
	UITextField *textField = (UITextField*)[addingView viewWithTag:1000];
	[textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	addingMSG = textField.text;
   
	//set delete button action
	[deleteList addTarget:self action:@selector(deleteTodoList) forControlEvents:UIControlEventTouchUpInside];
	
	//set table view properties
	[self sortTodos];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.backgroundColor = [UIColor clearColor];
	[self.tableView reloadData];
	[self.tableView layoutIfNeeded];
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height = [self.tableView contentSize].height;
	self.tableView.frame = newFrame;
	
	//set scroll view properties
	self.scrollView.canCancelContentTouches = NO;
	self.scrollView.layer.cornerRadius = 22.0f;
	[self resizeScrollView];
	self.scrollView.delegate = self;
	self.pullView.alpha = 0;
	
	//set title view properties
	titleView.backgroundColor = [UIColor clearColor];
	titleView.textColor = leftQuo.textColor = rightQuo.textColor = kTitleColor;
	
	//sound
	NSURL *closeSound   = [[NSBundle mainBundle] URLForResource: @"ViewClose"
																 withExtension: @"aif"];
	// Store the URL as a CFURLRef instance
	self.soundFileURLRef = (__bridge CFURLRef) closeSound;
	// Create a system sound object representing the sound file.
	AudioServicesCreateSystemSoundID (soundFileURLRef, &closeFileObject);
	
	NSURL *deleteSound   = [[NSBundle mainBundle] URLForResource: @"Delete"
                                                  withExtension: @"aif"];
	// Store the URL as a CFURLRef instance
	self.soundFileURLRef = (__bridge CFURLRef) deleteSound;
	// Create a system sound object representing the sound file.
	AudioServicesCreateSystemSoundID (soundFileURLRef, &deleteFileObject);
	
	//first time show, show guide
	if (settings.firstTimeShowInDetailsView.boolValue){
		guideView.hidden = NO;
		CGRect frame = arrow.frame;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationRepeatCount:2];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:.6];
		CGRect newFrame = frame;
		newFrame.size.height = 0;
		arrow.frame = newFrame;
		arrow.frame = frame;
		[UIView commitAnimations];
		
		UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(notFirstTime)];
		recog.numberOfTapsRequired = 1;
		[guideView addGestureRecognizer:recog];
	}else{
		guideView.hidden =YES;
	}
	
	((AppDelegate*)[[UIApplication sharedApplication]delegate]).appDel = self;
	
	//image support
	//[[NSBundle mainBundle] loadNibNamed:@"inputAccessoryViewForDetail" owner:self options:nil];
}

-(void)notFirstTime{
	settings.firstTimeShowInDetailsView = [NSNumber numberWithBool:NO];
	guideView.hidden = YES;
	[self save:settings];
	
	[guideView removeGestureRecognizer:[[guideView gestureRecognizers]objectAtIndex:0]];
}

- (void)viewDidUnload
{
	[self save:todoList];
	guideView = nil;
	settings = nil;
	todoList = nil;
	parentCellIndexPath = nil;
	todos = nil;
	delegate = nil;
	tableView = nil;
	scrollView = nil;
	titleView = nil;
	addTodoBtn = nil;
	addingView = nil;
	deleteList = nil;
	alarmClock = nil;
	alarmView = nil;
	dateLabel = nil;
	datePicker = nil;
	temperaryDate = nil;
	[self setPull:nil];
	[self setEditButton:nil];
	pullView = nil;
	letters = nil;
	leftQuo= nil;
	rightQuo= nil;
	//addImageAccessoryView = nil;
	//addImageBtn = nil;
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Scroll View Delegate Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (self.scrollView.contentOffset.y<-40){
		[self.navigationController popViewControllerAnimated:NO];
		[self dismissViewControllerAnimated:NO completion:NULL];
		AudioServicesPlaySystemSound(closeFileObject);
		[self debug:nil orFunctionOrNil:@"scrollViewDidEndDragging" withItsStringOrNil:[NSString stringWithFormat:@"The detail view is dismissed"]];
	}
	
	[self debug:nil orFunctionOrNil:@"scrollViewDidEndDragging" withItsStringOrNil:[NSString stringWithFormat:@"the contentOffset.y is %f",self.scrollView.contentOffset.y]];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//CGRect newFrame = [self.view convertRect:self.tableView.frame fromView:nil];
	//newFrame.origin.y = 179-self.scrollView.contentOffset.y/3;
	//self.tableView.frame = newFrame;
	//set visibility of pull
	CGFloat alpha = - self.scrollView.contentOffset.y/kFullAlphaScrollPoint;
	if (alpha<0)
		alpha = 0;
	else if (alpha>1)
		alpha = 1;
	pullView.alpha = alpha;
	if (self.scrollView.contentOffset.y>-40){
		pull.transform = CGAffineTransformMakeRotation(3.142);
		letters.image = [UIImage imageNamed:NSLocalizedString(@"pulllettersimage",@"detail view pull letters tag")];
	} else{
		pull.transform = CGAffineTransformMakeRotation(0);
		letters.image = [UIImage imageNamed:NSLocalizedString(@"releaselettersimage",@"detail view release letters tag")];
	}
	
	if (self.scrollView.contentOffset.y<-48)
		self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -48.0f);
	
	[self debug:nil orFunctionOrNil:@"scrollViewDidScroll" withItsStringOrNil:[NSString stringWithFormat:@"content offset y is %f",self.scrollView.contentOffset.y]];
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	[self debug:nil orFunctionOrNil:@"numberOfSectionsInTableView" withItsStringOrNil:nil];
	return kNumberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	[self debug:nil orFunctionOrNil:@"numberOfRowsInSection" withItsStringOrNil:[NSString stringWithFormat:@"%i",totalRows]];
	return totalRows;
}


//new feature: picture and audio compatible
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = [indexPath row];
	NSString *aText = @"";
	UITableViewCellSelectionStyle selectionStyle=UITableViewCellSelectionStyleGray;
	NSMutableString *identifier = [NSString stringWithFormat:@"plainCell"];
	
	if (self.editing)
		selectionStyle = UITableViewCellSelectionStyleNone;
	
	aText = [NSString stringWithString:[[todos objectAtIndex:row] event]];
	//configure the cell and initialize cell properties
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
	cell.selectionStyle = selectionStyle;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	CGSize size;
	UITextView *textView = (UITextView *)[cell viewWithTag:4];
	UILabel *cellLabel = (UILabel *)[cell viewWithTag:3];
	if (self.editing){
		size = [self sizeForString:aText WithWidth:kTextViewTodoTextWidth];
		
		if (textView == nil) {
			textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 5, 160, (size.height > 34.5f) ? size.height + 14.5f: 34.5f)];
			
			textView.opaque = YES;
			textView.contentMode = UIViewContentModeTop;
			textView.delaysContentTouches = YES;
			textView.textAlignment = NSTextAlignmentLeft;
			textView.font = [UIFont boldSystemFontOfSize:16];
			textView.textColor = [UIColor whiteColor];
			textView.returnKeyType = UIReturnKeyDefault;
			textView.backgroundColor = [cell backgroundColor];
			textView.delaysContentTouches = YES;
			textView.returnKeyType = UIReturnKeyDone;
			textView.scrollEnabled = NO;
			textView.autocorrectionType = UITextAutocorrectionTypeNo;
			textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
			
			[cell addSubview:textView];
			//[self debug:nil orFunctionOrNil:@"cellForRowAtIndexPath" withItsStringOrNil:[NSString stringWithFormat:@"created a text view %@",textView]];
		} else {
			[cell bringSubviewToFront:textView];
			textView.hidden = NO;
		}
		
		if (cellLabel !=nil)
			cellLabel.hidden = YES;
		
		textView.delegate = self;
		textView.text = aText;
		textView.tag = 4;
		
	} else {
		size = [self sizeForString:aText WithWidth:kLabelTextWidth];
		if (cellLabel == nil) {
			cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 5, 180, (size.height > 34.5f) ? size.height + 14.5f: 34.5f)];
			cellLabel.opaque = NO;
			cellLabel.textAlignment = NSTextAlignmentLeft;
			cellLabel.contentMode = UIViewContentModeTopLeft;
			cellLabel.font = [UIFont boldSystemFontOfSize:16];
			cellLabel.lineBreakMode = NSLineBreakByWordWrapping;
			cellLabel.backgroundColor = [UIColor clearColor];
			
			//[self debug:nil orFunctionOrNil:@"cellForRowAtIndexPath" withItsStringOrNil:[NSString stringWithFormat:@"created a label for row %i, section %i.",row,section]];
			[cell addSubview:cellLabel];
			
		} else {
			[cellLabel setFrame:CGRectMake(18, 5, 180, size.height + 14.5f)];
			cellLabel.hidden = NO;
		}
		
		if (textView != nil){
			[cell sendSubviewToBack:textView];
			textView.hidden =YES;
		}
		//set text color to cell label, when todo is done, set accessoryType as well.
		if ([[[todos objectAtIndex:row]isDone]boolValue]){
			UIImageView *checkMark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 18, 12, 10)];
			checkMark.image = [UIImage imageNamed:@"TLCheckMarkUN.png"];
			checkMark.autoresizesSubviews = YES;
			cell.accessoryView = checkMark;
			cellLabel.textColor = [UIColor lightGrayColor];
		} else {
			cell.accessoryView = nil;
			cellLabel.textColor = [UIColor whiteColor];
		}
		
		cellLabel.numberOfLines = (int) (size.height / 20);
		cellLabel.text = aText;
		cellLabel.tag = 3;
		
	};
	
	[self debug:nil orFunctionOrNil:@"cellForRowAtIndexPath"
withItsStringOrNil:[NSString stringWithFormat:@"The cell has width %f, height%f, label has width %f,textview has width %f",cell.frame.size.width,cell.frame.size.height,cellLabel.frame.size.width,textView.frame.size.width]];
	
	return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat theHeight;
	NSString *testString;
	CGSize size;
	NSInteger row = [indexPath row];
	Todo *todo = [todos objectAtIndex:row];
	testString = todo.event;
	
	if (self.editing)
		size = [self sizeForString:testString WithWidth:kTextViewTodoTextWidth];
	else
		size = [self sizeForString:testString WithWidth:kLabelTextWidth];
	
	theHeight = (size.height > 20) ? size.height + 26.0f:46.0f;
	//NSLog(@"theHeight is %f",theHeight);
	return theHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0;
}
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
-(void)setAllDone:(id)sender{
	BOOL allDone = todoList.allDone.boolValue;
	todoList.allDone = [NSNumber numberWithBool:!allDone];
}

#define mark -
#define Table View Delegate Method
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView beginUpdates];
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		[self debug:nil orFunctionOrNil:@"commitEditingStyle(Delete)" withItsStringOrNil:[NSString stringWithFormat:@"deletion happens on section %i, row %i",[indexPath section],[indexPath row]]];
		
		//stop displaying it
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		//delete the managed object for the given index path
		[self deleteTodoAtRow:[indexPath row]];
		
	}
	[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:NO];
	
	[self save:todoList];
	[self.tableView endUpdates];
	
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	/*UITableViewCell *cell;
    UILabel *cellLabel;
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cellLabel = (UILabel *)[cell viewWithTag:3];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cellLabel.textColor = [UIColor grayColor];*/
	Todo *todo = [todos objectAtIndex:[indexPath row]];
	if (!todo.isDone.boolValue) {
		todo.isDone = [NSNumber numberWithBool:YES];
		
		NSInteger onGoing =[todoList.onGoing intValue];
		onGoing --;
		todoList.onGoing = [NSNumber numberWithInt:onGoing];
		
		//when it is done, move it to the bottom, number it with totalRows and switch numbers on the other todos as well
		[self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:totalRows-1 inSection:0]];
		NSUInteger sourceRow = [indexPath row];
		NSUInteger destinationRow = totalRows-1;
		[todos removeObjectAtIndex:sourceRow];
		[todos insertObject:todo atIndex:destinationRow];
		
		[self resetDisplayOrderFromSourceRow:sourceRow ToDestinationRow:destinationRow];
		
		NSLog(@"todo is Done (%@)", todo.isDone);
	} else {
		//cell.accessoryType = UITableViewCellAccessoryNone;
		//cellLabel.textColor = [UIColor whiteColor];
		
		NSInteger onGoing =[todoList.onGoing intValue];
		onGoing ++;
		todoList.onGoing = [NSNumber numberWithInt:onGoing];
		
		//when it is undone, find the last undone item, move todo to just beneath it, and number it with that row +1
		for (int i =totalRows -1;i>=0;i--){
			Todo* aTodo = (Todo*)[todos objectAtIndex:i];
			if (!aTodo.isDone.boolValue){
				[self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0]];
				NSUInteger sourceRow = [indexPath row];
				NSUInteger destinationRow = i+1;
				[todos removeObjectAtIndex:sourceRow];
				[todos insertObject:todo atIndex:destinationRow];
				[self resetDisplayOrderFromSourceRow:sourceRow ToDestinationRow:destinationRow];
				todo.isDone = [NSNumber numberWithBool:NO];
				break;
			} else if (aTodo.isDone.boolValue && i ==0){
				[self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
				NSUInteger sourceRow = [indexPath row];
				NSUInteger destinationRow = 0;
				[todos removeObjectAtIndex:sourceRow];
				[todos insertObject:todo atIndex:destinationRow];
				[self resetDisplayOrderFromSourceRow:sourceRow ToDestinationRow:destinationRow];
				todo.isDone = [NSNumber numberWithBool:NO];
				break;
			}
		}
		
		NSLog(@"todo is Undone (%@)", todo.isDone);
	}
	
	//NSLog(@"didSelectRow: there are %i on going events, updating the parent cell text color",todoList.onGoing.intValue);
	
	if (todoList.onGoing.intValue == 0 && todoList.alarm){
		[self deleteOldAlarm];
	}
	
	[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:NO];
	[self save:todo];
	[self.tableView reloadData];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSIndexPath *target = proposedDestinationIndexPath;
	NSInteger proposedRow = proposedDestinationIndexPath.row;
	
	if (proposedRow<0)
		target = [NSIndexPath indexPathForRow:0 inSection:0];
	else if (proposedRow > totalRows-1)
		target = [NSIndexPath indexPathForRow:totalRows-1 inSection:0];
	
	return target;
}


#pragma Editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
	[super setEditing:editing animated:animated];
	if (editing){
		self.titleView.editable = YES;
		self.tableView.editing = YES;
		
		if (todoList.alarm){
			[self createDeleteAlarmClock];
			alarmClock.hidden = NO;
		} else {
			[self createAddAlarmClock];
			alarmClock.hidden = NO;
		}
		
		[self reloadTableView];
		
	} else if (!editing) {
		self.titleView.editable = NO;
		self.tableView.editing = NO;
		
		if (todoList.alarm){
			[self createAlarmClock];
			alarmClock.hidden = NO;
		} else
			alarmClock.hidden = YES;
		/*
		 If editing is finished, save the managed object context.
		 */
		[self save:todoList];
		[self reloadTableView];
	}
	
}

#pragma Text View Delegate : Auto Resize and Resign Keyboard
-(void)textViewDidBeginEditing:(UITextView *)textView{
	if (textView.tag != 9999){
		CGPoint point;
		CGRect rect = [textView bounds];
		rect = [textView convertRect:rect toView:self.scrollView];
		point = rect.origin;
		point.x = 0;
		point.y -= 70;
		[scrollView setContentOffset:point animated:YES];
		
		//if image is added, disable the button, otherwise, enable it.
		///textView.inputAccessoryView = addImageAccessoryView;
	} else {
		//addImageBtn.enabled = NO;
		textView.inputAccessoryView = nil;
	}
}

-(void)textViewDidChange:(UITextView *)textView {
	if (textView.tag != 9999){
		UITableViewCell *cell = (UITableViewCell *)[textView superview];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		NSInteger row = [indexPath row];
		Todo *todo = [todos objectAtIndex:row];
		todo.event = textView.text;
		//change size of frame if changed
		CGRect frame = textView.frame;
		frame.size = textView.contentSize;
		if (frame.size.height>textView.frame.size.height ||frame.size.height<textView.frame.size.height){
			textView.frame = frame;
			[self.tableView beginUpdates];
			[self.tableView endUpdates];
			[self debug:nil orFunctionOrNil:@"hasChange" withItsStringOrNil:[NSString stringWithFormat:@"text content height %f, text frame height is %f, text frame width is %f, text frame origin x is %f, text frame origin y is %f.", textView.contentSize.height,textView.frame.size.height,textView.frame.size.width,textView.frame.origin.x,textView.frame.origin.y]];
		}
		
	} else {
		titleView.font = [self getFontTofitInRect:titleView.frame forText:todoList.title];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if([text isEqualToString:@"\n"]) {
		if (textView.tag == 9999){
			self.todoList.title = textView.text;
			titleView.font = [self getFontTofitInRect:titleView.frame forText:todoList.title];
			[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:NO];
		}else {
			UITableViewCell *cell = (UITableViewCell*)[textView superview];
			NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
			NSInteger row = [indexPath row];
			//if (debugMode) NSLog(@"The cell is at section %i, row %i. Text View has tag %i",[indexPath section],[indexPath row],textView.tag);
			
			[self.tableView beginUpdates];
			Todo *todo= [todos objectAtIndex:row];
			//if text is nil, delete the row, else, update the row
			if ([textView.text isEqualToString:@""]){
				[self deleteTodoAtRow:row];
				
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
											 withRowAnimation:UITableViewRowAnimationTop];
				
			} else if (![todo.event isEqualToString:textView.text])
				todo.event = textView.text;
			
			//save
			[self save:todoList];
			
			[self.tableView endUpdates];
		}
		
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}

#pragma Text Field Delegate : Auto Resize and Resign Keyboard
-(void)textFieldDidBeginEditing:(UITextField *)textField{
	if (![addingMSG isEqualToString:@""])
		textField.text = addingMSG;
}

-(void)textFieldDidChange:(id)sender{
	UITextField *textField = (UITextField*)sender;
	addingMSG = textField.text;
	UIButton *acceptButton = (UIButton*)[addingView viewWithTag:2000];
	if (textField.tag == 1000){
		if ([textField.text isEqualToString:@""])
			acceptButton.enabled = NO;
		else
			acceptButton.enabled = YES;
	}
	
}


#pragma IBAction
-(IBAction)acceptNewTodo:(id)sender{
	UITextField *textField = (UITextField*)[addingView viewWithTag:1000];
	if (![textField.text isEqualToString:@""]){
		[self addTodoForEvent:textField.text];
		addingMSG = @"";
		[self hideAddingTextField];
	}
}

-(IBAction)declineTodo:(id)sender{
	UITextField *textField = (UITextField*)[addingView viewWithTag:1000];
	[textField resignFirstResponder];
	textField.text = @"";
	addingMSG = @"";
	[self hideAddingTextField];
}


-(IBAction)invokeKeyboard:(id)sender{
	[sender becomeFirstResponder];
}

-(IBAction)resignKeyBoard:(id)sender{
	[sender resignFirstResponder];
}

-(IBAction)setButtonClicked:(id)sender{
	//set alarm notification or update if it has one already
	if (todoList.alarm)
		[self cancelLocalNotificationOfTodoList:todoList];
	todoList.alarm = temperaryDate;
	[self scheduleLocalNotificationForDate:todoList.alarm];
	//switch add to delete
	if (self.editing){
		[self createDeleteAlarmClock];
		alarmClock.hidden = NO;
	} else {
		[self createAlarmClock];
		alarmClock.hidden = NO;
	}
	
	//update parent view
	[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:NO];
	[self dismissAlarmView];
	
}

-(IBAction)cancelBtnClicked:(id)sender{
	temperaryDate = nil;
	[self dismissAlarmView];
}

-(IBAction)changeAlarm:(id)sender{
	NSDate *date = [(UIDatePicker *)sender date];
	temperaryDate = date;
	[self setLabel:date];
}

-(IBAction)setEdit:(id)sender{
	if (self.editing){
		[self setEditing:NO animated:YES];
		[self.editButton setImage:[UIImage imageNamed:@"TLEditButtonUN.png"] forState:UIControlStateNormal];
	}else{
		[self setEditing:YES animated:YES];
		[self.editButton setImage:[UIImage imageNamed:@"TLEditButtonPressedUN.png"] forState:UIControlStateNormal];
	}
}

-(IBAction)scrollToTop:(id)sender{
	[self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(IBAction)scrollToBottom:(id)sender{
	[self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height-590) animated:YES];
}

#pragma Miscs
-(void)debug:(id)object orFunctionOrNil:(NSString *)function withItsStringOrNil:(NSString *)itsString{
	if (debugMode){
		if (object)
			NSLog(@"Class %@,\nObject %@",[object class],object);
		else if (function){
			if (itsString)
				NSLog(@"%@:%@",function,itsString);
			else
				NSLog(@"Called %@",function);
		}
	}
	
}

-(void)save:(NSManagedObject *)object{
	NSError *error = nil;
	if (![object.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

-(CGSize) sizeForString:(NSString *)string WithWidth:(CGFloat)width {
	
	CGSize size = [string sizeWithFont:[UIFont boldSystemFontOfSize:16]
						  constrainedToSize:CGSizeMake(width, MAXFLOAT)
								lineBreakMode:NSLineBreakByWordWrapping];
	
	return size;
}

-(UIFont*) getFontTofitInRect:(CGRect) rect forText:(NSString*) text {
	CGFloat baseFont=0;
	UIFont *myFont=[UIFont fontWithName:@"GillSans-Bold" size:baseFont];
	CGSize fSize;
	CGFloat step=0.1f;
	
	BOOL stop=NO;
	CGFloat previousH=0;
	while (!stop) {
		myFont=[UIFont fontWithName:@"GillSans-Bold" size:(baseFont)];
		fSize=[text sizeWithFont:myFont constrainedToSize:rect.size lineBreakMode:NSLineBreakByWordWrapping];
		
		if(fSize.height+myFont.lineHeight>rect.size.height){
			myFont=[UIFont fontWithName:@"GillSans-Bold" size:previousH];
			stop=YES;
		}else {
			previousH=baseFont;
		}
		
		baseFont += step;
	}
	
	return myFont;
	
}

-(void)showAddingTextField{
	UIButton *acceptButton = (UIButton*)[addingView viewWithTag:2000];
	acceptButton.enabled = NO;
	addingView.hidden = NO;
	addTodoBtn.enabled = NO;
	self.tableView.userInteractionEnabled = NO;
}

-(void)hideAddingTextField{
	((UITextField*)[addingView viewWithTag:1000]).text = @"";
	addingView.hidden = YES;
	addTodoBtn.enabled = YES;
	self.tableView.userInteractionEnabled = YES;
	[(UITextField*)[addingView viewWithTag:1000] resignFirstResponder];
	
}

-(void)deleteTodoList{
	//discard button string
	NSString *confirm = [NSString stringWithFormat:NSLocalizedString(@"confirmFormat", @"confirm button text")];
	
	//cancel button string
	NSString *cancel = [NSString stringWithFormat:NSLocalizedString(@"cancelFormat", @"cancel button text")];
	
	//title
	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Delete This List", @"Delete This List")];
	
	//message
	NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Are you sure?", @"Are you sure")];
	
	// create alert view for its action
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
																  message:msg
																 delegate:self
													 cancelButtonTitle:cancel
													 otherButtonTitles:confirm , nil];
	alert.alertViewStyle = UIAlertViewStyleDefault;
	
	[alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 1:
		{
			NSManagedObjectContext *context = [todoList managedObjectContext];
			[context deleteObject:todoList];
			for (int i=0;i<[todos count];i++){
				[context deleteObject:[todos objectAtIndex:i]];
			}
			AudioServicesPlayAlertSound(deleteFileObject);
			//[self save:todoList];
			[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:YES];
			[self.navigationController popViewControllerAnimated:NO];
			break;
		}
			
		default:
			break;
	}
}

-(void)deleteTodoAtRow:(NSInteger)row{
	Todo *todo = [todos objectAtIndex:row];
	NSString *event = [NSString stringWithString:todo.event];
	//[self debug:nil orFunctionOrNil:@"deleteTodoAtRow" withItsStringOrNil:[NSString stringWithFormat:@"Before list empty check, the event is %@",todo.event]];
	[todoList removeTodosObject:todo];
	[todos removeObjectAtIndex:row];
	[todo.managedObjectContext deleteObject:todo];
	NSInteger onGoing = todoList.onGoing.intValue;
	onGoing --;
	todoList.onGoing = [NSNumber numberWithInt:onGoing];
	totalRows --;
	//update display order on todos
	[self resetDisplayOrderFromSourceRow:row ToDestinationRow:totalRows-1];
	//empty list check
	[self listEmptyCheckAfterDeletion:event];
	
	[self.tableView reloadData];
}

-(void)addTodoForEvent:(NSString*)aEvent{
	NSManagedObjectContext *context = [todoList managedObjectContext];
	Todo *todo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:context];
	todo.event = [NSString stringWithString:aEvent];
	todo.isDone = [NSNumber numberWithBool:NO];
	todo.displayOrder = [NSNumber numberWithInt:totalRows];
	[todoList addTodosObject:todo];
	[todos addObject:todo];
	
	//update ongoings
	NSInteger onGoing = todoList.onGoing.intValue;
	onGoing ++;
	todoList.onGoing = [NSNumber numberWithInt:onGoing];
	
	//sort array
	[self sortTodos];
	
	//display it
	[self debug:nil orFunctionOrNil:@"addTodoForEvent" withItsStringOrNil:[NSString stringWithFormat:@"aEvent is %@, totalRows are %i",aEvent,totalRows]];
	[self resizeScrollView];
	[self save:todoList];
	[self.tableView reloadData];
	
}

-(void)resizeScrollView{
	CGFloat scrollHeight = self.tableView.frame.size.height + 358;
	self.scrollView.contentSize = CGSizeMake(275, scrollHeight>590? scrollHeight:590);
	CGRect frame = deleteList.frame;
	frame.origin.y = self.scrollView.contentSize.height - 60;
	[deleteList setFrame:frame];
}
-(void)sortTodos{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	NSMutableArray *sortedTodos = [[NSMutableArray alloc] initWithArray:[todoList.todos allObjects]];
	[sortedTodos sortUsingDescriptors:sortDescriptors];
	self.todos= sortedTodos;
	totalRows = [todos count];
	NSLog(@"totalRow %i",totalRows);
	
}

-(void)resetDisplayOrderFromSourceRow:(NSInteger)sourceRow ToDestinationRow:(NSInteger)destinationRow{
	NSInteger start = sourceRow;
	if (destinationRow < start) {
		start = destinationRow;
	}
	NSInteger end = destinationRow;
	if (sourceRow > end) {
		end = sourceRow;
	}
	
	Todo* aTodo;
	if (end<[todos count]){
		[self debug:nil orFunctionOrNil:@"resetDisplayOrder" withItsStringOrNil:[NSString stringWithFormat:@"start is %i, end is %i, capacity is %i",start,end,[todos count]]];
		for (NSInteger i = start; i <= end; i++) {
			aTodo = [todos objectAtIndex:i];
			aTodo.displayOrder = [NSNumber numberWithInteger:totalRows-i-1];
		}
		[self save:todoList];
	}
	
}

//check if todolist is empty, if it is, asking whether to delete the entire list as well or revert last deletion; if it is not, regard as a regular deletion
-(void)listEmptyCheckAfterDeletion:(NSString*)aEvent{
	if ([todos count]==0){
		//lastEvent = aEvent;
		//[self debug:nil orFunctionOrNil:@"listEmptyCheckAfterDeletion" withItsStringOrNil:[NSString stringWithFormat:@"last event is %@",lastEvent]];
		//delete button string
		NSString *delete = [NSString stringWithFormat:NSLocalizedString(@"deleteFormat", @"delete button text")];
		//revert button string
		NSString *keep= [NSString stringWithFormat:NSLocalizedString(@"keepFormat", @"keep button text")];
		
		UIActionSheet *actionSheet = nil;
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		
		actionSheet= [[UIActionSheet alloc]initWithTitle:todoList.title
															 delegate:self
												 cancelButtonTitle:keep
										  destructiveButtonTitle:delete
												 otherButtonTitles:nil];
		
		[actionSheet showInView:self.view];
	}
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == [actionSheet cancelButtonIndex]){
		//if clicked revert button
		/*lastEvent = todoList.title;
		 [self addTodoForEvent:lastEvent];
		 lastEvent = nil;*/
		//[self.navigationController popViewControllerAnimated:NO];
	} else if (buttonIndex == [actionSheet destructiveButtonIndex])
		[self deleteTodoList];
}

-(void)reloadTableView {
	[self.tableView reloadData];
	CGFloat scrollHeight = self.tableView.frame.size.height + 480;
	self.scrollView.contentSize = CGSizeMake(275, scrollHeight>590? scrollHeight:590);
	
}


#pragma Alarm Clock Support
-(void)addNewAlarm{
	//present modal view to set an alarm time;
	[datePicker setDate:[NSDate date]];
	[self changeAlarm:datePicker];
	[self presentAlarmView];
	
}
-(void)deleteOldAlarm{
	temperaryDate = nil;
	
	//remove local alarm notification
	[self cancelLocalNotificationOfTodoList:todoList];
	todoList.alarm = nil;
	
	//switch delete to add
	if (self.editing){
		[self createAddAlarmClock];
		alarmClock.hidden = NO;
	} else
		alarmClock.hidden = YES;
	
	[self debug:nil orFunctionOrNil:@"deleteOldAlarm" withItsStringOrNil:nil];
	
	//update parent view
	[self.delegate todoListDetailController:self updateParentCellAtIndexPath:parentCellIndexPath isDeleted:NO];
	
}

-(void)modifyCurrentAlarm{
	//present modal view to change alarm time;
	[datePicker setDate:todoList.alarm];
	[self setLabel:todoList.alarm];
	temperaryDate = todoList.alarm;
	[self presentAlarmView];
	
}


-(void)presentAlarmView{
	if (alarmView.alpha == 0.0f){
		alarmView.frame = CGRectMake(10, self.view.frame.size.height, alarmView.frame.size.width, alarmView.frame.size.height);
		if ([alarmView superview] == nil)
			[self.view addSubview:alarmView];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.35];
		alarmView.alpha = 1.0f;
		alarmView.center = self.view.center;
		[UIView commitAnimations];
		
		UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc]init];
		tapRecog.delegate = self;
		[self.scrollView addGestureRecognizer:tapRecog];
	}
}

-(void)dismissAlarmView{
	if (alarmView.superview){
		CGRect frame = alarmView.frame;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.35];
		alarmView.alpha = 0.0f;
		frame.origin.y = self.view.frame.size.height;
		alarmView.frame = frame;
		[alarmView removeFromSuperview];
		[UIView commitAnimations];
		for (UIGestureRecognizer *ges in self.scrollView.gestureRecognizers)
			if ([ges isKindOfClass:[UITapGestureRecognizer class]])
				[scrollView removeGestureRecognizer:ges];
	}
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	CGPoint touchPoint = [touch locationInView:self.scrollView];
	//NSString *testStr = [NSString stringWithFormat:@"touchPoint is inside %@",[self.scrollView pointInside:touchPoint withEvent:[[UIEvent alloc]init]]];
	//[self debug:nil orFunctionOrNil:@"shouldReceiveTouch" withItsStringOrNil:testStr];
	if (!CGRectContainsPoint([self.scrollView convertRect:alarmView.frame fromView:self.scrollView], touchPoint))//or from self.view
		[self dismissAlarmView];
	else
		return NO;
	
	return YES;
}

-(void)createAlarmClock{
	[alarmClock setImage:[UIImage imageNamed:@"TLAlarmClockUN.png"] forState:UIControlStateNormal];
	[alarmClock setImage:[UIImage imageNamed:@"TLAlarmClockSelectedUN.png"] forState:UIControlStateHighlighted];
	[alarmClock removeTarget:self action:@selector(deleteOldAlarm) forControlEvents:UIControlEventTouchUpInside];
	[alarmClock removeTarget:self action:@selector(addNewAlarm) forControlEvents:UIControlEventTouchUpInside];
	[alarmClock addTarget:self action:@selector(modifyCurrentAlarm) forControlEvents:UIControlEventTouchUpInside];
}
-(void)createAddAlarmClock{
	//disabled when ongoing is zero
	if (todoList.onGoing.intValue==0){
		[alarmClock setImage:[UIImage imageNamed:@"TLAddAlarmDisableUN.png"] forState:UIControlStateDisabled];
		alarmClock.enabled = NO;
	} else {
		[alarmClock setImage:[UIImage imageNamed:@"TLAddAlarmUN.png"] forState:UIControlStateNormal];
		[alarmClock setImage:[UIImage imageNamed:@"TLAddAlarmSelectedUN.png"] forState:UIControlStateHighlighted];
		alarmClock.enabled = YES;
	}
	
	[alarmClock removeTarget:self action:@selector(deleteOldAlarm) forControlEvents:UIControlEventTouchUpInside];
	[alarmClock removeTarget:self action:@selector(modifyCurrentAlarm) forControlEvents:UIControlEventTouchUpInside];
	[alarmClock addTarget:self action:@selector(addNewAlarm) forControlEvents:UIControlEventTouchUpInside];
}
-(void)createDeleteAlarmClock{
	[alarmClock setImage:[UIImage imageNamed:@"TLDeleteAlarmUN.png"] forState:UIControlStateNormal];
	[alarmClock setImage:[UIImage imageNamed:@"TLDeleteAlarmSelectedUN.png"] forState:UIControlStateHighlighted];
	[alarmClock removeTarget:self action:@selector(modifyCurrentAlarm) forControlEvents:UIControlEventTouchUpInside];
	[alarmClock removeTarget:self action:@selector(addNewAlarm) forControlEvents:UIControlEventTouchUpInside];
	[alarmClock addTarget:self action:@selector(deleteOldAlarm) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setLabel:(NSDate *)date{
	if (date != nil){
		NSString *alarmStr;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setLocale:[NSLocale currentLocale]];
		
		//get day and month and year of current date and alarm date
		NSCalendar *calendar = [NSCalendar currentCalendar];
		unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSWeekdayCalendarUnit;
		NSDate *todayDate = [NSDate date];
		NSDateComponents *comps = [calendar components:unitFlags fromDate:todayDate];
		NSInteger todayYear = [comps year];
		NSInteger todayMonth = [comps month];
		NSInteger todayDay = [comps day];
		NSDateComponents *comps2 = [calendar components:unitFlags fromDate:date];
		NSInteger year = [comps2 year];
		NSInteger month = [comps2 month];
		NSInteger day = [comps2 day];
		NSDateComponents *diff = [calendar components:unitFlags fromDate:todayDate  toDate:date options:NSWrapCalendarComponents];
		NSInteger daysDiff = [diff day];
		
		//convert weekday integer into string
		NSString* weekDay;
		switch ([comps2 weekday]) {
			case 1:{
				weekDay = @"Sunday";
				break;
			}
			case 2:{
				weekDay = @"Monday";
				break;
			}
			case 3:{
				weekDay = @"Tuesday";
				break;
			}
			case 4:{
				weekDay = @"Wednesday";
				break;
			}
			case 5:{
				weekDay = @"Thursday";
				break;
			}
			case 6:{
				weekDay = @"Friday";
				break;
			}
			case 7:{
				weekDay = @"Saturday";
				break;
			}
			default:
				break;
		}
		
		NSLog(@"setLabel:daysDiff %i,todayDate%@, date%@",daysDiff,todayDate,date);
		//assume that the alarm is set to today or tomorrow or this or next week
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		if ([(NSDate*)[date dateByAddingTimeInterval:10] compare:todayDate]<=0)
			alarmStr = @"Now";
		else if (year == todayYear && month == todayMonth && day == todayDay)
			alarmStr = [NSString stringWithFormat:@"Today %@",[dateFormatter stringFromDate:date]];
		else if (year == todayYear && month == todayMonth && day == todayDay+1)
			alarmStr = [NSString stringWithFormat:@"Tomorrow %@",[dateFormatter stringFromDate:date]];
		else if (daysDiff > 1 && daysDiff < 7 && ([comps2 weekday]>[comps weekday] || [comps2 weekday] ==1))
			alarmStr = [NSString stringWithFormat:@"This %@ %@", weekDay,[dateFormatter stringFromDate:date]];
		else if (daysDiff <= 14-[comps weekday])
			alarmStr = [NSString stringWithFormat:@"Next %@ %@", weekDay,[dateFormatter stringFromDate:date]];
		else {
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			alarmStr = [dateFormatter stringFromDate:date];
		}
		
		dateLabel.text = alarmStr;
	} else
		dateLabel.text = @"";
}

-(void)scheduleLocalNotificationForDate:(NSDate*)date{
	UILocalNotification* localNotification = [[UILocalNotification alloc]init];
	localNotification.fireDate = [date dateByAddingTimeInterval:10];
	localNotification.timeZone = [NSTimeZone defaultTimeZone];
	localNotification.alertBody =[NSString stringWithFormat:@"Todolist %@",todoList.title];
	localNotification.alertAction = @"Show";
	localNotification.soundName = @"alarm.aif";
	NSString *origin = @"todoListDetailController";
	NSDictionary* userDic = [[NSDictionary alloc]initWithObjectsAndKeys:origin,@"origin", nil];
	localNotification.userInfo = userDic;
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)cancelLocalNotificationOfTodoList:(Todolist*)aList{
	for (UILocalNotification* localNotification in [[UIApplication sharedApplication]scheduledLocalNotifications])
		if ([[localNotification.userInfo objectForKey:@"todolistalarm"]isEqual:aList.alarm]){
			[[UIApplication sharedApplication]cancelLocalNotification:localNotification];
			[self debug:nil orFunctionOrNil:@"cancelLocalNotificationOfTodoList" withItsStringOrNil:@"local notification is cancelled."];
		}
}

-(void)UpdateClockFromAppDelegate:(AppDelegate *)AppDelegate{
	todoList.alarm = nil;
	[self deleteOldAlarm];
}

#pragma Image Support
/*-(IBAction)addImageButtonTapped:(id)sender{
 // If in editing state, then display an image picker; if not, create and push a photo view controller.
 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
 imagePicker.delegate = self;
 [self presentViewController:imagePicker animated:YES completion:NULL];
 }
 
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
 
 // Delete any existing image.
 NSManagedObject *oldImage = recipe.image;
 if (oldImage != nil) {
 [recipe.managedObjectContext deleteObject:oldImage];
 }
 
 // Create an image object for the new image.
 NSManagedObject *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:recipe.managedObjectContext];
 recipe.image = image;
 
 // Set the image for the image managed object.
 [image setValue:selectedImage forKey:@"image"];
 
 // Create a thumbnail version of the image for the recipe object.
 CGSize size = selectedImage.size;
 CGFloat ratio = 0;
 if (size.width > size.height) {
 ratio = 44.0 / size.width;
 } else {
 ratio = 44.0 / size.height;
 }
 CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
 
 UIGraphicsBeginImageContext(rect.size);
 [selectedImage drawInRect:rect];
 recipe.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 [self dismissModalViewControllerAnimated:YES];
 }
 
 
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
 [self dismissModalViewControllerAnimated:YES];
 }
 */

@end