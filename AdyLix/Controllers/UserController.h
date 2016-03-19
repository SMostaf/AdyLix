//
//  UserController.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef UserController_h
#define UserController_h

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Parse/Parse.h>

@interface UserController : BaseViewController

@property PFUser* user;

@end


#endif /* UserController_h */
