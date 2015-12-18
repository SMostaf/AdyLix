//
//  Item.h
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef Style_h
#define Style_h

#import "Parse/Parse.h"
#import "itemInfo.h"

@interface StyleItems : NSObject

-(unsigned long) getLikesForSytle:(NSString*) styleId;
+(NSArray*) getItemsForStyle:(NSString*) styleId;
-(void) like:(NSString*) styleId ownerId:(NSString*) ownerId;
-(void) purchase:(NSString*) styleId;
+(NSArray*) getStylesNearby:(CLLocation*) location;

-(void) saveStyle:(ItemInfo*) info;

@end

#endif /* Style_h */
