//
//  ViewController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/13/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import "MainController.h"
#import "connector.h"
#import "Parse/Parse.h"
#import "LocateController.h"
#import "SignUpViewController.h"
#import "TabBarController.h"
#import "ItemsController.h"
#include "ParseUI/PFLogInViewController.h"


#ifndef ADY_ENABLE_LOGGING
#   ifdef DEBUG
#       define ADY_ENABLE_LOGGING 1
#   else
#       define ADY_ENABLE_LOGGING 0
#   endif /* DEBUG */
#endif /* ADY_ENABLE_LOGGING */


@interface MainController ()
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPass;
//@property FBSDKLoginButton *loginButton;
//@property FBSDKLoginManager *loginMgr;
//@property (weak, nonatomic) IBOutlet FBLoginView *loginButton;
@end

@implementation MainController


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if ([PFUser currentUser]) {
        // save current user location
        // keep updating current user location for others to discover my items
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                
                [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
                [[PFUser currentUser] saveInBackground];
                //[self.tabBarController setSelectedIndex:2];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:@"user"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];

    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[PFUser logOut];
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self];
        
        logInViewController.logInView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-mod.png"]];
        
        // adjust sign up button
        [logInViewController.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [logInViewController.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
        [logInViewController.logInView.signUpButton setBackgroundColor:[UIColor colorWithRed:239.0f/255.0f green:222.0f/255.0f blue:204.0f/255.0f alpha:1.0]];
        
        
        [logInViewController.logInView.signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
         [logInViewController.logInView.signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        //
        
        // adjust forecolor of text on fields
//        [logInViewController.logInView.usernameField setTextColor:[UIColor darkGrayColor]];
//        [logInViewController.logInView.passwordField setTextColor:[UIColor darkGrayColor]];
//        //
        
        logInViewController.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate

        
         // Assign our sign up controller to be displayed from the login controller
         [logInViewController setSignUpController:signUpViewController];
         // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}


#pragma mark - PFLogInViewControllerDelegate
         
         // Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
                 return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // register logged user for puh notification
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    // Dismiss the controller
    if(self.presentingViewController)
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate
         
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
             BOOL informationComplete = YES;
             
             // loop through all of the submitted data
             for (id key in info) {
                 NSString *field = [info objectForKey:key];
                 if (!field || !field.length) { // check completion
                     informationComplete = NO;
                     break;
                 }
             }
             
             // Display an alert if a field wasn't completed
             if (!informationComplete) {
                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
             }
             
             return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        //code to be executed with the dismissal is completed
        // for example, presenting a vc or performing a segue
    }];
    //[self.navigationController popToRootViewControllerAnimated:true];
}
// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
             NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
             NSLog(@"User dismissed the signUpViewController");
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    //NSUInteger index=[[tabBarController viewControllers] indexOfObject:viewController];
    
    return YES;
}
@end
