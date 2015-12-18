//
//  ItemsLocated.h
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef StyleInfo_h
#define StyleInfo_h

#include "Parse/Parse.h"

@interface StyleInfo : NSObject

@property NSString* objectId;
@property NSString* userObjectId;
@property NSString* name;
@property NSString* desc;
@property PFFile* imageData;
@property bool isDiscoverable;
// items belonging to this style
// array of itemInfo
@property NSArray* itemsInfo;

@end

#endif /* StyleInfo_h */
