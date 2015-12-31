//
//  User.h
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef User_h
#define User_h

#import "Parse/Parse.h"
#import "UserInfo.h"

#define USER_IMAGE @"profileImage"


@interface User:NSObject

-(void) saveTokenId:(NSString*) tokenId;
-(void) saveBankId:(NSString*) bankId;

-(NSString*) getTokenId;
-(NSString*) getBankId;


+(void) updateCurrentLocation;
+(void) saveLocation:(CLLocation*) location;
+(PFObject*) getUserForId:(NSString*) userId;
+(UserInfo*) getInfoForUser:(PFUser*) user;
+(NSData*) getFBProfilePic:(PFUser*) user;
+(NSString*) getFBUserName:(PFUser*) user;
@end

#endif /* User_h */
