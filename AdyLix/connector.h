//
//  connector.h
//  BCASampleApp
//
//  Created by Sahar Mostafa on 11/20/14.
//  Copyright (c) 2014 Intel. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void(^RespHandler)(NSData* __nullable, NSError* __nullable);


@protocol ConnectionResultHandler<NSObject>
-(void) receiveData:(bool) status;
@end

@interface Connector : NSObject<NSURLConnectionDelegate>
{
    @private

    id<ConnectionResultHandler> modelDelegate;
   
    NSString* userId;
    NSString* url;
    NSString* tokenResyncDataB64;
    NSString* lastServerError;
    
}
//@property (assign) id<ConnectionResultHandler> delegate;

+(Connector*) getConnector;
//-(void) setDelegate:(id<ConnectionResultHandler>)delegate;

-(void) submitPay:(NSString*)userId token:(NSString*) token amount:(NSString*) amount completion:(RespHandler) handler;
//-(NSString*) getServerTokenId;
//-(void) setServerTokenId:(NSString*) stoken;
//-(void) parseResponse:(NSData*) data;
//-(void) verifyID:(NSString*) deviceID input:(NSString*) b64Challenge;
//-(void) verifyAttestation:(NSString*) attestation msg:(NSString*) hash;
//-(void) resyncToken:(NSString*) url;
//-(NSString*) getTokenResyncDataB64;
-(NSString*) getLastServerError;
@end
