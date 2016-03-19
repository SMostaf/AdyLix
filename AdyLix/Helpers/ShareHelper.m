//
//  FBLogin.m
//  AdyLix
//
//  Created by Sahar Mostafa on 12/17/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//  based on: http://www.raywenderlich.com/44640/integrating-facebook-and-parse-tutorial-part-1

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "FBLogin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@implementation FBLogin

+(void)login:(id<FBLoginDelegate>)delegate
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_friends", @"user_location"];
    
     //Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        bool status = NO;
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            status = YES;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
             // #TODO: ask to share with friends here
             // gift card
             status = YES;
        } else {
            NSLog(@"User logged in through Facebook!");
             status = YES;
        }
        
        if ([delegate respondsToSelector:@selector(didLogin:)]) {
            [delegate didLogin:status];
        }
    }];
}
@end