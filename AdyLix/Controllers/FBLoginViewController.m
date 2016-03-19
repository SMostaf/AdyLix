//
//  FBLoginViewController.m
//  FBParse
//
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import "FBLoginViewController.h"
#import "FBLogin.h"
#import "LocateController.h"
#import "Utility.h"

@interface FBLoginViewController ()<FBLoginDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation FBLoginViewController

-(void) viewDidAppear:(BOOL)animated {
      self.navigationController.navigationBar.hidden = true;
}

- (void) viewDidLoad {
	[super viewDidLoad];
    self.navigationController.navigationBar.hidden = false;
    
}

-(void) goToMainView {
   
    LocateController *mainView = (LocateController*)[self.storyboard instantiateViewControllerWithIdentifier: @"discoverController"];
   [self.navigationController pushViewController:mainView animated:NO];
    
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
        UIAlertController* alertView = [Utility getAlertViewForMessage:@"Error" msg:@"Facebook Login failed. Please try again." action: nil];
        alertView.popoverPresentationController.sourceView = self.view;
        [self presentViewController:alertView animated:YES completion:nil];
        
    }
}

@end
