//
//  DataInfo.h
//  AdyLix
//  Represents a record inside the style or items table
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef DataInfo_h
#define DataInfo_h

#include "Parse/Parse.h"

enum DataType {
    kStyleType = 0,
    kItemType = 1,
    kOther = 2    
};


@interface DataInfo : NSObject

@property enum DataType type;
@property NSString* objectId;
@property PFUser* userObjectId;
@property NSString* name;
@property NSString* desc;
@property PFFile* imageData;
@property bool isDiscoverable;
@property unsigned int likes;

-(void) like;
-(unsigned long) getLikes;
@end

#endif /* DataInfo_h */
