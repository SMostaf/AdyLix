//
//  FBLogin.h
//  AdyLix
//
//  Created by Sahar Mostafa on 12/17/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef FBLogin_h
#define FBLogin_h


@protocol FBLoginDelegate <NSObject>
@optional
- (void) didLogin:(BOOL)loggedIn;
@end

@interface FBLogin : NSObject
+ (void) login:(id<FBLoginDelegate>)delegate;
@end

#endif /* FBLogin_h */
