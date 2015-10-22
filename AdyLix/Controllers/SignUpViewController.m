//
//  SignUpViewController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUpViewController.h"


@implementation SignUpViewController


-(void) viewDidLoad {
    
    self.signUpView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-mod.png"]];
    self.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    //
    //        [self presentViewController:signUpViewController animated:YES completion:^{
    //
    //            //signUpViewController.signUpView.frame = CGRectMake(0,0,120, 120);
    //
    //
    //            // [logInViewController.logInView.signUpButton setBackgroundImage:[UIImage //imageNamed:@"restBtn@2x"] forState:UIControlStateHighlighted];
    //        }];
    
    // adjust color of user text field
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    
    // adjust sign up button
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    
    [self.signUpView.signUpButton setBackgroundColor:[UIColor colorWithRed:239.0f/255.0f green:222.0f/255.0f blue:204.0f/255.0f alpha:1.0]];
    
    
    [self.signUpView.signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];

    
}

-(void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self.signUpView.usernameField setFrame:CGRectMake(self.signUpView.frame.origin.x + 90, self.signUpView.frame.origin.y + 195, 200, 200)];
   // [self.signUpView.usernameField setFrame:CGRectMake(self.signUpView.frame.origin.x + 90, self.signUpView.frame.origin.y + 180, 200, 200)];
    //    [signUpViewController.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
}


@end