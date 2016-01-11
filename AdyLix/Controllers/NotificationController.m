//
//  NotificationController.m
//  Ady
//  Notification center shows all notifications when user like style or item
//  a user own
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import <ParseUI/PFImageView.h>
#import "NotificationController.h"
#import "UserController.h"
#import "RegisterController.h"
#import "WardrobeController.h"
#import "LocateController.h"
#import "Parse/Parse.h"
#import "User.h"
#import "Style.h"
#import "Utility.h"

typedef enum {
    DecLabelTag = 100,
    ThumbnailTag = 101,
    CustomeTag = 102
} NotifyTagID;


@interface NotificationController ()

@property (strong, nonatomic) IBOutlet UITableView *tblView;

@property BOOL loaded;

@end

@implementation NotificationController

- (void) viewDidAppear:(BOOL)animated
{

    self.navigationController.navigationBar.hidden = false;
    if(!self.loaded) {
        NSArray<UIBarButtonItem*> *navigationItems = [Utility getNavOtherMenu:self];
    
        self.navigationItem.leftBarButtonItems = navigationItems;
    
        self.loaded = YES;
    }
    [self loadObjects];
}

-(void) viewDidLoad {

    [super viewDidLoad];
    self.tblView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

- (void) viewWillDisappear:(BOOL)animated
{
    // make sure back menu item does not appear
    self.navigationController.navigationBar.hidden = true;
}


-(void) showLocater:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:NO];

}


-(void) showWardrobe:(id)sender {
  
     NSArray * controllerArray = [[self navigationController] viewControllers];

     for (UIViewController *controller in controllerArray) {
         if ([NSStringFromClass([controller class]) isEqualToString:@"WardrobeController"]) {
            [self.navigationController popToViewController:controller animated:NO];
             return;
        }
      }
    
     WardrobeController *wardrobeController = [self.storyboard instantiateViewControllerWithIdentifier:@"wardrobeController"];
     [self.navigationController pushViewController:wardrobeController animated:NO];
}

-(void) showNotify:(id)sender {
}

-(void) showProfile:(id)sender {
    
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    //[self presentViewController:userController animated:YES completion:nil];
    [self.navigationController pushViewController:userController animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"ItemLike";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"name";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
    }
    return self;
}


- (PFQuery *)queryForTable {
    PFQuery *query;

    if ([PFUser currentUser])
    {
        query = [PFQuery queryWithClassName:self.parseClassName];
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query whereKey:@"userTo" equalTo:[PFUser currentUser]];
        
        
        // If no objects are loaded in memory, we look to the cache
        // first to fill the table and then subsequently do a query
        // against the network.
        if ([self.objects count] == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }

        [query orderByDescending:@"createdAt"];
        
    }
  
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{

    static NSString *itemTableIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }

    PFUser* userObj = [object objectForKey:@"userFrom"];
    NSLog(@"userfrom: %@", userObj.objectId);
    PFObject* styleObj = [object objectForKey:@"styleId"];
    // find a better way to query table
    if(userObj && styleObj) {
        PFObject* styleInfo = [StyleItems getStyleForId:styleObj.objectId];
        // #TODO: include key username, instead of doing another query
        PFObject* userInfo =  [User getUserForId:userObj.objectId];
    
        NSString* userName = [userInfo valueForKey:@"username"];
        NSString* styleName = [styleInfo valueForKey:@"name"];
        // User name liked your name style
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@%@", userName, @" likes your ", styleName, @" style"];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([self.objects count])
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        self.tblView.backgroundView   = nil;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblView.bounds.size.width, self.tblView.bounds.size.height)];
        noDataLabel.text             = @"No notifications";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tblView.backgroundView = noDataLabel;
        self.tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numOfSections;
}

@end