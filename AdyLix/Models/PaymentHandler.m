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
#import "Item.h"
#import "User.h"

#define MERCHANTID @"merchant.com.adylix"

@implementation PaymentHandler

+(void) registerSenderAndTransfer:(NSString*) token item:(NSString*) itemId recepientId:(NSString*) recepientId amount:(NSString*) price completion:
(void (^)(PKPaymentAuthorizationStatus))completion {
@try
{
    Connector* connector = [[Connector alloc] init];
    [connector registerSender:token name:[[PFUser currentUser] valueForKey:@"username"]  email:[[PFUser currentUser] valueForKey:@"email"] completion:
     ^(NSDictionary *custData,
       NSError *error) {
         if (error || custData[@"tokenId"] == nil) {
             completion(PKPaymentAuthorizationStatusFailure);
         } else {
             // update user customerId
             PFUser* user = [PFUser currentUser];
             [user setValue: custData[@"tokenId"] forKey:@"tokenId"];
             [user save];
             
             // success transmit payment
             [connector submitPay:recepientId customerId: custData[@"tokenId"] amount: price completion:
              ^(NSDictionary *payData,
                NSError *error) {
                  if (error) {
                      completion(PKPaymentAuthorizationStatusFailure);
                  } else {
                      Item* item = [[Item alloc]init];
                      [item purchase: itemId];
                      completion(PKPaymentAuthorizationStatusSuccess);
                  }
              }];
         }
     }];
}@catch(NSException* exp)
    {
         completion(PKPaymentAuthorizationStatusFailure);
    }
}


+(void) registerRecepient:(NSString*) recepientId name:(NSString*) name completion:
(void (^)(PKPaymentAuthorizationStatus))completion {
    @try
    {
        
        Connector* connector = [[Connector alloc] init];
        [connector registerRecepient:recepientId name:name email:[[PFUser currentUser] valueForKey:@"email"] completion:
         ^(NSDictionary *custData,
           NSError *error) {
             if (error || custData[@"tokenId"] == nil) {
                 completion(PKPaymentAuthorizationStatusFailure);
             } else {
                 // update user customerId
                 PFUser* user = [PFUser currentUser];
                 [user setValue: custData[@"tokenId"] forKey:@"bankId"];
                 [user save];
                 
                 completion(PKPaymentAuthorizationStatusSuccess);
            }
         }];
    }@catch(NSException* exp)
    {
        completion(PKPaymentAuthorizationStatusFailure);
    }
}
@end