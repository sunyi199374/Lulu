//
//  addTodoListController.m
//  Lulu
//
//  Created by Dingzhong Weng on 6/17/12.
//  Copyright (c) 2012 Worcester Polytechnique Institute. All rights reserved.
//

#import "AddTodoListController.h"


@interface AddTodoListController ()

@end

@implementation AddTodoListController
@synthesize addButton;
@synthesize cancelButton;
@synthesize context,gestureRecognizer,delegate,inputAccessoryView;
@synthesize titleField,content,isTextViewEditing,btnNext,btnPrev,todoList;
@synthesize soundFileURLRef,closeFileObject;
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
    titleField.placeholder = @"Title";
    titleField.delegate = self;
    [titleField addTarget:self 
                   action:@selector(textFieldOnReturn) 
         forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.content addGestureRecognizer:gestureRecognizer];
    isTextViewEditing = NO;
    
    
    //set the background color for the view
    self.content.backgroundColor = [UIColor colorWithRed:255.0f/255.0f
                                                   green:243.0f/255.0f
                                                    blue:243.0f/255.0f
                                                   alpha:1];
    self.titleField.backgroundColor = [UIColor colorWithRed:237.0f/255.0f
                                                      green:224.0f/255.0f
                                                       blue:224.0f/255.0f
                                                      alpha:1];
    
    //set content autocapitalization and autocorrection
    content.autocorrectionType = UITextAutocorrectionTypeNo;
    content.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    //disable to add button
    addButton.enabled = NO;
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //sound
    NSURL *closeSound   = [[NSBundle mainBundle] URLForResource: @"ViewClose" withExtension: @"aif"];
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (__bridge CFURLRef) closeSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (soundFileURLRef, &closeFileObject);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    context = nil;
    titleField = nil;
    content = nil;
    [self setAddButton:nil];
    [self setCancelButton:nil];
    inputAccessoryView = nil;
    gestureRecognizer = nil;
    btnNext = nil;
    btnPrev = nil;
    todoList = nil;
    delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 
#pragma mark Text Field Methods
-(void)textFieldOnReturn {
    [titleField resignFirstResponder];
    isTextViewEditing = YES;
    content.editable = YES;
    [content becomeFirstResponder];

}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"InputAccessoryView" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textField.inputAccessoryView = inputAccessoryView;    
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.inputAccessoryView = nil;
    }
    
    isTextViewEditing = NO;
    [content resignFirstResponder];
    [textField becomeFirstResponder];
}

#pragma mark - 
#pragma mark Text View Methods
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"InputAccessoryView" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = inputAccessoryView;    
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.inputAccessoryView = nil;
    }
    
    NSRange nextLine= [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:YES];
    NSRange prevLine = [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:NO];
    
    if ([self hasNext:nextLine])
        btnNext.enabled = YES;
    else 
        btnNext.enabled = NO;

    if ([self hasPrev:prevLine])
        btnPrev.enabled = YES;
    else
        btnPrev.enabled = NO;
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]>0)
        addButton.enabled = YES;
    else 
        addButton.enabled = NO;
    
    NSRange nextLine= [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:YES];
    NSRange prevLine = [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:NO];
    [self enableButton:btnNext enabled:[self hasNext:nextLine]];
    [self enableButton:btnPrev enabled:[self hasPrev:prevLine]];
}
-(void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"textViewDidChangeSelection: selectedRange location %i, length %i", [content selectedRange].location,[content selectedRange].length);
    NSRange nextLine= [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:YES];
    NSRange prevLine = [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:NO];
    [self enableButton:btnNext enabled:[self hasNext:nextLine]];
    [self enableButton:btnPrev enabled:[self hasPrev:prevLine]];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (isTextViewEditing) {
        [content resignFirstResponder];
        isTextViewEditing = NO;
        content.editable = NO;
        NSLog(@"1.Text View ends its editing session.");
    } else {
        content.editable = YES;
        isTextViewEditing = YES;
        [content becomeFirstResponder];
        NSLog(@"2.Text View is under editing");
    } 
    return YES;
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = [self.view convertRect:self.content.bounds toView:nil];
    newTextViewFrame.origin.y = 32; // in retina 4.0, the value is 31
    newTextViewFrame.size.height = keyboardTop -33; // in retina 4.0, the value is keyboardTop -33
    //NSLog(@"keyboardWillShow:keyboard height is %f ",keyboardRect.size.height);
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    content.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    // recovery
    NSDictionary* userInfo = [notification userInfo];

    CGRect newTextViewFrame = self.content.frame;
    newTextViewFrame.size.height = self.view.frame.size.height - newTextViewFrame.origin.y;
    
    //NSLog(@"keyboardWillHide: text view bounds' y is %f, titleField y is %f",newTextViewFrame.origin.y, titleField.frame.origin.y);
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    content.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

