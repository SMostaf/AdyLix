//
//  NavigationBar.m
//  AdyLix
//
//  Created by Sahar Mostafa on 12/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

#import "UserController.h"
#import "RegisterController.h"
#import "WardrobeController.h"
#import "LocateController.h"
#import "NotificationController.h"

@implementation BaseViewController


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    UIImage* imageMain = [UIImage imageNamed:@"menu.png"];
    CGRect frameimg = CGRectMake(0, 0, imageMain.size.width, imageMain.size.height);
    UIButton *imgButton = [[UIButton alloc] initWithFrame:frameimg];
    [imgButton setBackgroundImage:imageMain forState:UIControlStateNormal];
    [imgButton addTarget:self action:@selector(showProfile:)
         forControlEvents:UIControlEventTouchUpInside];
    [imgButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithCustomView:imgButton];
    self.navigationItem.leftBarButtonItem = menuButton;
    
//
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Profile", @"")
//  style:UIBarButtonItemStylePlain target:self action:@selector(showProfile:)];
//    

  
    UIImage* imageSnap = [UIImage imageNamed:@"camera.png"];
    CGRect snapFrameimg = CGRectMake(0, 0, imageSnap.size.width, imageSnap.size.height);
    UIButton *imgSnapButton = [[UIButton alloc] initWithFrame:snapFrameimg];
    [imgSnapButton setBackgroundImage:imageSnap forState:UIControlStateNormal];
    [imgSnapButton addTarget:self action:@selector(showSelfie:)
        forControlEvents:UIControlEventTouchUpInside];
    [imgSnapButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *snapButton =[[UIBarButtonItem alloc] initWithCustomView:imgSnapButton];
    self.navigationItem.rightBarButtonItem = snapButton;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Snap", @"")
//                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(showSelfie:)];
//
    
}


-(void) showLocater:(id)sender {
    LocateController *locateController = [self.storyboard instantiateViewControllerWithIdentifier:@"discoverController"];
    [self presentViewController:locateController animated:NO completion:nil];
}


-(void) showWardrobe:(id)sender {
   WardrobeController *wardrobeController = [self.storyboard instantiateViewControllerWithIdentifier:@"wardrobeController"];
   [self presentViewController:wardrobeController animated:NO completion:nil];
}

-(void) showNotify:(id)sender {
    NotificationController *notifyController = [self.storyboard instantiateViewControllerWithIdentifier:@"notifyController"];
    [self presentViewController:notifyController animated:NO completion:nil];
}
                                              
-(void) showProfile:(id)sender {
    
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    
    //  [self.navigationController pushViewController:userController animated:NO];

    //[userController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:userController animated:NO completion:nil];
}

-(void) showSelfie:(id)sender{

    
    RegisterController* snapController = [self.storyboard instantiateViewControllerWithIdentifier:@"registerController"];
    [self presentViewController:snapController animated:NO completion:NULL];
}

@end