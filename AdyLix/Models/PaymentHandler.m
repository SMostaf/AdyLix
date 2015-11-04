//
//  PaymentHandler.m
//  AdyLix
//
//  Created by Sahar Mostafa on 11/1/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaymentHandler.h"
#import "Stripe/Stripe.h"
#import "Parse/Parse.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "PaymentController.h"
#import "User.h"

#define MERCHANTID @"merchant.com.adylix"


@implementation PaymentHandler

// connection on receiving status of payment
-(void) receiveData:(bool) status {
    
}

+(void) submitPayment: (NSString*) amount tokenId:(NSString*) tokenId
               bankId:(NSString*) bankId completion:(void (^)(bool))completion {
    Connector* connector = [Connector getConnector];
    [connector submitPay:bankId token: tokenId amount: amount completion:
     ^(NSData *data,
       NSError *error) {
         if (error) {
             completion(PKPaymentAuthorizationStatusFailure);
         } else {
             completion(PKPaymentAuthorizationStatusSuccess);
         }
         
     }];
}

-(void) pay: (NSString*) amount bankId:(NSString*) bankId completion:(void (^)(bool))completion {
    
    User* userInfo = [[User alloc] init];
    NSString* tokenId = [userInfo getTokenId];
    // does user have a token already
    // or first time registration
    if (tokenId != nil)
    {
        [PaymentHandler submitPayment:amount tokenId: tokenId bankId: bankId completion: completion];
    
    } else {
    
    // show payment Dialogue
    PKPaymentRequest *request = [Stripe
                             paymentRequestWithMerchantIdentifier:MERCHANTID];
    // Configure your request here.
    NSString *label = @"Purchase Request";
        
    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:amount];
        
    request.paymentSummaryItems = @[
                                    [PKPaymentSummaryItem summaryItemWithLabel:label
                                                                        amount:price]
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
        // delete item from Item Detail
//            completion(true);
//            return true;
//
//        }];
    
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }
    }

}

@end