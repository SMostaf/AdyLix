//
//  UserController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "UserController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "Parse/Parse.h"
#import "FBLoginViewController.h"
#import "User.h"
#import "Style.h"

@interface UserController ()
@property (weak, nonatomic) IBOutlet UILabel *lblStyleName;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UILabel *lblStylesCount;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;

@end

@implementation UserController

-(void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) showUserInfo {
    
    // adding rounded corners to profile image
    self.imgProfile.layer.cornerRadius = (self.imgProfile.frame.size.width / 2) - 10;
    self.imgProfile.clipsToBounds = YES;
    self.imgProfile.layer.borderWidth = 3.0f;
    self.imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgProfile.image = [UIImage imageNamed:@"emptyProfile.png"];
    
    // showing profile for owners of style
    if(self.user != nil) {
        self.lblStylesCount.text = [NSString stringWithFormat:@"%@%lu", @"Number of styles: ", [[StyleItems getStylesForUser:self.user] count]];
        NSString* userName = [User getFBUserName:self.user];
        if([userName length] > 0)
            self.lblName.text = [NSString stringWithFormat:@"%@%@", @"Welcome ", [User getFBUserName:self.user]];
        PFObject* currStyle = [[User getUserForId:self.user.objectId] valueForKey:@"currentStyleId"];
        if (currStyle != nil) {
            NSString* styleName = [StyleItems getStyleForObj:currStyle];
            if ([styleName length] > 0)
                self.lblStyleName.text = [NSString stringWithFormat:@"%@%@", @"You are looking fabulous in ", styleName];
        }
        
        NSData* imageData = [User getFBProfilePic:self.user];
        self.imgProfile.image = [UIImage imageWithData:imageData];

        self.btnLogout.hidden = YES;
        self.btnSettings.hidden = YES;
    }
    else { // show profile for current user
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            PFUser *currentUser = [PFUser currentUser];
            self.lblStylesCount.text = [NSString stringWithFormat:@"%@%lu", @"Number of styles: ", [[StyleItems getStylesForUser:currentUser] count]];
            self.lblName.text = [NSString stringWithFormat:@"%@%@", @"Welcome ", [User getFBUserName:currentUser]];
            self.lblStyleName.text = [NSString stringWithFormat:@"%@%@", @"You are looking fabulous in ", [StyleItems getStyleForObj:[currentUser valueForKey:@"currentStyleId"]]];
            
            NSData* imageData = [User getFBProfilePic:currentUser];
            self.imgProfile.image = [UIImage imageWithData:imageData];
            
        }
    }
//    // show profile image
//    // in case user logged using parse
//    PFFile *profileImage = [[PFUser currentUser] objectForKey:USER_IMAGE];
//    
//    [profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if(!error)
//            self.imgProfile.image = [UIImage imageWithData:data];
//    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(back:)];

}

- (void)viewWillAppear:(BOOL)animated {
    
}


- (IBAction)btnLogout:(id)sender {
    
    [PFUser logOut];
    
    FBLoginViewController *loginController = [[FBLoginViewController alloc] init];
    [self presentViewController:loginController animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showUserInfo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction)btnChangeStyle:(id)sender {
}

- (IBAction)btnSettingd:(id)sender {
}

@end