//
//  Item.m
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"
#import "Parse/Parse.h"

@interface Item()
@property NSString* parseClassName;
@end

@implementation Item : NSObject

-(id) init {
    self = [super init];
    if(self)
        self.parseClassName = @"ItemDetail";
    return self;
}

+(NSArray*) getItemsNearby:(CLLocation*) location
{
    // get users nearby
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation: location];
    // Create a query for places
    //PFQuery *usersQuery = [PFQuery queryWithClassName:@"User"];
    PFQuery *usersQuery = [PFUser query];
    // Interested in locations near user
    CGFloat km = 1.0f;
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] withinKilometers:(double)km];
   
    // #TODO: remove DEBUG
    // [usersQuery whereKey:@"currentLocation" nearGeoPoint:userGeoPoint];
    //[usersQuery whereKey:@"email" notEqualTo:[[PFUser currentUser] email]];
    [usersQuery whereKey: @"objectId" notEqualTo: [[PFUser currentUser] valueForKey:@"objectId"]];
    //[usersQuery orderByAscending:@"orderByAscending"];
    
    // Limit what could be a lot of points.
    usersQuery.limit = 100;
    
    NSArray* arrUsers = [usersQuery findObjects];
    // no users nearby
    if(arrUsers.count == 0)
        return nil;
    
    // query nearby users and find their items
    PFQuery *query = [PFQuery queryWithClassName:@"ItemDetail"];
    NSMutableArray *arrUsersItems = [[NSMutableArray alloc]init];
    for (PFObject *object in arrUsers) {
        [arrUsersItems addObject:[object objectId]];
    }
    [query whereKey:@"userObjectId" containedIn:arrUsersItems];
    [query whereKey:@"isDiscoverable" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"status" equalTo:[NSNumber numberWithInt:ITMRegistered]];
    
    //[query orderByDescending:@"objectId"];
    NSArray* arrItemsFound = [query findObjects];
    if(arrItemsFound.count == 0)
    {
        return nil;
    }
    return arrItemsFound;
}

-(void) like:(NSString*) itemId ownerId:(NSString*) ownerId {
    // get user id of owner
//    PFQuery* query = [PFQuery queryWithClassName:@"ItemDetail"];
//    [query whereKey:@"objectId" equalTo:itemId];
//    PFObject* item = [query getFirstObject];
//    if(item)
//    {
        //NSString* ownerId = [item valueForKey:@"userObjectId"];
        
        // like item ntifcation will be sent after save
        PFObject *item = [PFObject objectWithClassName:@"ItemLike"];
        [item setObject:itemId forKey:@"itemId"];
        [item setObject:[[PFUser currentUser] valueForKey:@"objectId"] forKey:@"userFrom"];
        [item setObject:ownerId forKey:@"userTo"];
        
        [item saveInBackground];
        
   // }

}

+(PFObject*) getItemForId:(NSString*) itemId {
    
    PFQuery* query = [PFQuery queryWithClassName:@"ItemDetail"];
    [query whereKey:@"objectId" equalTo:itemId];
    return [query getFirstObject];
}

+(unsigned long) getLikesForItem:(NSString*) itemId {
    if(!itemId)
        return 0;
    PFQuery* query = [PFQuery queryWithClassName:@"ItemLike"];
    [query whereKey:@"itemId" equalTo:itemId];
    [query whereKey:@"userTo" equalTo:[PFUser currentUser]];

    return [[query findObjects] count];
}

-(void) purchase:(NSString*) itemId {
    // mark item as purchased
    NSString* itemClassName = @"itemDetail";
    PFQuery* query = [PFQuery queryWithClassName:itemClassName];
    [query whereKey:@"objectId" equalTo:itemId];
    PFObject* item = [query getFirstObject];
    [item setValue: [NSNumber numberWithInt:ITMPurchased] forKey:@"status"];
    [item save];
}
@end