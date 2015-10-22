//
//  ItemsController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "ItemsController.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "Parse/Parse.h"

@interface ItemsController ()
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITableView *itemsTblView;
@property (weak, nonatomic) IBOutlet UITextView *txtDesc;
@property (weak, nonatomic) IBOutlet UISwitch *chkDiscover;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) UIImage* itemImage;
@end

@implementation ItemsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnSave:(id)sender {
    
    if (self.txtName.text.length == 0 || self.txtPrice.text.length == 0
        || [self itemImage] == nil)
    {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
        return;
    }
    PFObject *item = [PFObject objectWithClassName:@"ItemDetail"];
    [item setObject:self.txtName.text forKey:@"name"];
    [item setObject:self.txtPrice.text forKey:@"price"];
    
    [item setObject:self.txtDesc.text forKey:@"description"];
    
    if (self.chkDiscover.selected)
        [item setObject:[NSNumber numberWithBool:YES] forKey:@"isDiscoverable"];
    else
        [item setObject:[NSNumber numberWithBool:NO] forKey:@"isDiscoverable"];

    
    [item setObject:[NSDate date] forKey:@"timeStamp"];
    
    
    // item image
    NSData *imageData = UIImageJPEGRepresentation(self.itemImage.images[0], 0.8);
    NSString *filename = [NSString stringWithFormat:@"%@.png", self.txtName.text];
    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully saved the recipe" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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


// camera  related
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
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

- (IBAction)btnUpload:(id)sender {
    
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];

}

// gallery related
//- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
//                               usingDelegate: (id <UIImagePickerControllerDelegate,
//                                               UINavigationControllerDelegate>) delegate {
//    
//    if (([UIImagePickerController isSourceTypeAvailable:
//          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
//        || (delegate == nil)
//        || (controller == nil))
//        return NO;
//    
//    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
//    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    
//    // Displays saved pictures and movies, if both are available, from the
//    // Camera Roll album.
//    mediaUI.mediaTypes =
//    [UIImagePickerController availableMediaTypesForSourceType:
//     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//    
//    // Hides the controls for moving & scaling pictures, or for
//    // trimming movies. To instead show the controls, use YES.
//    mediaUI.allowsEditing = NO;
//    
//    mediaUI.delegate = delegate;
//    
//    [controller presentModalViewController: mediaUI animated: YES];
//    return YES;
//}

#pragma mark - gallery delegate

- (IBAction)btnGallery:(id)sender {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures from the Camera Roll album.
    mediaUI.mediaTypes = @[(NSString*)kUTTypeImage];
    
    // Hides the controls for moving & scaling pictures
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = self;
    
    [self.navigationController presentModalViewController: mediaUI animated: YES];
}

//- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
//    
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//    UIImage *originalImage, *editedImage, *imageToUse;
//    
//    // Handle a still image picked from a photo album
//    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
//        == kCFCompareEqualTo) {
//        
//        editedImage = (UIImage *) [info objectForKey:
//                                   UIImagePickerControllerEditedImage];
//        originalImage = (UIImage *) [info objectForKey:
//                                     UIImagePickerControllerOriginalImage];
//        
//        if (editedImage) {
//            imageToUse = editedImage;
//        } else {
//            imageToUse = originalImage;
//        }
//        // Do something with imageToUse
//    }
//    
//    // Handle a movied picked from a photo album
//    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
//        == kCFCompareEqualTo) {
//        
//        NSString *moviePath = [[info objectForKey:
//                                UIImagePickerControllerMediaURL] path];
//        
//        // Do something with the picked movie available at moviePath
//    }
//    
//    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
//}

# pragma mark - camera delegate
// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    self.itemImage = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//    UIImage *originalImage, *editedImage, *imageToSave;
//    
//    // Handle a still image capture
//    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
//        == kCFCompareEqualTo) {
//        
//        editedImage = (UIImage *) [info objectForKey:
//                                   UIImagePickerControllerEditedImage];
//        originalImage = (UIImage *) [info objectForKey:
//                                     UIImagePickerControllerOriginalImage];
//        
//        if (editedImage) {
//            imageToSave = editedImage;
//        } else {
//            imageToSave = originalImage;
//        }
//        
//        // Save the new image (original or edited) to the Camera Roll
//        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
//    }
//    
//   
//    
//    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}


@end