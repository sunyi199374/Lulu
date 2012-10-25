//
//  FirstLevelViewController.h
//  Lulu
//
//  Created by Dingzhong Weng on 6/10/12.
//  Copyright (c) 2012 Oasislulu. All rights reserved.
//

//tap nav to scroll to the top
#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#include "Settings.h"
#include "AppDelegate.h"
#define kLeft 0
#define kRight 1
#define kTop 2
#define kDissolve 3
#define kCoverFrame CGRectMake(20, 61, 280, 480)
#define kCoverCenter CGPointMake(160,294)
@interface FirstLevelViewController : UIViewController
//apps and signin and title
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIButton *firstApp;
@property (strong, nonatomic) IBOutlet UIButton *secondApp;
@property (strong, nonatomic) IBOutlet UIButton *thirdApp;
@property (strong, nonatomic) IBOutlet UIButton *fourthApp;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIImageView *luluTitle;
@property (strong, nonatomic) IBOutlet UIView *reference;
@property (strong, nonatomic) UIView *chosenApp;
@property (strong, nonatomic) Settings *settings;
@property BOOL justStart;
@property BOOL debugMode;

//account service
@property (strong, nonatomic) IBOutlet UIImageView *banner;
@property (strong, nonatomic) IBOutlet UITextField *password;
//sound
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

//debug
@property (strong, nonatomic) IBOutlet UISwitch* aSwitch;
//IBAction
-(IBAction)resignKeyboard:(id)sender;
-(IBAction)invokeKeyboard:(id)sender;
-(IBAction)appButtonTapped:(id)sender;
-(IBAction)signInButtonTapped:(id)sender;
-(IBAction)chooseApp:(id)sender;
-(IBAction)debugModeSwitch:(id)sender;
//animation
-(void)presentAppView:(UIView*)view withDuration:(NSTimeInterval)duration andDirection:(NSInteger)direction;
-(void)showApp:(UIView*)appView;
-(void)hideReference:(UIView *)appView;
-(void)hideReference;
//basics
-(void)signIn;
-(void)initSettings;
-(void)initStarterView;
-(void)initView;
-(void)debug:(id)object orFunctionOrNil:(NSString*)function withItsStringOrNil: (NSString*)itsString;

@end
