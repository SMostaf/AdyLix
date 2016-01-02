//
//  Style.m
//  Ady
//
//  Model wrapper for Parse Style table
//  Style may or may not contain items
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Style.h"
#import "User.h"
#import "Parse/Parse.h"

@interface StyleItems()
@property NSString* parseClassName;
@end

@implementation StyleDetail
@end

@implementation StyleItems : NSObject

-(id) init {
    self = [super init];
    if(self)
        self.parseClassName = @"StyleMaster";
    return self;
}

+(void) getStylesNearby:(CLLocation*) location handler:(completion) handler {
    // get users nearby
    PFQuery *usersQuery = [PFUser query];
    // Interested in locations near user
    double miles = [[NSUserDefaults standardUserDefaults] doubleForKey:@"range"];
    if (miles == 0) //preference not set
        miles = 10.0;
    
    usersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    NSLog(@"Location query current location: %@", location);
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] withinMiles:(double)miles];
    
    [usersQuery whereKey:@"discoverable" equalTo:[NSNumber numberWithBool:YES]];
    // exclude the current user from list of users
    [usersQuery whereKey: @"objectId" notEqualTo: [[PFUser currentUser] valueForKey:@"objectId"]];
    
    // #TODO: for DEBUG purpose
    // [usersQuery whereKey:@"currentLocation" nearGeoPoint:userGeoPoint];
    // #TODO: figure out sorting?
    // [usersQuery orderByAscending:@"orderByAscending"];
    
    // Limit what could be a lot of points.
    usersQuery.limit = 50;
    
   // NSArray* arrUsers = [usersQuery findObjects];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // no users nearby
            if(objects.count == 0) {
                handler(NO, nil);
                return;
            }
            // query nearby users and find their items
            // NSMutableArray *arrStylesFound = [[NSMutableArray alloc]init];
            PFQuery *stylesQuery = [PFQuery queryWithClassName:@"StyleMaster"];
            stylesQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
            [stylesQuery whereKey:@"userId" containedIn:objects];
            [stylesQuery whereKey:@"isDiscoverable" equalTo:[NSNumber numberWithBool:YES]];
 
            [stylesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    handler(YES, objects);
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    if ([error code] != 120) // cache miss in that case the callback will be called a second time after fetching from the network
                    handler(NO, nil);
                }
            }];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if ([error code] != 120) // cache miss in that case the callback will be called a second time after fetching from the network
            handler(NO, nil);
        }
    }];
  
}

+(NSString*) getStyleForObj:(PFObject*) style {
    NSString* styleName = nil;
    if (style != nil) {
        PFQuery* query = [PFQuery queryWithClassName:@"StyleMaster"];
        [query whereKey:@"objectId" equalTo:style.objectId];
        PFObject* styleObj = [query getFirstObject];
        styleName = [styleObj valueForKey:@"name"];
    }
    return styleName;
}

+(PFObject*) getStyleForId:(NSString*) styleId {
    PFQuery* query = [PFQuery queryWithClassName:@"StyleMaster"];
    [query whereKey:@"objectId" equalTo: styleId];
    PFObject* styleObj = [query getFirstObject];
    return styleObj;
}


+(NSArray*) getItemsForStyle:(NSString*) styleId {
    if(!styleId)
        return 0;
    NSArray* arrItemsFound;
    PFQuery* query = [PFQuery queryWithClassName:@"ItemDetail"];
    [query whereKey:@"styleId" equalTo:[StyleItems getStyleForId:styleId]];
    
    arrItemsFound = [query findObjects];
    
    return arrItemsFound;
    
}

+(BOOL) isCurrentStyle:(PFObject*) style {
    
    if([[PFUser currentUser] valueForKey:@"currentStyleId"] == style)
        return YES;
    return NO;
}

+(NSArray*) getStylesForUser:(PFUser*) user {
    PFQuery* query = [PFQuery queryWithClassName:@"StyleMaster"];
    [query whereKey:@"userId" equalTo:user];
    return [query findObjects];
}

+(void) like:(NSString*) styleId itemId:(NSString*) itemId owner:(PFUser*) owner {
    // get item object
    PFObject* itemObj = nil;
    PFObject* styleObj = nil;
    
    if(itemId)
         itemObj = [Item getItemForId:itemId];
    if(styleId)
        styleObj = [StyleItems getStyleForId:styleId];

    // like item ntifcation will be sent after save
    PFObject *like = [PFObject objectWithClassName:@"ItemLike"];
    if(styleObj)
        [like setObject:styleObj forKey:@"styleId"];
    if(itemObj)
        [like setObject:itemObj forKey:@"itemId"];
    
    [like setObject:[PFUser currentUser] forKey:@"userFrom"];
    [like setObject:owner forKey:@"userTo"];
        
    [like saveInBackground];

}

+(unsigned long) getLikesForStyle:(NSString*) styleId {
    if(!styleId)
        return 0;
    PFQuery* query = [PFQuery queryWithClassName:@"ItemLike"];
    [query whereKey:@"styleId" equalTo:[StyleItems getStyleForId: styleId]];
    //[query whereKey:@"userTo" equalTo:[PFUser currentUser]];
    
    return [[query findObjects] count];
}

// fetch info for style the user is currently wearing
+(DataInfo*) getCurrentStyleInfo {
    DataInfo* info = [[DataInfo alloc]init];
    PFObject* currStyle = [[PFUser currentUser] valueForKey:@"currentStyleId"];
    if(currStyle) {
        PFQuery * query = [PFQuery queryWithClassName:@"StyleMaster"];
        [query whereKey:@"objectId" equalTo:currStyle.objectId];
        PFObject* styleObj = [query getFirstObject];
        if(styleObj)
            info.name = [styleObj valueForKey:@"name"];
    }
    return info;
}

// saving
-(void) saveStyle:(DataInfo*) info {
  
    PFObject *item = [PFObject objectWithClassName:@"StyleMaster"];
    [item setObject:[PFUser currentUser] forKey:@"userId"];
    [item setObject:info.desc forKey:@"description"];
    [item setObject:info.name forKey:@"name"];
    [item setObject:info.imageData forKey:@"imageFile"];
    
    [item saveInBackground];
}


// ---------------------------------------- disabled -------------------------------------------- //
-(void) purchase:(NSString*) itemId {
    // mark item as purchased
    NSString* itemClassName = @"itemDetail";
    PFQuery* query = [PFQuery queryWithClassName:itemClassName];
    [query whereKey:@"objectId" equalTo:itemId];
    PFObject* item = [query getFirstObject];
 //   [item setValue: [NSNumber numberWithInt:ITMPurchased] forKey:@"status"];
    [item save];
}
@end