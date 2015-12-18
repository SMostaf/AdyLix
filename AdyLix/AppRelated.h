//
//  AppRelated.h
//  AdyLix
//
//  Created by Sahar Mostafa on 12/17/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef AppRelated_h
#define AppRelated_h


NSString *const AppDelegateApplicationDidReceiveRemoteNotification  = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";

NSString * const StripePublishableKey = @"pk_test_qEGQmR4XAdo9rIQDsU30dKBZ";//sk_test_0hmo7YaWTsDPo1KouO8hRrEN";
NSString* kPushPayloadFromUserObjectIdKey = @"itm";
typedef enum {
    UAPHomeTabBarItemIndex = 0,
    UAPEmptyTabBarItemIndex = 1,
    UAPActivityTabBarItemIndex = 2
} APTabBarControllerViewControllerIndex;



#endif /* AppRelated_h */
