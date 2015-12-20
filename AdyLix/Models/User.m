//
//  User.m
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

@interface User()
@property NSString* parseClassName;
@end

@implementation User : NSObject

-(id) init {
    self = [super init];
    if(self)
        self.parseClassName = @"ItemDetail";
    return self;
}

+(PFUser*) getUserForId:(NSString*) userId {
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userId];
    PFUser *user = (PFUser *)[query getFirstObject];
    return user;
}

// get user info owning the passed style
+(UserInfo*) getInfoForStyle:(PFUser*) user {
    UserInfo* userInfo = [[UserInfo alloc]init];
    // show profile image
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:user.objectId];
    PFObject* userObj = [query getFirstObject];
    if(userObj) {
        PFFile *profileImage = [userObj valueForKey:@"profileImage"];
        userInfo.profileImage = profileImage;
    }
    return userInfo;
}


-(NSString*) getTokenId {
    return [[PFUser currentUser] valueForKey:@"tokenId"];
}

-(NSString*) getBankId {
    return [[PFUser currentUser] valueForKey:@"bankId"];
}

-(void) saveTokenId:(NSString*) tokenId {
    [[PFUser currentUser] setObject:tokenId forKey:@"tokenId"];
    [[PFUser currentUser] saveInBackground];

}

-(void) saveBankId:(NSString*) bankId {
    [[PFUser currentUser] setObject:bankId forKey:@"bankId"];
    [[PFUser currentUser] saveInBackground];
   
}

@end