//
//  ItemsLocated.h
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef ItemInfo_h
#define ItemInfo_h

#include "Parse/Parse.h"

@interface ItemInfo : NSObject

@property NSString* objectId;
@property NSString* userObjectId;
@property NSString* name;
@property NSString* desc;
@property NSString* price;
@property PFFile* imageData;
@property bool isDiscoverable;


-(void) like;
-(unsigned long) getLikesForItem;
@end

#endif /* ItemInfo_h */
