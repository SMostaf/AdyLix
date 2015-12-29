//
//  ItemsController.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef RegisterController_h
#define RegisterController_h
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureOutput.h>

@interface RegisterController : UIViewController<UITextViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *currStyleSwitch;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationItem;
@property (weak, nonatomic) IBOutlet UITextView *txtDesc;
@property (weak, nonatomic) IBOutlet UISwitch *chkDiscover;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property UIImage* itemImage;
@property NSString* editStyleId;
@property (weak, nonatomic) IBOutlet UIImageView *feedImage;
@property BOOL camViewShowing;
@end


#endif /* RegisterController_h */
