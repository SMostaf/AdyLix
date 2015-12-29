//
//  FBLoginViewController.m
//  FBParse
//

#import "FBLoginViewController.h"
#import "FBLogin.h"
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import "LocateController.h"

@interface FBLoginViewController ()<FBLoginDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation FBLoginViewController


-(void) viewDidAppear:(BOOL)animated {
    // #TODO should navigate directly from app delegate
    if ([FBSDKAccessToken currentAccessToken]) {
        [self goToMainView];
    }
}
- (void) viewDidLoad
{
	[super viewDidLoad];
   
}

-(void) goToMainView {
    LocateController *discoveryView = [self.storyboard instantiateViewControllerWithIdentifier:@"discoverController"];
    //[tabView setSelectedIndex:1];
    [self presentViewController:discoveryView animated:NO completion:nil];
}

- (IBAction)FBLogin:(id)sender {
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
        [self goToMainView];
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
