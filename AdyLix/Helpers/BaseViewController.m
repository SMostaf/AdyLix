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
#import "Utility.h"

@implementation BaseViewController


#pragma mark -
#pragma mark UIViewController


- (void) viewWillDisappear:(BOOL)animated
{
//   self.navigationController.navigationBar.hidden = true;
    // [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}


-(void) showLocater:(id)sender {
 //   LocateController *locateController = [self.storyboard instantiateViewControllerWithIdentifier:@"discoverController"];
   // [self presentViewController:locateController animated:NO completion:nil];
   // [self.navigationController pushViewController:locateController animated:NO];
}


-(void) showWardrobe:(id)sender {
   WardrobeController *wardrobeController = [self.storyboard instantiateViewControllerWithIdentifier:@"wardrobeController"];
     [self.navigationController pushViewController:wardrobeController animated:NO];
}

-(void) showNotify:(id)sender {
    NotificationController *notifyController = [self.storyboard instantiateViewControllerWithIdentifier:@"notifyController"];
    [self.navigationController pushViewController:notifyController animated:NO];
}
                                              
-(void) showProfile:(id)sender {
    
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    //[self presentViewController:userController animated:NO completion:nil];
    [self.navigationController pushViewController:userController animated:NO];
}

-(void) showSelfie:(id)sender{
    
    RegisterController* snapController = [self.storyboard instantiateViewControllerWithIdentifier:@"registerController"];
    [self presentViewController:snapController animated:NO completion:NULL];
}

@end