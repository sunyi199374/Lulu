//
//  todoListController.m
//  Lulu
//
//  Created by Dingzhong Weng on 6/10/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//

#import "TodoListController.h"
#import "Todolist.h"
#import "Todo.h"

@interface TodoListController ()
@end

@implementation TodoListController
@synthesize contentView;
@synthesize tableView;
@synthesize settings;
@synthesize cover;
@synthesize originalFrame,centerDifference,originalCenter,frameDifference,parentFrame,parentCenter;
@synthesize filteredLists,searchBar,searching;
@synthesize childAddController,childDetailController,popOver;
@synthesize managedObjectContext= _managedObjectContext;
@synthesize soundFileURLRef,addFileObject,detailFileObject,closeFileObject;
@synthesize lists,totalRows;
@synthesize guideView,arrowBottom,arrowTop,prompt,tapBottom,tapTop;
@synthesize debugMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.35];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    cover.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y+self.contentView.frame.size.height, self.contentView.frame.size.width, 0);
    [UIView commitAnimations];
    self.view.alpha =1;
    [self newLists];
    //calculate total count of all lists, update the badge
    [self updateBadgeNumber];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    if (_managedObjectContext == nil){
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
        [self debug:_managedObjectContext orFunctionOrNil:nil withItsStringOrNil:nil];
    }
    
    /*if (debugMode){
        Todolist * todoL2 = [NSEntityDescription insertNewObjectForEntityForName:@"Todolist" inManagedObjectContext:self.managedObjectContext];
        todoL2.title = @"Toy Story 2:Madacasca";
        todoL2.timeCreated = [NSDate date];
        todoL2.timeFinished = nil;
        Todo *todo1 = (Todo*)[NSEntityDescription insertNewObjectForEntityForName:@"Todo" inManagedObjectContext:todoL2.managedObjectContext];
        todo1.event = @"Hello Here";
        todo1.displayOrder = [NSNumber numberWithInt:0];
        todo1.isDone = [NSNumber numberWithBool:NO];
        [todoL2 addTodosObject:todo1];
        todoL2.onGoing = [NSNumber numberWithInt:1];
        todoL2.allDone = [NSNumber numberWithBool:NO];
        todoL2.alarm = [NSDate date];
        [self save:todo1];
        [self save:todoL2];
    }*/

    //set table view properties
    self.tableView.scrollsToTop = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.layer.cornerRadius = 4.0f;
    self.tableView.layer.backgroundColor = [[UIColor clearColor]CGColor];
    
    //set view background
    self.contentView.layer.cornerRadius = 22.0f;
    //self.contentView.layer.backgroundColor = [kContentViewBackground CGColor];
    
    //add search bar on top of tableview
    searching = NO;
    searchBar.delegate = self;
    for (UIView *subview in self.searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) 
            [subview removeFromSuperview];
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")])
            [(UITextField *)subview setBackground:[UIImage imageNamed:@"TLSearchBoxUN.png"]];
        NSLog(@"search bar subview class: %@",[subview class]);
    }

    //sound
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"TapButton"
                                                 withExtension: @"aif"];
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (__bridge CFURLRef) tapSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (soundFileURLRef, &addFileObject);
    
    NSURL *whipSound   = [[NSBundle mainBundle] URLForResource: @"ViewOpen"
                                                withExtension: @"wav"];
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (__bridge CFURLRef) whipSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID(soundFileURLRef, &detailFileObject);
    
    NSURL *closeSound   = [[NSBundle mainBundle] URLForResource: @"ViewClose"
                                                  withExtension: @"aif"];
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (__bridge CFURLRef) closeSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (soundFileURLRef, &closeFileObject);
    
    //set cover view
    cover = [[UIView alloc]initWithFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y+self.contentView.frame.size.height, self.contentView.frame.size.width, 0)];
    [self.view addSubview:cover];
    [self.view bringSubviewToFront:cover];
    cover.backgroundColor = contentView.backgroundColor;
    cover.layer.cornerRadius = 22.0f;
    
    //set pinch gesturenizer
    UIPinchGestureRecognizer* pinchReg = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchReg];
    
    //reset original datas
    originalFrame = contentView.frame;
    originalCenter = contentView.center;
    centerDifference.x = parentCenter.x-self.contentView.center.x;
    centerDifference.y = parentCenter.y-self.contentView.center.y;
    frameDifference.size.width = parentFrame.size.width - self.contentView.frame.size.width;
    frameDifference.size.height = parentFrame.size.height - self.contentView.frame.size.height;
    NSLog(@"center x %f, y %f, width %f,height %f",contentView.center.x,contentView.center.y,contentView.frame.size.width,contentView.frame.size.height);
    
    //first time show, show guide
    if (settings.firstTimeShowInListsView.boolValue){
        guideView.hidden = NO;
        arrowBottom.transform = CGAffineTransformMakeRotation(3.142);
        CGRect topFrame = arrowTop.frame;
        CGRect bottomFrame = arrowBottom.frame;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationRepeatCount:2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:.6];
        CGRect newTopFrame = topFrame;
        newTopFrame.size.height = 0;
        arrowTop.frame = newTopFrame;
        CGRect newBottomFrame = bottomFrame;
        newBottomFrame.origin.y += newBottomFrame.size.height;
        newBottomFrame.size.height = 0;
        arrowBottom.frame = newBottomFrame;
        arrowTop.frame = topFrame;
        arrowBottom.frame = bottomFrame;
        [UIView commitAnimations];
        
        UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(notFirstTime)];
        recog.numberOfTapsRequired = 1;
        [guideView addGestureRecognizer:recog];
    }else{
        guideView.hidden =YES;
    }
}

