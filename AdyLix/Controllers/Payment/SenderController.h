//
//  PaymentController.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef SenderController_h
#define SenderController_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TTTAttributedLabel/TTTAttributedLabel.h"
#import "STPTestPaymentAuthorizationViewController.h"

@interface SenderController : UIViewController<PKPaymentAuthorizationViewControllerDelegate, TTTAttributedLabelDelegate>
@property (nonatomic, retain) NSString* price;
@property (retain, nonatomic) NSString* recepientId;
@property (retain, nonatomic) NSString* itemId;

@end


#endif /* SenderController_h */
