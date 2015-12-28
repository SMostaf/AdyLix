//
//  ItemsController.m
//  Ady
//  Controller to register new items
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "ItemsController.h"
#import "RegisterItemController.h"
#import "Parse/Parse.h"
#import "User.h"

@interface ItemsController ()
@property (weak, nonatomic) IBOutlet UITextView *txtDesc;
@property (weak, nonatomic) IBOutlet UISwitch *chkDiscover;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property UIImage* itemImage;
@property RegisterItemController* regController;
@end

@implementation ItemsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtDesc.text = @"Enter Item Description";
    self.txtDesc.textColor = [UIColor lightGrayColor];
    self.txtDesc.delegate = self;
    
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
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnSave:(id)sender {
    @try
    {
    UIImage* itemImage = [self.regController getImage];
        
    if (self.txtName.text.length == 0
        || itemImage == nil)
    {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
        return;
    }


    
    PFObject *item = [PFObject objectWithClassName:@"ItemDetail"];
    [item setObject:self.txtName.text forKey:@"name"];
    [item setObject:self.txtDesc.text forKey:@"description"];
    
    if (self.chkDiscover.on)
        [item setObject:[NSNumber numberWithBool:YES] forKey:@"isDiscoverable"];
    else
        [item setObject:[NSNumber numberWithBool:NO] forKey:@"isDiscoverable"];

    NSString* userName = [[PFUser currentUser] objectForKey:@"username"];
    [item setObject:[NSDate date] forKey:@"timeStamp"];
    [item setObject:[[PFUser currentUser] valueForKey:@"objectId"] forKey:@"userObjectId"];

    // item image
   
    NSData* data = UIImageJPEGRepresentation(itemImage, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    [item setObject:imageFile forKey:@"imageFile"];
    
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    
    // Upload item to Parse
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        
        if (!error) {
            // Show success message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully saved your item" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        
            
            // Notify table view to reload the recipes from Parse cloud
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            
            // Dismiss the controller
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
    }];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught an exception on saving item");
    }
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
    
    self.regController = [[RegisterItemController alloc]init];
    
    [controller presentModalViewController: self.regController animated: YES];
//    
//    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
//    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    // Displays a control that allows the user to choose picture or
//    // movie capture, if both are available:
//    cameraUI.mediaTypes =
//    [UIImagePickerController availableMediaTypesForSourceType:
//     UIImagePickerControllerSourceTypeCamera];
//    
//    // Hides the controls for moving & scaling pictures, or for
//    // trimming movies. To instead show the controls, use YES.
//    cameraUI.allowsEditing = NO;
//    
//    cameraUI.delegate = delegate;
//    
//    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (IBAction)btnCancel:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
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
    self.itemImage = originalImage;
   
    [picker dismissViewControllerAnimated:YES completion:nil];

}


@end