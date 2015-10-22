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
#import "UserInfo.h"

@interface User()
@property NSManagedObjectContext* managedObjectContext;
@end

@implementation User : NSObject 

-(void) saveUser:(NSString*) userId {
     NSManagedObjectContext *context;
    if ([self managedObjectContext] != nil)
         context = [self managedObjectContext];
    else
    {
        
       _managedObjectContext = context = [[NSManagedObjectContext alloc]init];
    }
    
    UserInfo *user = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"UserInfo"
                                      inManagedObjectContext:context];
    user.userID = userId;
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"couldn't save: %@", [error localizedDescription]);
    }
}

-(NSString*) getUserId {
    NSError *error;
    NSString* strId = [[NSString alloc] init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *info in fetchedObjects) {
        strId = [info valueForKey:@"userId"];
       // NSManagedObject *details = [info valueForKey:@"details"];
       // NSLog(@"Zip: %@", [details valueForKey:@"zip"]);
    }
    
    return strId;
}
@end