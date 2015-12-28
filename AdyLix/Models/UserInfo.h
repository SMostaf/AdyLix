//
//  UserInfo.h
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface UserInfo : NSObject
@property PFFile *profileImage;
@property unsigned int likes;
@property NSString* name;

@end

//NS_ASSUME_NONNULL_END
//
//#import "UserInfo+CoreDataProperties.h"
