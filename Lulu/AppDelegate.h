

#import <UIKit/UIKit.h>
#import "FirstLevelViewController.h"
@protocol AppDelegateDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly,strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly,strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly,strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,strong) id <AppDelegateDelegate> appDel;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@protocol AppDelegateDelegate <NSObject>
//to delete the clock and update alarm
-(void)UpdateClockFromAppDelegate:(AppDelegate*)AppDelegate;
@end