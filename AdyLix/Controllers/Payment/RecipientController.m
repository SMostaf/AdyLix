//
//  PaymentController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 11/1/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecipientController.h"
//#import "ItemListViewController.h"
#include "PaymentHandler.h"
#import "Stripe.h"
#import "Parse/Parse.h"
#import "User.h"
#import "connector.h"


// based on Stripe: https://stripe.com/docs/mobile/ios#collecting-card-information
@interface RecipientController()<STPPaymentCardTextFieldDelegate>
 // holds on to data with price and destination Id
@property(nonatomic) STPPaymentCardTextField *paymentTextField;
@property(nonatomic) UITextField* nameTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) TTTAttributedLabel *attributedLabel;
@end


@implementation RecipientController


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Adress Info";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self showStripeForm];

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
    self.navigationItem.rightBarButtonItem.enabled = (textField.isValid && [self.nameTextField.text length] > 0);
}

- (void)cancel:(id)sender {
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

// show stripe card form
-(void) showStripeForm {
#ifdef PAY
    // Setup save button
    NSString *title = @"Save";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    saveButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // add legal name
    UITextField *nameTextField = [[UITextField alloc] init];
    nameTextField.placeholder = @"Enter your full name";
    self.nameTextField = nameTextField;
    
    [self.view addSubview:nameTextField];

    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    self.paymentTextField = paymentTextField;
    
    
    [self.view addSubview:self.paymentTextField];
    
//    // privacy link
//    NSString* policyUrl = @"https://stripe.com/connect/account-terms";
//    NSURL *url = [NSURL URLWithString:policyUrl];
//    self.attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(25, 200, 100, 0)];
//    
//    //self.attributedLabel.font = [UIFont systemFontOfSize:15];
//   // self.attributedLabel.text = @"Tap here!";
//    //self.attributedLabel.linkAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15]};
//    [self.attributedLabel setText:@"test"];
    //self.attributedLabel.backgroundColor = [UIColor lightGrayColor];
   // self.attributedLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    //[self.attributedLabel addLinkToURL:[NSURL URLWithString:policyUrl] withRange:[self.attributedLabel.text rangeOfString:policyUrl]];
                                                                                    
//    self.attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectInset(self.view.bounds, 25, 180)];
  //  self.attributedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//    NSRange range = [policyUrl rangeOfString:policyUrl];
//    [self.attributedLabel addLinkToURL:url withRange:range];
//    
    
    TTTAttributedLabel* attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"Tom Bombadil"
                                                                    attributes:@{
                                                                                 (id)kCTForegroundColorAttributeName : (id)[UIColor redColor].CGColor,
                                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                                                                                 NSKernAttributeName : [NSNull null],
                                                                                 (id)kTTTBackgroundFillColorAttributeName : (id)[UIColor greenColor].CGColor
                                                                                 }];

    attributedLabel.text = attString;
    attributedLabel.delegate = self;
    
    self.attributedLabel = attributedLabel;
    [self.view addSubview:self.attributedLabel];
#endif
 }

#pragma mark - payment events

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
        // save tokenized debit card info on server
        // don't ask user again
        // suingle use token
        NSString* strToken = token.tokenId;
        NSString* strName = self.nameTextField.text;
        if([strName length] > 0 || [strToken length] > 0)
        {
            [self handleError:nil];
            return;
        }
        [PaymentHandler registerRecepient:strToken  name:strName completion:^(PKPaymentAuthorizationStatus status) {
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
     [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Information saved successfully", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
    
  //  ItemListViewController* itemsController = [[ItemListViewController alloc] init];
   // [self.navigationController pushViewController:itemsController animated:NO];
    
}
-(void) handleError:(NSError* __nullable) error
{
    if(error)
      NSLog(@"Error during saving %@, %@", error, [error userInfo]);
    NSString* message = @"Sorry, failed to save your info";
    
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
                                                              [self handleError:nil];
                                                  }];
                                              }
                                          }];
#endif
}
@end
