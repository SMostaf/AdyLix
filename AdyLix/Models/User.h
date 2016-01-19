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

typedef void(^profileHandler)(UIImage* image);

@interface User:NSObject

-(void) saveTokenId:(NSString*) tokenId;
-(void) saveBankId:(NSString*) bankId;

-(NSString*) getTokenId;
-(NSString*) getBankId;


+(void) updateCurrentLocation;
+(void) saveLocation:(CLLocation*) location;
+(PFUser*) getUserForId:(NSString*) userId;
+(UserInfo*) getInfoForUser:(PFUser*) user;
+(void) getFBProfilePic:(PFUser*) user handler:(profileHandler) handler;
+(NSString*) getFBUserName:(PFUser*) user;
@end

#endif /* User_h */
