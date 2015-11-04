//
//  PaymentController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 11/1/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentController.h"
#import "Stripe.h"
#import "Parse/Parse.h"
#import "connector.h"

// based on Stripe: https://stripe.com/docs/mobile/ios#collecting-card-information
@interface PaymentController()<STPPaymentCardTextFieldDelegate>
@property(nonatomic) STPPaymentCardTextField *paymentTextField;
// holds on to data with price and destination Id
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property NSDictionary* data;
@end

@implementation PaymentController

- (void) initWithData:(NSDictionary*) data
{
    // holds on to price and destination Id
    self.data = data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(self.view.frame) - 30, 44)];
    //self.paymentTextField.set
    self.paymentTextField.delegate = self;
    [self.view addSubview:self.paymentTextField];
}

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
    NSString* strToken = token.tokenId;
    [[PFUser currentUser] setObject:strToken forKey:@"tokenId"];

    
    Connector* connector = [Connector getConnector];
    //connector.delegate = self;
    [connector submitPay:self.data[@"bankId"] token: strToken amount: self.data[@"amount"] completion:
     ^(NSData *data,
       NSError *error) {
         if (error) {
             completion(PKPaymentAuthorizationStatusFailure);
         } else {
             completion(PKPaymentAuthorizationStatusSuccess);
         }

     }];
    

    /*
     NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
     request.HTTPMethod = @"POST";
     NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
     request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
     
     [NSURLConnection sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response,
     NSData *data,
     NSError *error) {
     if (error) {
     completion(PKPaymentAuthorizationStatusFailure);
     } else {
     completion(PKPaymentAuthorizationStatusSuccess);
     }
     }];*/
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
