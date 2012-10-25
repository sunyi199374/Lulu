

#import "dissolve.h"

@implementation dissolve
-(void)perform{
    //The new dissolve effect is disabled but is going to use a cover-view effect. The transition duration is reduced from .75 to .5
    //UIViewController *src = (UIViewController *)self.sourceViewController;
    //UIViewController *dst = (UIViewController *)self.destinationViewController;
    //[src.view addSubview:dst.view];
    //dst.view.alpha = 0;
    
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:.35];
    //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //dst.view.alpha = 1;
    //src.view.alpha = 0.5;
    //[UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(showNextView) userInfo:nil repeats:NO];
}
-(void)showNextView{
    [((UIViewController*)self.sourceViewController).navigationController pushViewController:((UIViewController *)self.destinationViewController) animated:NO];
}
@end
