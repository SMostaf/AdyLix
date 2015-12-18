//
//  connector.h
//  BCASampleApp
//
//  Created by Sahar Mostafa on 11/20/14.
//  Copyright (c) 2014 Intel. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void(^RespHandler)(NSDictionary* __nullable, NSError* __nullable);



@interface Connector : NSObject<NSURLConnectionDelegate>

-(void) pushLikecompletion:(NSString*) userId completion:(RespHandler) handler;

-(void) registerSender:(NSString*) tokenId name:(NSString*)name email:(NSString*) email  completion:(RespHandler) handler;
-(void) registerRecepient:(NSString*) tokenId name:(NSString*)name email:(NSString*) email completion:(RespHandler) handler;
-(void) submitPay:(NSString*)userId customerId:(NSString*) customerId amount:(NSString*) amount completion:(RespHandler) handler;

-(NSString*) getLastServerError;
@end
