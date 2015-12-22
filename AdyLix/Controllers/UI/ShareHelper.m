//
//  ShareAction.m
//  AdyLix
//  layer to share any information to social networks
//  Created by Sahar Mostafa on 12/18/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareHelper.h"
#import "datainfo.h"

@implementation ShareHelper

// share action pops up share view
// restricts to email and social networks
// #TODO: share image of style or item
+(UIActivityViewController*) shareInfo:(enum ShareType) type info:(DataInfo*) info {

    NSString *textToShare;
    NSArray *objectsToShare;

    switch (type) {
            
        case kShareItem: {
            
            textToShare = @"Sharing this item discovered by AdyLix";
            NSData* styleImage = [info.imageData getData];
            objectsToShare = @[textToShare, styleImage];

        }
            break;
        
        case kShareStyle: {
            
            textToShare = @"Sharing this style discovered by AdyLix";
            NSData* itemImage = [info.imageData getData];
            objectsToShare = @[textToShare, itemImage];
        }
            break;
            
        case kEmpty: {
            textToShare = @"AdyLix is a cool App helps you locate your interest in the street, check it out!";
            NSURL* data = [NSURL URLWithString:@"http://www.adylix.com/"];
            objectsToShare = @[textToShare, data];

        }
            break;
    }
    
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityController.excludedActivityTypes = excludeActivities;
    
    return activityController;

}

@end
