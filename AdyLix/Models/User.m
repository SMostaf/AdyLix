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

-(PFUser*) getUserForItem:(NSString*) itemId {
    
    PFQuery* query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"objectId" equalTo:itemId];
    
    PFUser* user = [query getFirstObject];

    return user;
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