#pragma mark Button Support (ActionSheetDelegate)
- (IBAction)buttonTapped:(id)sender{
    //save button string
    NSString *save = [NSString stringWithFormat:NSLocalizedString(@"saveFormat", @"save button text")];
    
    //discard button string
    NSString *discard = [NSString stringWithFormat:NSLocalizedString(@"discardFormat", @"discard button text")];
    
    //cancel button string
    NSString *cancel = [NSString stringWithFormat:NSLocalizedString(@"cancelFormat", @"cancel button text")];
    
    UIActionSheet *actionSheet = nil;
    
    if ([content.text isEqualToString:@""] && [titleField.text isEqualToString:@""])
        actionSheet= [[UIActionSheet alloc]initWithTitle:titleField.text
                                                delegate:self
                                       cancelButtonTitle:cancel
                                  destructiveButtonTitle:discard
                                       otherButtonTitles:nil];
    else 
        actionSheet= [[UIActionSheet alloc]initWithTitle:titleField.text
                                                           delegate:self
                                                  cancelButtonTitle:cancel
                                             destructiveButtonTitle:discard
                                                  otherButtonTitles:save,nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [actionSheet firstOtherButtonIndex])
        [self save];
    else if (buttonIndex == [actionSheet destructiveButtonIndex]){
        [self cancel];
    }
}

-(IBAction)gotoPrevEntry:(id)sender{
    NSRange prevLine = [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:NO];
    if ([self hasPrev:prevLine])
        [content setSelectedRange:prevLine];
}

-(IBAction)gotoNextEntry:(id)sender{
    NSRange nextLine= [self findReturnInString:content.text withSelectedRange:[content selectedRange] toTheEnd:YES];
    if ([self hasNext:nextLine])
        [content setSelectedRange:nextLine];
}

-(IBAction)accept:(id)sender {
    [self save];
}
-(IBAction)decline:(id)sender{
    [self cancel];
}

#pragma mark - 
#pragma mark Miscs
-(BOOL)hasNext:(NSRange) nextLine{
    if (nextLine.location != NSNotFound)
        return YES;
    //NSLog(@"hasNext: not found!");
    return NO;
}

-(BOOL)hasPrev:(NSRange) prevLine{
    if (prevLine.location != NSNotFound)
        return YES;
    //NSLog(@"hasPrev: not found!");
    return NO;
}

-(void) save{
    //in further development, if text in titleField is nil, the first todo will be used for todoList's name. There will also be a convinient button to insert date at any time
    NSInteger count = 0;
    todoList = [NSEntityDescription insertNewObjectForEntityForName:@"Todolist" inManagedObjectContext:context];
    
    //give todolist time stamps and name
    todoList.timeCreated = [NSDate date];
    todoList.timeFinished = nil;
    todoList.title = titleField.text;
    
	NSMutableString * todos = [content.text mutableCopy];
    
    while ([todos length]>0) {
        //break up the text view into todos, marked by a return key
        NSRange range = [todos rangeOfString:@"\n"];
        NSUInteger returnIndex = range.location;
        
        if (returnIndex == NSNotFound)
            returnIndex = [todos length];
        NSString * aEvent = [todos substringToIndex:returnIndex];
        //if the event is null, do not add it
        if (![aEvent isEqual:@""]){
            [self addTodo:aEvent Order:count];
            count ++;
        }
        
        //remove the event from text view
        [todos deleteCharactersInRange:NSMakeRange(0, returnIndex<[todos length] ? returnIndex+1:[todos length])];
    }
    
    //if nothing is added to todo, it will use title as first todo
    if ([todoList.todos count]==0){
        [self addTodo:titleField.text Order:count];
        count ++;
    } 
    
    //count ongoings in todo list
    todoList.onGoing = [NSNumber numberWithInt:count];
    todoList.allDone = [NSNumber numberWithBool:NO];
    
    [self.delegate addTodoListController:self didAddTodoList:todoList];
    [self dismissView];
}

- (void)addTodo:(NSString*)aEvent Order:(NSInteger) displayOrder {
    //add a todo to the list
    Todo * aTodo = [NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:context];
    aTodo.event = aEvent;
    aTodo.isDone = [NSNumber numberWithBool:NO];
    aTodo.displayOrder = [NSNumber numberWithInt:displayOrder];
    [todoList addTodosObject:aTodo];
    
    //if todolist does not have a title, the first aTodoEvent will be it
    if ([todoList.title isEqual:@""]){
        todoList.title = aEvent;
    }
    NSLog(@"addTodo:the displayOrder for item %@ is %i",aTodo.event,aTodo.displayOrder.intValue);
    
}

-(void) cancel{    
    [self.delegate addTodoListController:self didAddTodoList:nil];
    [self dismissView];
}

-(void) dismissView{
    AudioServicesPlaySystemSound(closeFileObject);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(NSRange)findReturnInString:(NSString *)string withSelectedRange:(NSRange)selectedRange toTheEnd:(BOOL)to{
    if ([string isEqualToString:@""]||(selectedRange.location == [string length]&&to))
        return NSMakeRange(NSNotFound, 0);
    
    NSString *subStr;
    NSRange lineRange;
    if (to){
        subStr = [string substringFromIndex:selectedRange.location+selectedRange.length+1];
        lineRange = [subStr rangeOfString:@"\n"];
    } else {
        subStr = [string substringToIndex:selectedRange.location];
        lineRange = [subStr rangeOfString:@"\n" options:NSBackwardsSearch];
    }
    
    //NSLog(@"findReturnInString:lineRange location %i,length %i, toTheEnd %@",lineRange.location,lineRange.length, to? @"Yes" : @"No");
    
    if (lineRange.location == NSNotFound && to)
        lineRange = NSMakeRange([string length], 0);
    else 
        lineRange = to? NSMakeRange(selectedRange.location+lineRange.location+1, 0):NSMakeRange(lineRange.location, 0);
    return lineRange;
    
}

-(void)enableButton:(UIButton *)button enabled :(BOOL)enabled {
    button.enabled = enabled;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
