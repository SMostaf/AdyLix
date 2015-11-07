
//
//  connector.m
//  Layer to handle all requests to Parse cloud
//
//  Created by Sahar Mostafa on 11/20/14.
//  Copyright (c) 2014 Intel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "connector.h"

#define PARSE_APP_ID @"AotKeCXXy3BIbipBkHWI0hkEeBsrW3sGm738gPVT"
#define REST_KEY_ID  @"36tCnMKHTomoh588fsxhqZjf9bvDHelKwEsYr1rj"


@interface Connector()
-(void) doPost:(NSString*) url body: (NSString*) reqBody;
@property (nonatomic,strong) RespHandler respHandler;
@property NSString* lastServerError;
@end

static NSString* serverURL = @"https://api.parse.com/1/functions/";

@implementation Connector

-(void) doPost:(NSString*) url body: (NSString*) reqBody {

    NSLog(@"jsonRequest is %@", reqBody);
    
    NSData *requestData = [reqBody dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableString* swUrl = [serverURL stringByAppendingString: url];
    NSLog(@"sending request to url: %@", swUrl);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:swUrl]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:PARSE_APP_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:REST_KEY_ID forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    
    [request setHTTPBody: requestData];
    [request setTimeoutInterval:10];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

// register token for purchaser
-(void) registerSender:(NSString*) tokenId name:(NSString*)name email:(NSString*) email completion:(RespHandler) handler {
    
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:
                              [NSArray arrayWithObjects:name, email,tokenId, nil]
                                                         forKeys:[NSArray arrayWithObjects:@"userName", @"userEmail",@"sourceId", nil]];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    if (jsonError != nil) {
        NSLog(@"Error parsing JSON.");
        return;
    }
    NSString* reqBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (reqBody == nil)
    {
        NSLog(@"Request Error body is nil!");
        return;
    }
    
    self.respHandler = handler;
    
    [self doPost: @"registerSender" body: reqBody];

    
}

// register bank info of recepient of transaction
-(void) registerRecepient:(NSString*) tokenId name:(NSString*)name email:(NSString*) email completion:(RespHandler) handler {

    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:
                              [NSArray arrayWithObjects:name, email, tokenId, nil]
                                                         forKeys:[NSArray arrayWithObjects:@"userName", @"userEmail",@"sourceId", nil]];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    if (jsonError != nil) {
        NSLog(@"Error parsing JSON.");
        return;
    }
    NSString* reqBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (reqBody == nil)
    {
        NSLog(@"Request Error body is nil!");
        return;
    }
    
    self.respHandler = handler;
    
    [self doPost: @"registerRecepient" body: reqBody];
    
    
}

-(void) submitPay:(NSString*)userId customerId:(NSString*) customerId amount:(NSString*) amount
      completion:(RespHandler) handler
{
    
    NSLog(@"Sending new transaction request");

    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:
                              [NSArray arrayWithObjects:userId,customerId, amount, nil]
                                                         forKeys:[NSArray arrayWithObjects:@"sourceId",@"destinationId", @"value",nil]];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    if (jsonError != nil) {
        NSLog(@"Error parsing JSON.");
        return;
    }
    NSString* reqBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (reqBody == nil)
    {
        NSLog(@"Request Error body is nil!");
        return;
    }
    
    self.respHandler = handler;
    
    [self doPost: @"transfer" body: reqBody];
}


#pragma mark ConnectionResultHandler Delegate Methods

-(void) parseResponse:(NSData*) data {
    @try
    {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error != nil) {
            NSLog(@"Error parsing response JSON: %@", [error localizedDescription]);
            if (data == nil)
                NSLog(@" - Data object is nil!");
            else {
                NSString *dataStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog(@" - Response data:%@:", dataStr);
            }
        }
        else {
            if(jsonDict[@"code"])
            {
               NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
               NSError* retError = [[NSError alloc]initWithDomain:@"Received error From Server"
                                                             code:[num numberFromString:jsonDict[@"code"]] userInfo:nil];
                self.respHandler(nil, retError);
            }
            else
            {
                self.respHandler(jsonDict[@"result"], nil);
            }

        }
    }
    @catch(...)
    {
//#TODO:
        NSError* retError = [[NSError alloc]initWithDomain:@"Received error From Server"
                                                      code:1 userInfo:nil];
        self.respHandler(nil, retError);
        NSLog(@"Exception in parsing response");
    }
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self parseResponse:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //NSLog(@"Connection finished loading");
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Received connection Error");
    NSNumber * connectError = [NSNumber numberWithInt:error.code];
    self.respHandler(nil, error);
   //[self.delegate performSelector:@selector(receiveStatus:) withObject:connectError];
}


-(NSString*)getLastServerError {
    return self.lastServerError;
}

@end

