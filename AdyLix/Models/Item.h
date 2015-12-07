//
//  Item.h
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef Item_h
#define Item_h

#import "Parse/Parse.h"

@interface Item:NSObject

typedef NS_ENUM(NSInteger, ITMStatus) {
    ITMRegistered, // Item registered, default state
    ITMPending,   // Pending state
    ITMRefunded,  // Refunded
    ITMPurchased  // Item purchased after a successfull transaction
};

-(unsigned long) getLikesForItem:(NSString*) itemId;
-(void) like:(NSString*) itemId ownerId:(NSString*) ownerId;
-(void) purchase:(NSString*) itemId;
+(NSArray*) getItemsNearby:(CLLocation*) location;
@end

#endif /* Item_h */
