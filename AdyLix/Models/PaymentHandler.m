//
//  PaymentHandler.m
//  AdyLix
//
//  Created by Sahar Mostafa on 11/1/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaymentHandler.h"
#import "Stripe.h"
#import "Parse/Parse.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "PaymentController.h"

#define MERCHANTID @"merchant.com.adylix"

@implementation PaymentHandler

// connection on receiving status of payment
-(void) receiveData:(bool) status {
    
}

-(void) pay: (NSDecimalNumber*) amount completion:(void (^)(bool))completion {
    
    if (![PFUser currentUser])
        return;
    
    // show payment Dialogue
    PKPaymentRequest *request = [Stripe
                             paymentRequestWithMerchantIdentifier:MERCHANTID];
    // Configure your request here.
    NSString *label = @"Purchase Request";
    request.paymentSummaryItems = @[
                                    [PKPaymentSummaryItem summaryItemWithLabel:label
                                                                        amount:amount]
                                    ];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
        PaymentController *paymentController;
        NSString* bankId = [[PFUser currentUser] valueForKey:@"bankId"];
        NSDictionary *dictData = [NSDictionary dictionaryWithObjects:
                                  [NSArray arrayWithObjects:bankId, amount, nil]
                                                             forKeys:[NSArray arrayWithObjects:@"bankId", @"value",nil]];
        
        [paymentController initWithData: dictData];
        
//#ifdef DEBUG
//        paymentController = [[STPTestPaymentAuthorizationViewController alloc]
//                             initWithPaymentRequest:request];
//        ((STPTestPaymentAuthorizationViewController*)paymentController).delegate = self;
//#else
//        paymentController = [[PKPaymentAuthorizationViewController alloc]
//                             initWithPaymentRequest:request];
//        paymentController.delegate = self;
//#endif
//        [self presentViewController:paymentController animated:YES completion:^{
//            // if success
//            completion(true);
//            return true;
//
//        }];
    
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }

}

@end