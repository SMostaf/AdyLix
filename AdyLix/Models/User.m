//
//  User.m
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "User.h"

@interface User()
@property NSString* parseClassName;
@end

@implementation User : NSObject

-(id) init {
    self = [super init];
    if(self)
        self.parseClassName = @"User";
    return self;
}

+(void) updateCurrentLocation {
    // save current user location on login
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error && [PFUser currentUser] != nil) {
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] save];
        }
    }];
}

+(void) saveLocation:(CLLocation *)location {
    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation: location];
    [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
    [[PFUser currentUser] save];
}

+(PFObject*) getUserForId:(NSString*) userId {
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userId];
    return(PFUser *)[query getFirstObject];
}

+(NSString*) getFBAccessToken:(PFUser*) user {
    NSDictionary *accessDict = [user valueForKey:@"authData"];
    if(!accessDict)
        return nil;
    return accessDict[@"facebook"][@"access_token"];
}

// #TODO move to asynch code
// fetch profile pic using access token
+(void) getFBProfilePic:(PFUser *)user handler:(profileHandler) handler {
    
    NSString* accessToken = [User getFBAccessToken: user];
    if([accessToken length] == 0)
        handler(nil);
    else {
        // PFSession *fbSession = [PFFacebookUtils session];
        // NSString *accessToken = [fbSession accessToken];
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", accessToken]];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *data = [NSData dataWithContentsOfURL:pictureURL];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(image);
            });
        });
    }
}

+(NSString*) getFBUserName:(PFUser*) user
{
    NSString* accessToken = [User getFBAccessToken: user];
    NSString* userFullName = nil;
    if([accessToken length] > 0) {

    NSURL *infoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me?return_ssl_resources=1&access_token=%@", accessToken]];
                      
    NSData* infoData = [NSData dataWithContentsOfURL:infoURL];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:infoData
                                                             options:kNilOptions
                                                               error:&error];
    if(!error)
      userFullName = json[@"name"];
    }
    
    return userFullName;
    
}
// get user info owning the passed style
+(UserInfo*) getInfoForUser:(PFUser*) user {
    UserInfo* userInfo = [[UserInfo alloc]init];
    // show profile image
    PFQuery * query = [PFUser query];
    [query whereKey:@"objectId" equalTo:user.objectId];
    PFObject* userObj = [query getFirstObject];
    if(userObj) {
        PFFile *profileImage = [userObj valueForKey:@"profileImage"];
        userInfo.profileImage = profileImage;
        userInfo.name = [userObj valueForKey:@"username"];
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