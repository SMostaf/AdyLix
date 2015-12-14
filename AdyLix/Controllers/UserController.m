//
//  UserController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "UserController.h"
#import "ASStarRatingView.h"
#import "Parse/Parse.h"
#import "MainController.h"
#import "User.h"

@interface UserController ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@end

@implementation UserController


- (void) setupView {
    
    // adding rounded corners to profile image
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2;
    self.imgProfile.clipsToBounds = YES;
    self.imgProfile.layer.borderWidth = 3.0f;
    self.imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // show profile image
    // in case user logged using parse
    PFFile *profileImage = [[PFUser currentUser] objectForKey:USER_IMAGE];
    
    [profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(!error)
            self.imgProfile.image = [UIImage imageWithData:data];
    }];

}

- (void)viewWillAppear:(BOOL)animated {
   [self setupView];
}

- (IBAction)btnLogout:(id)sender {
    [PFUser logOut];
    
    MainController *mainController = [[MainController alloc] init];
    
    [self presentViewController:mainController animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [self setupView];
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

@end