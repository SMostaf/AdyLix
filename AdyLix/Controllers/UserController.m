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
#import "Utility.h"

@interface UserController ()
@property (weak, nonatomic) IBOutlet UILabel *lblStyleName;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UILabel *lblStylesCount;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation UserController

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) showUserInfo {
    
    // adding rounded corners to profile image
    self.imgProfile.layer.cornerRadius = (self.imgProfile.frame.size.width / 2) - 10;
    self.imgProfile.clipsToBounds = YES;
    self.imgProfile.layer.borderWidth = 3.0f;
    self.imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgProfile.image = [UIImage imageNamed:@"emptyProfile.png"];
    // menu add quick selfie
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                                                        style:UIBarButtonItemStylePlain target:self action:@selector(back:)];

    self.navigationItem.rightBarButtonItem = [Utility getNavForProfile:self];
   
    
    [self.view addSubview:self.navBar];
    
    PFUser *currentUser = nil;
    // showing profile for owners of style
    if(self.user != nil) {
        currentUser = self.user;
        self.btnLogout.hidden = YES;
        self.btnSettings.hidden = YES;
    }
    else { // show profile for current user
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
           currentUser = [PFUser currentUser];
        else {
            [self btnLogout];
            return;
        }
    }
    
    [StyleItems getStylesForUser:currentUser handler:^(unsigned long count) {
        self.lblStylesCount.text = [NSString stringWithFormat:@"%@%lu", @"Number of styles: ", count];
    }];
    
    NSString* userName = [User getFBUserName:currentUser];
    if([userName length] > 0)
        self.lblName.text = [NSString stringWithFormat:@"%@%@", @"Welcome ", userName];
    
    PFObject* currStyle = [[User getUserForId:currentUser.objectId] valueForKey:@"currentStyleId"];
    if (currStyle != nil) {
        NSString* styleName = [StyleItems getStyleForObj:currStyle];
        if ([styleName length] > 0)
            self.lblStyleName.text = [NSString stringWithFormat:@"%@%@", @"You are looking fabulous in ", styleName];
    }
        
   [User getFBProfilePic:currentUser handler:^(UIImage* image) {
       if (image != nil)
        self.imgProfile.image = image;
       else
        self.imgProfile.image = [UIImage imageNamed:@"emptyProfile.png"];
    }];
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.hidden = false;
}


- (IBAction)btnLogout:(id)sender {
    
    [PFUser logOut];
    
    FBLoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
   
    [self.navigationController pushViewController:loginController animated:NO];
    
  //  [self presentViewController:loginController animated: NO completion:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // round corner
    self.btnLogout.layer.cornerRadius = 15;
    self.btnLogout.clipsToBounds = YES;
    
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