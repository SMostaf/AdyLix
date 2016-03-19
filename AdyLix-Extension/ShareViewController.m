//
//  ShareViewController.m
//  AdyLix-Extension
//
//  Created by Sahar Mostafa on 11/9/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    NSInteger messageLength = [[self.contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    NSInteger charactersRemaining = 100 - messageLength;
    self.charactersRemaining = @(charactersRemaining);
    
    if (charactersRemaining >= 0) {
        return YES;
    }
    
    return NO;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    // save link to backend
    // opening App pulls that data from backend and shows to user
   
   // NSUserDefaults* userDefaults = [NSUserDefaults initWithSuiteName:@""];
    // send: self.contentText to backend
    
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    
    NSExtensionItem *outputItem = [inputItem copy];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:self.contentText attributes:nil];
    // Complete this implementation by setting the appropriate value on the output item.
    
    NSArray *outputItems = @[outputItem];

    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
