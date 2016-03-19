//
//  SenderController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 11/1/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SenderController.h"
#include "PaymentHandler.h"
#import "Stripe.h"
#import "Parse/Parse.h"
#import "connector.h"
#define MERCHANTID @"merchant.com.adylix"

// based on Stripe: https://stripe.com/docs/mobile/ios#collecting-card-information
@interface SenderController()<STPPaymentCardTextFieldDelegate>
 // holds on to data with price and destination Id
@property(nonatomic) STPPaymentCardTextField *paymentTextField;
@property(nonatomic) UITextField* nameTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property NSDictionary* data;
@property (nonatomic) TTTAttributedLabel *attributedLabel;
@end

static inline NSRegularExpression * NameRegularExpression() {
    static NSRegularExpression *_nameRegularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _nameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"^\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _nameRegularExpression;
}


@implementation SenderController


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Purchase";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
    [self showPaymentOption];

    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
    
    // privacy link
    NSString* policyUrl = [NSString stringWithString:@"www.adylix.com/privacy"];
    self.attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectInset(self.view.bounds, 10.0f, 70.0f)];
    self.attributedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSRange range = [policyUrl rangeOfString:policyUrl];
    [self.attributedLabel addLinkToURL:[NSURL URLWithString:policyUrl] withRange:range]; // Embedding a custom link in a substring

    self.attributedLabel.delegate = self;
    [self.view addSubview:self.attributedLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 25;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    self.nameTextField.frame = CGRectMake(padding, padding, width, 50);
    
    self.paymentTextField.frame = CGRectMake(padding, padding + 80, width, 50);
    
    self.activityIndicator.center = self.view.center;

}


- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}


- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


// show stripe card form
-(void) showStripeForm {
    
#ifdef PAY
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
    
    
    // add legal name
    UITextField *nameTextField = [[UITextField alloc] init];
    nameTextField.placeholder = @"Enter your full name";
    self.nameTextField = nameTextField;
    
    [self.view addSubview:nameTextField];
#endif

}

-(void) showPaymentOption {
#ifdef PAY
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
    request.requiredBillingAddressFields =  PKShippingTypeShipping; //| PKAddressFieldPostalAddress
    
    if ([Stripe canSubmitPaymentRequest:request]) {

#ifdef DEBUG
        
        [self showStripeForm];

        paymentController = [[STPTestPaymentAuthorizationViewController alloc]
                             initWithPaymentRequest:request];
        ((STPTestPaymentAuthorizationViewController*)paymentController).delegate = self;
        
        [paymentController.view addSubview:self.nameTextField];

#else
     paymentController = [[PKPaymentAuthorizationViewController alloc]
                             initWithPaymentRequest:request];
        ((PKPaymentAuthorizationViewController*)paymentController).delegate = self;
#endif

        [self presentViewController:paymentController animated:NO completion: nil];
     }
 
     else {
       // show stripe card text
        [self showStripeForm];
    }
#endif

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
#ifdef PAY
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                
                                                 
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
#endif
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    @try
    {
    // save tokenized credit card info on server
    // don't ask user again
    // suingle use token
    NSString* strTtoken = token.tokenId;
    [PaymentHandler registerSenderAndTransfer:strTtoken item:self.itemId recepientId:self.recepientId amount:self.price completion:^(PKPaymentAuthorizationStatus status) {
        if(status == PKPaymentAuthorizationStatusSuccess)
             [self handleSuccess];

            else
            {
                NSError* error = [[NSError alloc]initWithDomain:@"Received error From Server"
                                                              code:2 userInfo:nil];
                
                [self handleError:error];
            }
        
           completion(status);
      }];
    }@catch(...)
    {
        NSLog(@"Caught an excweption on saving to backend");
        completion(PKPaymentAuthorizationStatusFailure);
    }
}

-(void) handleSuccess
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Thank you for your payment", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
}

-(void) handleError:(NSError*) error
{
    if(error)
      NSLog(@"Error during payment %@, %@", error, [error userInfo]);
    NSString* message = @"Sorry, transaction failed...try again later";
  
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(message, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

}
// #TODO: add scan card feature using camera
// Ongetting token, charge using sripe
- (IBAction)save:(id)sender {
    if(!self.paymentTextField.isValid)
    {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Missing Information", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        return;
    }
#ifdef PAY
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
                                                              [self handleSuccess];
                                                          
                                                          else
                                                              [self handleError:error];

                                                  }];
                                              }
                                          }];
#endif
}
@end
