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
#import "DataInfo.h"
#import "Item.h"

@interface StyleDetail : NSObject
@property NSArray* items;
@property NSInteger currentItemIndex;
@property unsigned int currentItemsLimit;
@end


@interface StyleItems : NSObject

+(unsigned long) getLikesForStyle:(NSString*) styleId;
+(NSArray*) getItemsForStyle:(NSString*) styleId;
+(NSString*) getStyleForObj:(PFObject*) style;
+(BOOL) isCurrentStyle:(PFObject*) style;
+(NSArray*) getStylesForUser:(PFUser*) user;
+(void) like:(NSString*) styleId itemId:(NSString*)itemId owner:(PFUser*) owner;
-(void) purchase:(NSString*) styleId;
+(NSArray*) getStylesNearby:(CLLocation*) location;
+(DataInfo*) getCurrentStyleInfo;
-(void) saveStyle:(DataInfo*) info;
// for test cases
+(PFObject*) getStyleForId:(NSString*) styleId;
@end

#endif /* Style_h */
