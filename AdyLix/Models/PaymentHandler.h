//
//  PaymentHandler.h
//  Ady
//
//  Created by Sahar Mostafa on 10/16/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef PaymentHandler_h
#define PaymentHandler_h

#import "connector.h"
#import "STPTestPaymentAuthorizationViewController.h"

@interface PaymentHandler:NSObject


+(void) submitPayment: (NSString*) amount tokenId:(NSString*) tokenId
                bankId:(NSString*) bankId completion:(void (^)(bool))completion;
+(void) registerSenderAndTransfer:(NSString*) token item:(NSString*) itemId  recepientId:(NSString*) recepientId amount:(NSString*) price completion:
(void (^)(PKPaymentAuthorizationStatus))completion;
+(void) registerRecepient:(NSString*) recepientId name:(NSString*) name completion:
(void (^)(PKPaymentAuthorizationStatus))completion;
@end

#endif /* PaymentHandler_h */
