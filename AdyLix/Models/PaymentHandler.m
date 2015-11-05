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

+(void) registerSender:(NSString*) token item:(NSString*) itemId bankId:(NSString*) bankId amount:(NSString*) price completion:
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
             [connector submitPay:bankId customerId: custData[@"tokenId"] amount: price completion:
              ^(NSDictionary *payData,
                NSError *error) {
                  if (error) {
                      completion(PKPaymentAuthorizationStatusFailure);
                  } else {
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
}@catch(NSException* exp)
    {
         completion(PKPaymentAuthorizationStatusFailure);
    }
}
@end