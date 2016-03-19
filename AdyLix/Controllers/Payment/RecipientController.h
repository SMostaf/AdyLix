//
//  RecipientController.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef RecipientController_h
#define RecipientController_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TTTAttributedLabel/TTTAttributedLabel.h"
#import "STPTestPaymentAuthorizationViewController.h"

@interface RecipientController : UIViewController<PKPaymentAuthorizationViewControllerDelegate, TTTAttributedLabelDelegate>

@end


#endif /* RecipientController_h */
