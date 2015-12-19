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

+(NSArray*) getStylesNearby:(CLLocation*) location
{
    // get users nearby
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation: location];
    // Create a query for places
    //PFQuery *usersQuery = [PFQuery queryWithClassName:@"User"];
    PFQuery *usersQuery = [PFUser query];
    // Interested in locations near user
    CGFloat km = 0.5f;
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] withinKilometers:(double)km];
   
    // #TODO: for DEBUG purpose
    // [usersQuery whereKey:@"currentLocation" nearGeoPoint:userGeoPoint];
    [usersQuery whereKey: @"objectId" notEqualTo: [[PFUser currentUser] valueForKey:@"objectId"]];
    //[usersQuery orderByAscending:@"orderByAscending"];
    // Limit what could be a lot of points.
    usersQuery.limit = 100;
    
    NSArray* arrUsers = [usersQuery findObjects];
    // no users nearby
    if(arrUsers.count == 0)
        return nil;
    
   // query nearby users and find their items
   // NSMutableArray *arrStylesFound = [[NSMutableArray alloc]init];
    PFQuery *stylesQuery = [PFQuery queryWithClassName:@"StyleMaster"];
    // #TODO: remove DEBUG
   // [stylesQuery whereKey:@"userId" containedIn:arrUsers];
    [stylesQuery whereKey:@"isDiscoverable" equalTo:[NSNumber numberWithBool:YES]];

    
//    for (PFObject *object in arrUsers) {
//        [arrStylesFound addObject:[object objectId]];
//    }
//    [query whereKey:@"userObjectId" containedIn:arrStylesFound];
   
    //[query orderByDescending:@"objectId"];
    NSArray* arrStylesFound = [stylesQuery findObjects];

    return arrStylesFound;
}


+(NSArray*) getItemsForStyle:(NSString*) styleId {
    if(!styleId)
        return 0;
    NSArray* arrItemsFound;
    // [postQuery includeKey:@"user"];
    PFQuery* query = [PFQuery queryWithClassName:@"ItemDetail"];
    [query whereKey:@"styleId" equalTo:styleId];
    
    arrItemsFound = [query findObjects];
    
    return arrItemsFound;
    
}

-(void) like:(NSString*) styleId ownerId:(NSString*) ownerId {
    // get user id of owner
//    PFQuery* query = [PFQuery queryWithClassName:@"ItemDetail"];
//    [query whereKey:@"objectId" equalTo:itemId];
//    PFObject* item = [query getFirstObject];
//    if(item)
//    {
        //NSString* ownerId = [item valueForKey:@"userObjectId"];
        
        // like item ntifcation will be sent after save
        PFObject *item = [PFObject objectWithClassName:@"StyleLike"];
        [item setObject:styleId forKey:@"itemId"];
        [item setObject:[[PFUser currentUser] valueForKey:@"objectId"] forKey:@"userFrom"];
        [item setObject:ownerId forKey:@"userTo"];
        
        [item saveInBackground];
        
   // }

}


-(unsigned long) getLikesForStyle:(NSString*) styleId {
    if(!styleId)
        return 0;
    PFQuery* query = [PFQuery queryWithClassName:@"StyleLike"];
    [query whereKey:@"styleId" equalTo:styleId];
    [query whereKey:@"userTo" equalTo:[[PFUser currentUser] valueForKey:@"objectId"]];

    
    return [[query findObjects] count];
}


// fetch info for style the user is currently wearing
+(DataInfo*) getCurrentStyleInfo {
    DataInfo* info = [[DataInfo alloc]init];
    PFQuery *styleQuery = [PFQuery queryWithClassName:@"StyleMaster"];
    [styleQuery whereKey:@"objectId" equalTo:[[PFUser currentUser] valueForKey:@"currentStyleId"]];
    PFObject* currStyle = [styleQuery getFirstObject];
    if(currStyle)
        info.name = [currStyle valueForKey:@"name"];
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