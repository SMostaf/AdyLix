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
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property NSDictionary* data;
@end

@implementation PaymentController


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Purchase";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self showPaymentOption];
   // [self showStripeForm];

    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 25;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    self.paymentTextField.frame = CGRectMake(padding, padding, width, 50);
    
    self.activityIndicator.center = self.view.center;
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(id) initWithInfo:(NSString*) price bankId:(NSString*) bankId {
    
    self = [super init];
    if(self)
    {
        self.price = price;
        self.bankId = bankId;
    }
    return self;
}
         
- (void) initWithData:(NSDictionary*) data
{
    // holds on to price and destination Id
    self.data = data;
}

// show stripe card form
-(void) showStripeForm {
    
    // Setup save button
    NSString *title = [NSString stringWithFormat:@"Pay $%@", self.price];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    saveButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    // paymentTextField.cursorColor = [UIColor purpleColor];
    self.paymentTextField = paymentTextField;
    [self.view addSubview:paymentTextField ];
    

}

-(void) showPaymentOption {
    
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

        [self presentViewController:paymentController animated:NO completion: nil];
     //      [self.navigationController pushViewController:paymentController animated:NO];
    
    } else {
       // show stripe card text
        [self showStripeForm];
    }


}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
didAuthorizePayment:(PKPayment *)payment
completion:(void (^)(PKPaymentAuthorizationStatus))completion {
 
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:NO completion:nil];
   
    [self.navigationController popToRootViewControllerAnimated:YES];

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
        if(status == PKPaymentAuthorizationStatusSuccess)
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Thank you for your payment.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

            else
            {
                NSError* error = [[NSError alloc]initWithDomain:@"Received error From Server"
                                                              code:2 userInfo:nil];
                
                [self handleError:error];
            }
        
        completion(status);
    }];

}

-(void) handleError:(NSError*) error
{
    if(error)
      NSLog(@"Error during payment %@, %@", error, [error userInfo]);

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, transaction failed...try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

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
                                                  [self handleError:error];
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