-(void)notFirstTime{
    settings.firstTimeShowInListsView = [NSNumber numberWithBool:NO];
    guideView.hidden = YES;
    [self save:settings];
    
    [guideView removeGestureRecognizer:[[guideView gestureRecognizers]objectAtIndex:0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    cover = nil;
    popOver = nil;
    tableView = nil;
    contentView = nil;
    lists = nil;
    childAddController= nil;
    childDetailController = nil;
    _managedObjectContext = nil;
    filteredLists = nil;
    searchBar = nil;
    guideView = nil;
    arrowTop = nil;
    tapTop = nil;
    prompt = nil;
    arrowBottom = nil;
    tapBottom = nil;
    settings = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table Data Source Methods 
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    if (!searching)
        numberOfRows = totalRows;
    else
        numberOfRows = [filteredLists count];
    
    [self debug:nil orFunctionOrNil:@"numberOfRowsInSection" withItsStringOrNil:[NSString stringWithFormat:@"%i",numberOfRows]];
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"plainCell";
    Todolist *aList = nil;
    if (!searching){
        aList = (Todolist*)[lists objectAtIndex:[indexPath row]];
    }else
        aList = (Todolist*)[filteredLists objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    //configure the cell
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:1000];
    cellLabel.text = aList.title;
    if (aList.onGoing.intValue == 0)
        cellLabel.textColor = [UIColor lightGrayColor];
    else
        cellLabel.textColor = [UIColor whiteColor];
    cellLabel.font = [UIFont fontWithName:@"Courier-Bold" size:14.0f];
    
    //configure its accessory view with info indicator, if it has alarm, set the alarm as well, if the alarm is ringed but did not eliminated, change it to golden color
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIButton *info = [[UIButton alloc]initWithFrame:CGRectMake(0, 11, 24, 24)];
    [info setImage:[UIImage imageNamed:@"TLInfoButtonUN.png"] forState:UIControlStateNormal];
    info.adjustsImageWhenHighlighted = NO;
    [info addTarget:self action:@selector(accessoryButtonTappedForRowWithIndexPath:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = info;
    
    if (aList.alarm)
        cell.imageView.image = [UIImage imageNamed:@"TLAlarmIconUN.png"];
    else 
        cell.imageView.image = nil;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
} 

#pragma mark Table Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CGRect newFrame = self.contentView.frame;
    cover.alpha = 0.9;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.35];
    cover.frame = newFrame;
    [UIView commitAnimations];
    [self performSegueWithIdentifier:@"secondLevelSegue_1" sender:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		//delete the managed object for the given index path
		Todolist *aList = nil;
		if (self.searching){
			aList = [filteredLists objectAtIndex:[indexPath row]];
		} else {
			aList = [lists objectAtIndex:[indexPath row]];
		}
		NSManagedObjectContext *context = aList.managedObjectContext;
		[context deleteObject:aList];
		[self save:nil];
		
		[self newLists];
		if (self.searching){
			[self newFilteredLists];
			[self updateFilteredLists:self.searchBar.text];
		}
		
		//stop displaying it
		//[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
		//update badge number
		[self updateBadgeNumber];
	}
}

#pragma mark Todo List support

-(void)addTodoListController:(AddTodoListController *)addTodoListController didAddTodoList:(Todolist *)todoList{
    if (todoList) {
        [self save:todoList];
        [self newLists];
        //update badge number
        [self updateBadgeNumber];
        [self.tableView reloadData];
        NSLog(@"add a new todo list");
    }
    
}

-(void)todoListDetailController:(TodoListDetailController *)todoListDetailController updateParentCellAtIndexPath:(NSIndexPath *)indexPath isDeleted:(BOOL)deleted{
    if (deleted){
		 [self newLists];
		 if (self.searching){
			 [self newFilteredLists];
			 [self updateFilteredLists:self.searchBar.text];
		 }
		 [self.tableView reloadData];
		return;
    }
   
    Todolist *aList = nil;
    if (!self.searching)
        aList = (Todolist *)[lists objectAtIndex:[indexPath row]];
    else
        aList = (Todolist *)[filteredLists objectAtIndex:[indexPath row]];
    
    if (aList.onGoing.intValue == 0) 
        aList.timeFinished = [NSDate date];
    else
        aList.timeFinished = nil;
    
    //update badge number
    [self updateBadgeNumber];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //childController = segue.destinationViewController;
    if ([segue.identifier isEqual:@"secondLevelSegue_1"]){
        //[self debug:segue.identifier];
        childDetailController = (TodoListDetailController*) segue.destinationViewController;
        Todolist * todoList;
        if (self.searching)
            todoList = (Todolist*)[filteredLists objectAtIndex:[(NSIndexPath*)sender row]];
        else
            todoList = (Todolist*)[lists objectAtIndex:[(NSIndexPath*)sender row]];
        childDetailController.todoList = todoList;
        childDetailController.parentCellIndexPath = (NSIndexPath*)sender;
        childDetailController.debugMode = self.debugMode;
        childDetailController.settings = self.settings;
        childDetailController.delegate = self;
        
        AudioServicesPlaySystemSound(detailFileObject);
    } if ([segue.identifier isEqual:@"secondLevelSegue_2"]){
        childAddController = (AddTodoListController*) segue.destinationViewController;
        childAddController.context = self.managedObjectContext;
        childAddController.delegate = self;
        
        AudioServicesPlaySystemSound(addFileObject);
    }
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:{
			break;
		}
            
		case NSFetchedResultsChangeDelete:{
			break;
        }
            
		case NSFetchedResultsChangeUpdate:{
			break;
        }
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}*/

#pragma mark search Data Source

-(void)newFilteredLists {
    filteredLists = [lists mutableCopy];
}
-(void)updateFilteredLists:(NSString *)searchTerm{
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    for (Todolist* list in filteredLists)
        if ([list.title rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound)
            [toRemove addObject:list];
    [filteredLists removeObjectsInArray:toRemove];
    
    //if count is 0, assume that user want to add 
    //if ([filteredLists count]==0
    [self.tableView reloadData];
}

#pragma mark Search Delegate Methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    for (UIView *subview in self.searchBar.subviews) 
        if ([subview isKindOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)subview;
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            [button setBackgroundImage:nil forState:UIControlStateHighlighted];
            NSString *imageName;
            imageName = NSLocalizedString(@"cancelButtonImage",@"lists view cancel button tag");
            [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            //NSLog(@"the image name was %@",imageName);
            imageName = NSLocalizedString(@"cancelButtonPressedImage",@"lists view cancel button pressed tag");
            [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
            //NSLog(@"the image name is %@",imageName);
        }
            
    [self debug:nil orFunctionOrNil:@"searchBarTextDidBeginEditing" withItsStringOrNil:[NSString stringWithFormat:@"searching is %@",searching?@"YES":@"NO"]];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self debug:nil orFunctionOrNil:@"searchBarTextDidEndEditing" withItsStringOrNil:[NSString stringWithFormat:@"searching is %@",searching?@"YES":@"NO"]];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]){
        searching = NO;
        [self.tableView reloadData];
    } else {
        searching = YES;
        [self newFilteredLists];
        [self updateFilteredLists:searchText];
        [self debug:nil orFunctionOrNil:@"searchBar textDidChange" withItsStringOrNil:[NSString stringWithFormat:@"Text is %@",searchText]];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [self.searchBar text];
    [self newFilteredLists];
    [self updateFilteredLists:searchTerm];
    [self.searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searching = NO;
    self.searchBar.text = @"";
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma Gesture Recognizer Delegate Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)handlePinch:(UIPinchGestureRecognizer*) pinchRecognizer {
    [self debug:pinchRecognizer orFunctionOrNil:nil withItsStringOrNil:nil];
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint pinchPoint = [pinchRecognizer locationInView:self.view];
        [self debug:nil orFunctionOrNil:@"handlePinch" withItsStringOrNil:[NSString stringWithFormat:@"the pinch scale is %f, pinch point x is %f, y is %f",pinchRecognizer.scale,pinchPoint.x,pinchPoint.y]];
    } else if (pinchRecognizer.state == UIGestureRecognizerStateEnded || pinchRecognizer.state == UIGestureRecognizerStateCancelled){
        CGFloat scale = pinchRecognizer.scale;
        if (centerDifference.y*scale<150){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationDuration:0.15];
            self.view.alpha = 0.2;
            [UIView commitAnimations];
            [NSTimer scheduledTimerWithTimeInterval:.15 target:self selector:@selector(dismissView) userInfo:nil repeats:NO];
        } else{
        contentView.frame = originalFrame;
        contentView.center = originalCenter;
        }
        NSLog(@"centerDiff y is %f",centerDifference.y*scale);
        [self debug:nil orFunctionOrNil:@"handlePinch" withItsStringOrNil:@"ends"];
    } else if (pinchRecognizer.state == UIGestureRecognizerStateChanged){//if state is changing, minimize the content view by scale
        CGFloat scale = pinchRecognizer.scale;
        CGRect newFrame = originalFrame;
        newFrame.size.width = parentFrame.size.width - frameDifference.size.width*scale;
        newFrame.size.height = parentFrame.size.height - frameDifference.size.height*scale;
        contentView.frame = newFrame;
        CGPoint newCenter;
        newCenter.x = parentCenter.x - centerDifference.x*scale;
        newCenter.y = parentCenter.y - centerDifference.y*scale;
        contentView.center = newCenter;
        [self debug:nil orFunctionOrNil:@"handlePinch" withItsStringOrNil:[NSString stringWithFormat:@"the pinch scale is %f,newframe width %f, newFrame height %f,new center x is %f, y is %f",pinchRecognizer.scale,newFrame.size.width,newFrame.size.height,newCenter.x,newCenter.y]];
    }
    //minimize to its original place. hide the cover.
}
 
#pragma Miscs
-(void)debug:(id)object orFunctionOrNil:(NSString *)function withItsStringOrNil:(NSString *)itsString{
    if (debugMode){
        if (object)
            NSLog(@"Class %@,\nObject %@",[object class],object);
        else if (function) {
            if (itsString)
                NSLog(@"%@:%@",function,itsString);
            else
                NSLog(@"Calling %@",function);
        }
    }
}

-(void)save:(NSManagedObject*)objectOrNil{
    NSError *error = nil;
    NSManagedObjectContext* context =nil;
    if (objectOrNil){
        context = objectOrNil.managedObjectContext;
    }else{
        context =_managedObjectContext;
    }

	if (![context save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	} else{
        NSLog(@"save succeeded!");
    }
}

-(void)updateBadgeNumber {
    NSInteger count = totalRows;
    for (int i =0;i<totalRows;i++){
        Todolist *aList = (Todolist *)[lists objectAtIndex:i];
        if (aList.onGoing.intValue == 0)
            count --;
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
}

-(void)popOver:(id)sender WithCreationDate:(NSDate *)dateCreated andFinishDate:(NSDate *)dateFinished andAlarm:(NSDate *)alarm {
    
    ListDatesViewController * viewControl = [[ListDatesViewController alloc]initWithCreationDateOfList:dateCreated andFinishDate:dateFinished andAlarm:alarm];
    popOver = [[FPPopoverController alloc]initWithViewController:viewControl];
    popOver.tint = FPPopoverLightGrayTint;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popOver.contentSize = CGSizeMake(300, 500);
    }
    else {
        CGSize textSize = viewControl.viewSize;
        
        popOver.contentSize = CGSizeMake(textSize.width + 20, textSize.height);
    }
    
    popOver.arrowDirection = FPPopoverArrowDirectionVertical;
    
    //sender is the UIButton view
    [popOver presentPopoverFromView:sender]; 
    
}

-(void)dismissView{
    AudioServicesPlaySystemSound(closeFileObject);
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:NULL];
    _managedObjectContext = nil;
    NSLog(@"todolist view dismissed");
}

-(void)newLists{
    NSError *error = nil;
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Todolist" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptorCreated = [[NSSortDescriptor alloc] initWithKey:@"timeCreated" ascending:NO];
    NSSortDescriptor *sortDescriptorFinished = [[NSSortDescriptor alloc] initWithKey:@"timeFinished" ascending:YES];
    NSSortDescriptor *sortDescriptorAlarm = [[NSSortDescriptor alloc] initWithKey:@"alarm" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorFinished,sortDescriptorAlarm,sortDescriptorCreated,nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    lists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    totalRows = [lists count];
    //NSLog(@"todolist %@",lists);
    //NSLog(@"totalRow is %i",totalRows);
}
#pragma IBActions
//add new todo list
- (IBAction)add:(id)sender {
    [self performSegueWithIdentifier:@"secondLevelSegue_2" sender:self];
}

-(IBAction)accessoryButtonTappedForRowWithIndexPath:(id)sender{
    UIButton *button = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDate * dateCreated = [(Todolist*)[lists objectAtIndex:[indexPath row]] timeCreated];
    NSDate * dateFinished = [(Todolist*)[lists objectAtIndex:[indexPath row]] timeFinished];
    NSDate * alarm = [(Todolist*)[lists objectAtIndex:[indexPath row]] alarm];
    
    //set up pop over view to show details
    [self popOver:sender WithCreationDate:dateCreated andFinishDate:dateFinished andAlarm:alarm];
}


@end
