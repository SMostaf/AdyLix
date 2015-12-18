//
//  FBLoginViewController.m
//  FBParse
//

#import "FBLoginViewController.h"
#import "FBLogin.h"

@interface FBLoginViewController ()<FBLoginDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation FBLoginViewController



- (void) viewDidLoad
{
	[super viewDidLoad];
}

// Outlet for FBLogin button
- (IBAction)login:(id)sender {
    // Disable the Login button to prevent multiple touches
    [_btnLogin setEnabled:NO];
    
    // Show an activity indicator
   // [_activityLogin startAnimating];
    
    // Do the login
    [FBLogin login:self];
}

- (void) didLogin:(BOOL)loggedIn {
    // Re-enable the Login button
    [_btnLogin setEnabled:YES];
    
    // Stop the activity indicator
    // [_activityLogin stopAnimating];
    
    // Did we login successfully ?
    if (loggedIn) {
        // navigate to table view controller with the discovery view
        
    } else {
        // Show error alert
        [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Facebook Login failed. Please try again"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

@end
