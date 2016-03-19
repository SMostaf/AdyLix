//
//  RegisterController.m
//  Ady
//  Controller to register new items
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVCaptureInput.h>
#import "MBProgressHUD.h"
#import "RegisterController.h"
#import "RegisterItemController.h"
#import "Parse/Parse.h"
#import "Style.h"
#import "User.h"
#import "Utility.h"

@interface RegisterController()
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@end

@implementation RegisterController


-(void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.btnCancel.layer.cornerRadius = 25;
    self.btnCancel.clipsToBounds = YES;
    
    //self.txtName.text = @"Enter Item Description";
    self.txtName.textColor = [UIColor lightGrayColor];
    self.txtName.delegate = self;
    
    self.navigationView.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
  //  [self captureImage];
}

-(void) viewDidAppear:(BOOL)animated {
    
    if(!self.camViewShowing) {
        // if the edit view is opened from the item tableview controller
        if(self.editStyleId) {
            PFObject* styleObj = [StyleItems getStyleForId:self.editStyleId];
            
            self.txtName.text = [styleObj valueForKey:@"name"];
            
            PFFile* thumbnail = [styleObj valueForKey:@"imageFile"];
            [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.feedImage.image = self.itemImage = [UIImage imageWithData:data];
                
            }];
            
            self.chkDiscover.on = [StyleItems isCurrentStyle:styleObj];

        }
        else
            [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
        self.camViewShowing = true;
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.txtName resignFirstResponder];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.txtDesc.text = @"";
    self.txtDesc.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.txtDesc.text.length == 0){
        self.txtDesc.textColor = [UIColor lightGrayColor];
        self.txtDesc.text = @"Comment";
        [self.txtDesc resignFirstResponder];
    }
}

- (IBAction)btnAddItem:(id)sender {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnSave:(id)sender {
    @try
    {
   // UIImage* itemImage = [self.regController getImage];
        
    if (self.txtName.text.length == 0
        || self.itemImage == nil)
    {
        UIAlertController* alertView = [Utility getAlertViewForMessage:NSLocalizedString(@"Missing Information", nil)  msg:NSLocalizedString(@"Make sure you fill out all of the information!", nil) action: nil];
        alertView.popoverPresentationController.sourceView = self.view;
        [self presentViewController:alertView animated:YES completion:nil];

        return;
    }

    
    
    PFObject *style = [PFObject objectWithClassName:@"StyleMaster"];
    [style setObject:self.txtName.text forKey:@"name"];
   // [style setObject:[NSNumber numberWithBool:YES] forKey:@"isDiscoverable"];
        
    //[item setObject:self.txtDesc.text forKey:@"description"];
    
    if (self.chkDiscover.on)
        [style setObject:[NSNumber numberWithBool:YES] forKey:@"isDiscoverable"];
    else
        [style setObject:[NSNumber numberWithBool:NO] forKey:@"isDiscoverable"];

    [style setObject:[NSDate date] forKey:@"timeStamp"];
    [style setObject:[PFUser currentUser] forKey:@"userId"];

    // item image
    NSData* data = UIImageJPEGRepresentation(self.itemImage, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    [style setObject:imageFile forKey:@"imageFile"];
    
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    
    // Upload item to Parse
    [style saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        
        if (!error) {
            
            // check if user wants to set the new style as current style
            if (self.currStyleSwitch.isOn)
            {
                PFUser* currentUser = [PFUser currentUser];
                [currentUser setObject:style forKey:@"currentStyleId"];
                [currentUser saveInBackground];
            }
            // Show success message
            UIAlertController* alertView = [Utility getAlertViewForMessage:NSLocalizedString(@"Upload Complete", nil)  msg:NSLocalizedString(@"Successfully saved your style", nil) action: nil];
            alertView.popoverPresentationController.sourceView = self.view;
            [self presentViewController:alertView animated:YES completion:nil];

            
            
            // Notify table view to reload the recipes from Parse cloud
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            
            // Dismiss the controller
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            NSLog(@"Error uploading syle: %@", [error localizedDescription]);
            UIAlertController* alertView = [Utility getAlertViewForMessage:NSLocalizedString(@"Upload Error", nil)  msg:NSLocalizedString(@"Failed to save your style", nil) action: nil];
            alertView.popoverPresentationController.sourceView = self.view;
            [self presentViewController:alertView animated:YES completion:nil];
        }
     }];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught an exception on saving item");
    }
}

- (IBAction)btnCamera:(id)sender {
  
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];

}

// camera  related
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    //self.regController = [[RegisterItemController alloc]init];
    
    //[controller presentModalViewController: self.regController animated: YES];
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}



#pragma mark - pic delegate

- (IBAction)btnUpload:(id)sender {
    
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
    
}

- (IBAction)btnGallery:(id)sender {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    
    UIImagePickerController *picker;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentModalViewController: picker animated: YES];
}


# pragma mark - camera delegate
// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.feedImage.image = self.itemImage = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}


@end