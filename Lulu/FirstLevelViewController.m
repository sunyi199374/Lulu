//
//  FirstLevelViewController.m
//  Lulu
//
//  Created by Dingzhong Weng on 6/10/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//

#import "FirstLevelViewController.h"
#import "TodoListController.h"

@interface FirstLevelViewController ()

@end

@implementation FirstLevelViewController
@synthesize aSwitch;
@synthesize secondApp;
@synthesize thirdApp;
@synthesize fourthApp;
@synthesize signIn;
@synthesize lulutitle;
@synthesize reference;
@synthesize VIPBtn;
@synthesize banner;
@synthesize password;
@synthesize firstApp;
@synthesize chosenApp;
@synthesize firstTime;
@synthesize soundFileObject,soundFileURLRef;
@synthesize backgroundImage;
@synthesize settings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (firstTime)
        firstTime = NO;
    else
        [self hideAnimationAccordingToApp:chosenApp];
    
}

// slide to delete is not functioning.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //set settings
    [self getSettings];
    //starter view
    UIImageView* starterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLuluClassic.png"]];
    starterView.autoresizesSubviews = YES;
    starterView.frame = CGRectMake(0, 0, 320, 568);
    starterView.userInteractionEnabled = NO;
    [self.view addSubview:starterView];
    [self.view bringSubviewToFront:starterView];
    starterView.alpha =0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1];
    starterView.alpha = 1;
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelay:1];
    [UIView setAnimationDuration:1];
    starterView.alpha = 0;
    [UIView commitAnimations];

    
    //present instructions
    if (settings.firstTimeShowInFirstLevel.boolValue){
        settings.firstTimeShowInFirstLevel = [NSNumber numberWithBool:NO];
        NSError* error;
        if (![settings.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    //show animation on buttons
    reference.hidden =YES;
    [self showAnimationWithApp:firstApp withDuration:0.35 andDirection:kRight];
    [self showAnimationWithApp:secondApp withDuration:0.35 andDirection:kLeft];
    [self showAnimationWithApp:thirdApp withDuration:0.35 andDirection:kLeft];
    [self showAnimationWithApp:fourthApp withDuration:0.35 andDirection:kTop];
    [self showAnimationWithApp:signIn withDuration:0.35 andDirection:kRight];
    [self showAnimationWithApp:lulutitle withDuration:0.35 andDirection:kDissolve];
    
    //set apps
    [self setFirstApp];
    
    //set vip service sign in
    [self setVIPBanner];

    //set first time show at this time
    firstTime = YES;
    
    //debug switch
    aSwitch.hidden = YES;
    [aSwitch setOn:NO];
    password.text = @"";
    
    //set sound
    NSURL *whipSound   = [[NSBundle mainBundle] URLForResource: @"whip-click" withExtension: @"wav"];
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (__bridge CFURLRef) whipSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (soundFileURLRef,&soundFileObject);
    
    NSLog(@"FirstLevelViewController: the view frame is width %f, height %f",self.view.frame.size.width,self.view.frame.size.height);
}

-(void)viewDidUnload
{
    [self setSecondApp:nil];
    [self setThirdApp:nil];
    [self setFourthApp:nil];
    [self setSignIn:nil];
    [self setLulutitle:nil];
    [self setReference:nil];
    [super viewDidUnload];
    firstApp = nil;
    aSwitch = nil;
    VIPBtn = nil;
    banner = nil;
    password = nil;
    chosenApp = nil;
    backgroundImage = nil;
    settings = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma IBAction support
-(IBAction)appButtonTapped:(id)sender{
    UIButton * button = (UIButton *)sender;
    NSString *generalSegueName = @"firstLevelSegue_";
    NSString *identifier = [generalSegueName stringByAppendingFormat:@"%i",button.tag];
    [self performSegueWithIdentifier:identifier sender:self];
}

-(IBAction)signInButtonTapped:(id)sender{
    [self showOrHideBanner];
}

-(IBAction)resignKeyboard:(id)sender{
    [sender resignFirstResponder];
    [self confirmPassword];
    NSLog(@"resign");
}
-(IBAction)invokeKeyboard:(id)sender{
    [sender becomeFirstResponder];
    NSLog(@"invoke");
}

-(IBAction)chooseApp:(id)sender{
    chosenApp = (UIButton*)sender;
    [self showAnimationOfNewWindowAccordingToApp:chosenApp];
}

#pragma segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	TodoListController *childController = (TodoListController*) segue.destinationViewController;
	if (aSwitch.isOn){
		childController.debugMode = YES;
		settings.firstTimeShowInFirstLevel = [NSNumber numberWithBool:YES];
		settings.firstTimeShowInListsView = [NSNumber numberWithBool:YES];
		settings.firstTimeShowInDetailsView = [NSNumber numberWithBool:YES];
	}else
		childController.debugMode = NO;
	childController.parentCenter = fourthApp.center;
	childController.parentFrame = fourthApp.frame;
	childController.settings = settings;
	AudioServicesPlaySystemSound(soundFileObject);
	firstTime = NO;
	
}

#pragma miscs
-(void)setFirstApp{
    firstApp.tag = 0;
}

-(void)setVIPBanner{
    //hide banner and password field
    banner.alpha = 0;
    password.hidden = YES;
}

-(void)showOrHideBanner{
    if (banner.alpha == 0){
        [UIView animateWithDuration:.5 animations:^() {
            banner.alpha = 1.0f;
        }];
        password.hidden = NO;
    } else {
        [UIView animateWithDuration:.5 animations:^() {
            banner.alpha = 0.0f;
        }];
        password.hidden = YES;
    }
}

-(void)showAnimationWithApp:(UIView*)app withDuration:(NSTimeInterval)duration andDirection:(NSInteger)direction{
    app.alpha = 0.0f;
    CGRect frame = app.frame;
    CGRect newFrame = frame;
    if (direction == kLeft){
        newFrame.size.width = 0;
        newFrame.origin.x = frame.origin.x+frame.size.width;
    } else if (direction == kRight){
        newFrame.size.width = 0;
    } else if (direction == kTop) {
        newFrame.size.height = 0;
        newFrame.origin.y = frame.origin.y + frame.size.height;
    } else if (direction == kDissolve){
        app.alpha = 0;
    }
    app.frame = newFrame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelay:2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    app.frame = frame;
    app.alpha = 1;
    [UIView commitAnimations];
}

-(void)showAnimationOfNewWindowAccordingToApp:(UIView *)appView{
    reference.hidden = NO;
    CGRect frame = kCoverFrame;
    CGPoint center = kCoverCenter;
    reference.center = appView.center;
    reference.frame = appView.frame;
    reference.alpha = .9;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.35];
    reference.frame = frame;
    reference.center = center;
    reference.layer.cornerRadius = 22.0f;
    [UIView commitAnimations];
}

-(void)hideAnimationAccordingToApp:(UIView *)appView{
    reference.hidden = NO;
    reference.frame = kCoverFrame;
    reference.center = kCoverCenter;
    reference.alpha = 0.5;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:.25];
    reference.frame = appView.frame;
    reference.center = appView.center;
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(hideRef) userInfo:nil repeats:NO];
}

-(void)hideRef{
    reference.hidden =YES;
}

-(void)confirmPassword{
    NSString* pw = password.text;
    NSLog(@"the pw is %@, password is %@",pw,password);
    if ([pw isEqualToString:@"lulu0927"]){
        [aSwitch setHidden:NO];
        backgroundImage.alpha = 0.5;
        NSLog(@"Master Mode is On");
    }
    password.text = @"";
}

-(void)getSettings{
    NSError *error = nil;
    NSManagedObjectContext* context =[(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray* settingArray = [context executeFetchRequest:fetchRequest error:&error];
    //NSLog(@"%@",settingArray);
    if ([settingArray count]==0){
        settings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context];
        settings.firstTimeShowInFirstLevel = [NSNumber numberWithBool:YES];
        settings.firstTimeShowInListsView = [NSNumber numberWithBool:YES];
        settings.firstTimeShowInDetailsView = [NSNumber numberWithBool:YES];
        NSLog(@"getSettings: the settingsArray count is %i",[settingArray count]);
        if (![settings.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    } else 
        settings = (Settings*)[settingArray objectAtIndex:0];
}

#pragma Text Field Delegate Methods

@end 
