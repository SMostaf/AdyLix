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

+(NSArray*) getStylesNearby:(CLLocation*) location
{
    // get users nearby
    PFQuery *usersQuery = [PFUser query];
    // Interested in locations near user
    CGFloat km = 0.5f;
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] withinKilometers:(double)km];
    
    // #TODO: for DEBUG purpose
    // [usersQuery whereKey:@"currentLocation" nearGeoPoint:userGeoPoint];
    //[usersQuery whereKey: @"objectId" notEqualTo: [[PFUser currentUser] valueForKey:@"objectId"]];
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

+(NSString*) getStyleForObj:(PFObject*) style {
    
    PFQuery* query = [PFQuery queryWithClassName:@"StyleMaster"];
    [query whereKey:@"objectId" equalTo:style.objectId];
    PFObject* styleObj = [query getFirstObject];
    return [styleObj valueForKey:@"name"];
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
    [query whereKey:@"userTo" equalTo:[PFUser currentUser]];
    
    return [[query findObjects] count];
}

// fetch info for style the user is currently wearing
+(DataInfo*) getCurrentStyleInfo {
    // *******************************
    //#TODO remove
    //[StyleItems addObjForTest];
    // *******************************
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