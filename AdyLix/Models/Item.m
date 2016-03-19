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