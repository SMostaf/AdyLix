//
//  ShareAction.m
//  AdyLix
//  layer to share any information to social networks
//  Created by Sahar Mostafa on 12/18/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareHelper.h"

@implementation ShareHelper

// share action
+(void) shareInfo {
    // add default item to be added
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
    ItemInfo *item = [[ItemInfo alloc] init];
    item.name = @"unknown-default";
    
    [items addObject:item];
    
    self.stylesArr = items;
    

    [self.locationManager stopUpdatingLocation];
    
   
        
        NSString *textToShare;
        NSURL *website;
    
        switch (state) {
                
            case kShareItem: break;
            
            case kShareStyle: break;
                
            case kEmpty: {
                textToShare = @"AdyLix is a cool App helps you locate your interest in the street, check it out!";
                website = [NSURL URLWithString:@"http://www.adylix.com/"];

            }
                break;
        }
    
        NSArray *objectsToShare = @[textToShare, website];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                       UIActivityTypePrint,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo];
        
        activityController.excludedActivityTypes = excludeActivities;
        
        
        [self presentViewController:activityController animated:YES completion:nil];
}

@end
