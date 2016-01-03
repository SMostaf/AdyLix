//
//  UserController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "SettingsController.h"
#import <Parse/Parse.h>
#import "Utility.h"

@interface SettingsController ()

@property (weak, nonatomic) IBOutlet UISlider *discRange;
@property (weak, nonatomic) IBOutlet UISwitch *discSwitch;

@property (weak, nonatomic) IBOutlet UILabel *lblPoints;
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;

@property (strong, nonatomic) IBOutlet UITableView *tblView;
//@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

@implementation SettingsController



- (void)viewWillAppear:(BOOL)animated {
    

    self.tblView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
}


- (void)viewDidLoad {

   [super viewDidLoad];
   
  // self.navigationController.navigationBar.hidden = false;
    
   self.discRange.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"range"];
   self.discSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"discoverable"];

    
  // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                                                           //  style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) viewDidDisappear:(BOOL)animated {
    
    [[NSUserDefaults standardUserDefaults] setFloat:[self.discRange value] forKey:@"range"];
    [[NSUserDefaults standardUserDefaults] setBool:[self.discSwitch isOn] forKey:@"discoverable"];
    
    // to be filtered by other users
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:[self.discSwitch isOn]] forKey:@"discoverable"];
    [[PFUser currentUser] saveInBackground];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end