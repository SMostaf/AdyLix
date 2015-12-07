//
//  RegsiterItemController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <ImageIO/ImageIO.h>
#import "MBProgressHUD.h"
#import "RegisterItemController.h"
#import "CaptureSessionManager.h"
#import "Parse/Parse.h"
#import "User.h"

@interface RegisterItemController ()
@property UIImage* croppedImg;
@property UIImageView *overlayImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
//@property(nonatomic, retain) IBOutlet UIImageView *itemImage;
@property CaptureSessionManager *captureManager;
@property (nonatomic, weak) UILabel *scanningLabel;

@end

@implementation RegisterItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    
    [[self captureManager] addVideoInput];
    
    [[self captureManager] addVideoPreviewLayer];
    CGRect layerRect = [[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
    [[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    
    self.overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
    [_overlayImageView setFrame:CGRectMake(30, 100, 260, 200)];
    [[self view] addSubview:_overlayImageView];
    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(130, 320, 60, 30)];
    [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:overlayButton];
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [self setScanningLabel:tempLabel];
   
    [_scanningLabel setBackgroundColor:[UIColor clearColor]];
    [_scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
    [_scanningLabel setTextColor:[UIColor redColor]];
    [_scanningLabel setText:@"Scanning..."];
    [_scanningLabel setHidden:YES];
    [[self view] addSubview:_scanningLabel];
    
    
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    [[_captureManager captureSession] addOutput:_stillImageOutput];
    
    [[_captureManager captureSession] startRunning];
    
    
//    self.txtDesc.text = @"Enter Item Description";
//    self.txtDesc.textColor = [UIColor lightGrayColor];
//    self.txtDesc.delegate = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 UIImage *croppedImg = nil;
 CGRect cropRect = CGRectMake("AS YOu Need"); //set your rect size.
 croppedImg = [self croppIngimageByImageName:self.imageView.image toRect:cropRect];
 Use following code for call croppIngimageByImageName:toRect: method that return UIImage (with specific size of image)
 
 - (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
 {
 //CGRect CropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+15);
 
 CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
 UIImage *cropped = [UIImage imageWithCGImage:imageRef];
 CGImageRelease(imageRef);
 
 return cropped;
 }
 */

-(UIImage*) getImage {
    return _croppedImg;
}

- (void) scanButtonPressed {
    [[self scanningLabel] setHidden:NO];
 //   [self performSelector:@selector(hideLabel:) withObject:[self scanningLabel] afterDelay:2];
    UIImageView* itemView = [[UIImageView alloc]init];
    AVCaptureConnection *videoConnection = nil;
//    UIImage *image = [UIImage imageNamed:@"dogs.png"];
//    UIImage *maskImage = [UIImage imageNamed:@"mask.png"];
//    
//    CGImageRef maskRef = maskImage.CGImage;
//    
//    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                        CGImageGetHeight(maskRef),
//                                        CGImageGetBitsPerComponent(maskRef),
//                                        CGImageGetBitsPerPixel(maskRef),
//                                        CGImageGetBytesPerRow(maskRef),
//                                        CGImageGetDataProvider(maskRef), NULL, false);
//    
//    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
//    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", _stillImageOutput);
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
             [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

         }
         else
             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         itemView.image = image;
     
        // crop image and save to DB
        CGSize prevSize = [[self captureManager] previewLayer].frame.size;
        UIGraphicsBeginImageContextWithOptions(prevSize, NO, 0.0);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

        
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, 0.0, prevSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGImageRef maskImage = [[UIImage imageNamed:@"red.png"] CGImage];
        CGContextClipToMask(context, [[self captureManager] previewLayer].bounds, maskImage);
        
        CGContextTranslateCTM(context, 0.0, prevSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        [itemView.image drawInRect:[[self captureManager] previewLayer].bounds];
        
      
                                                     
        _croppedImg  = UIGraphicsGetImageFromCurrentImageContext();
        

         [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    }];
    
    
  //  self.imageView.image = image;
    
    
    
    //self.overlayImageView.frame.origin.x
//    CGRect clippedRect  = CGRectMake(0 ,0,180 ,180);
//    CGImageRef imageRef = CGImageCreateWithImageInRect(imgVw1.image.CGImage, clippedRect);
//    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
//    
//    
//    UIBezierPath *aPath = [UIBezierPath bezierPath];
//    
//    // Set the starting point of the shape.
//    [aPath moveToPoint:CGPointMake(100.0, 0.0)];
//    
//    // Draw the lines.
//    [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
//    [aPath addLineToPoint:CGPointMake(160, 140)];
//    [aPath addLineToPoint:CGPointMake(40.0, 140)];
//    [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
//    [aPath closePath];
}

/*
- (IBAction)btnSave:(id)sender {
    @try
    {
        
    if (self.txtName.text.length == 0 || self.txtPrice.text.length == 0
        || self.itemImage == nil)
    {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        
        return;
    }


    
    PFObject *item = [PFObject objectWithClassName:@"ItemDetail"];
    [item setObject:self.txtName.text forKey:@"name"];
    [item setObject:self.txtPrice.text forKey:@"price"];
    [item setObject:self.txtDesc.text forKey:@"description"];
    
    if (self.chkDiscover.on)
        [item setObject:[NSNumber numberWithBool:YES] forKey:@"isDiscoverable"];
    else
        [item setObject:[NSNumber numberWithBool:NO] forKey:@"isDiscoverable"];

    NSString* userName = [[PFUser currentUser] objectForKey:@"username"];
    [item setObject:[NSDate date] forKey:@"timeStamp"];
    [item setObject:[[PFUser currentUser] valueForKey:@"objectId"] forKey:@"userObjectId"];

    // item image
   
    NSData* data = UIImageJPEGRepresentation(self.itemImage, 0.5f);
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
*/

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
    //[self presentModalViewController: picker animated: YES];
}


# pragma mark - camera delegate


@end