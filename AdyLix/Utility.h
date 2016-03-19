//
//  Utility.h
//  AdyLix
//
//  Created by Sahar Mostafa on 12/24/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef Utility_h
#define Utility_h
#import <UIKit/UIKit.h>

@interface Utility : NSObject
+(NSArray<UIBarButtonItem*> *) getNavOtherMenu:(id) obj;
+(UINavigationItem*) getNavMainMenu:(id) obj;
+(UIBarButtonItem*) getNavForProfile:(id) obj;
+(UIAlertController*) getAlertViewForMessage:(NSString*) title msg:(NSString*) message action:(void (^ __nullable)(UIAlertAction *action))action;
@end

#endif /* Utility_h */
