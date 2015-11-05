//
//  PaymentController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 11/1/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentController.h"
#include "PaymentHandler.h"
#import "Stripe.h"
#import "Parse/Parse.h"
#import "connector.h"
#define MERCHANTID @"merchant.com.adylix"

// based on Stripe: https://stripe.com/docs/mobile/ios#collecting-card-information
@interface PaymentController()<STPPaymentCardTextFieldDelegate>
 // holds on to data with price and destination Id
@property(nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property NSDictionary* data;
@end

@implementation PaymentController

-(void) viewDidLoad {
    
    [super viewDidLoad];
    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(self.view.frame) - 30, 44)];
    //self.paymentTextField.set
    self.paymentTextField.delegate = self;
    [self.view addSubview:self.paymentTextField];

    
    UIViewController *paymentController;
    // first time registration
    // show payment Dialogue
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:MERCHANTID];
    // Configure your request here.
    NSString *pLabel = @"Purchase Request";
    
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.price];
    
    request.paymentSummaryItems = @[
                                    [PKPaymentSummaryItem summaryItemWithLabel:pLabel
                                                                        amount:amount]
                                    ];
    //request.;
    if ([Stripe canSubmitPaymentRequest:request]) {
        
#ifdef DEBUG
        
        paymentController = [[STPTestPaymentAuthorizationViewController alloc]
                             initWithPaymentRequest:request];
        ((STPTestPaymentAuthorizationViewController*)paymentController).delegate = self;
        
        
        
#else
        paymentController = [[PKPaymentAuthorizationViewController alloc]
                             initWithPaymentRequest:request];
        paymentController.delegate = self;
#endif
        
        [self presentViewController:paymentController animated:NO completion: nil];//^void(BOOL success) {
        // if success
        // delete item from Item Detail
        // completion(true);
        // return true;
        //  }];
        //}];
    } else {
        // Show the user your own credit card form (see options 2 or 3)
    }

}

-(id) initWithInfo:(NSString*) price bankId:(NSString*) bankId {
    
    self = [super init];
    if(self)
    {
        self.price = price;
        self.bankId = bankId;
        NSString* strPrice = self.price;// [NSString stringWithFormat:@"%@%@", @"$", self.price];
        [self.btnSave setTitle:strPrice forState:UIControlStateNormal];
    }
    return self;
}
         
- (void) initWithData:(NSDictionary*) data
{
    // holds on to price and destination Id
    self.data = data;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(self.view.frame) - 30, 44)];
//    //self.paymentTextField.set
//    self.paymentTextField.delegate = self;
//    [self.view addSubview:self.paymentTextField];
//}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
didAuthorizePayment:(PKPayment *)payment
completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
        // Toggle navigation, for example
       // self.saveButton.enabled = textField.isValid;
    }


- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                
                                                 
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    // save tokenized credit card info on server
    // don't ask user again
    // suingle use token
    NSString* strTtoken = token.tokenId;
    [PaymentHandler registerSender:strTtoken item:self.itemId bankId:self.bankId amount:self.price completion:^(PKPaymentAuthorizationStatus status) {
               completion(status);
    }];

}


// #TODO: add scan card feature using camera
// Ongetting token, charge using sripe
- (IBAction)save:(id)sender {
    if(!self.paymentTextField.isValid)
    {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Missing Information", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        return;
    }
    STPCardParams *card = [[STPCardParams alloc] init];
    card.number = self.paymentTextField.card.number;
    card.expMonth = self.paymentTextField.card.expMonth;
    card.expYear = self.paymentTextField.card.expYear;
    card.cvc = self.paymentTextField.card.cvc;
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  //[self handleError:error];
                                              } else {
                                                  [self createBackendChargeWithToken:token completion:^(PKPaymentAuthorizationStatus status) {
                                             
                                                          if(status == PKPaymentAuthorizationStatusSuccess)
                                                        
                                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Thank you for your payment", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                                                          
                                                    else
                                                          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, Payment failed...try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

                                                  }];
                                              }
                                          }];
}
@end
