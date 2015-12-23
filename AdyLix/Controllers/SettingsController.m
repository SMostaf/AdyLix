//
//  UserController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "SettingsController.h"
#import <Parse/Parse.h>

@interface SettingsController ()

@property (weak, nonatomic) IBOutlet UISlider *proxRange;
@property (weak, nonatomic) IBOutlet UISwitch *discoverSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblPoints;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

@implementation SettingsController


-(void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    
}

- (IBAction)btnRedeem:(id)sender {
}

- (IBAction)btnSave:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setFloat:[self.proxRange value] forKey:@"range"];
    [[NSUserDefaults standardUserDefaults] setBool:[self.discoverSwitch isOn] forKey:@"discoverable"];

    // to be filtered by other users
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:[self.discoverSwitch isOn]] forKey:@"discoverable"];
    [[PFUser currentUser] saveInBackground];
    
     [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
   self.proxRange.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"range"];
   self.discoverSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"discoverable"];

    
   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


@end