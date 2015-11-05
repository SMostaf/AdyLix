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


#import "User.h"

#define MERCHANTID @"merchant.com.adylix"


@implementation PaymentHandler

// contact our backend
+(void) submitPayment: (NSString*) amount tokenId:(NSString*) tokenId
               bankId:(NSString*) bankId completion:(void (^)(bool))completion {
    Connector* connector = [[Connector alloc]init];
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

+(void) registerSender:(NSString*) token item:(NSString*) itemId bankId:(NSString*) bankId amount:(NSString*) price completion:
(void (^)(PKPaymentAuthorizationStatus))completion {
    
    Connector* connector = [[Connector alloc] init];
    [connector registerSender:token name:[[PFUser currentUser] valueForKey:@"username"]  email:[[PFUser currentUser] valueForKey:@"email"] completion:
     ^(NSData *data,
       NSError *error) {
         if (error) {
             completion(PKPaymentAuthorizationStatusFailure);
         } else {
             // success transmit payment
             [connector submitPay:bankId token: token amount: price completion:
              ^(NSData *data,
                NSError *error) {
                  if (error) {
                      completion(PKPaymentAuthorizationStatusFailure);
                  } else {
                      // update user token
                      PFUser* user = [PFUser currentUser];
                      [user setValue: token forKey:@"tokenId"];
                      [user save];
                      
                      // delete item
                      NSString* itemClassName = @"itemDetail";
                      PFQuery* query = [PFQuery queryWithClassName:itemClassName];
                      [query whereKey:@"objectId" equalTo:itemId];
                      PFObject* item = [query getFirstObject];
                      [item deleteInBackground];
                      
                      completion(PKPaymentAuthorizationStatusSuccess);
                  }
              }];
         }
     }];
}
@end