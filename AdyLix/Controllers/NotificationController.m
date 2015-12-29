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

@end

@implementation NotificationController

- (void) viewDidAppear:(BOOL)animated
{

    UINavigationItem* navigationItem = [Utility getNavMainMenu:self];
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -50, 380, 40)];
    navbar.backgroundColor = [UIColor redColor];
    

    navbar.items = @[navigationItem];
    
    [self.view addSubview:navbar];
    
    self.tblView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
    

}

-(void) showLocater:(id)sender {
    LocateController *locateController = [self.storyboard instantiateViewControllerWithIdentifier:@"discoverController"];
    [self presentViewController:locateController animated:YES completion:nil];
}


-(void) showWardrobe:(id)sender {
    WardrobeController *wardrobeController = [self.storyboard instantiateViewControllerWithIdentifier:@"wardrobeController"];
    [self presentViewController:wardrobeController animated:YES completion:nil];
}

-(void) showNotify:(id)sender {
    NotificationController *notifyController = [self.storyboard instantiateViewControllerWithIdentifier:@"notifyController"];
    [self presentViewController:notifyController animated:YES completion:nil];
}

-(void) showProfile:(id)sender {
    
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    
    //  [self.navigationController pushViewController:userController animated:NO];
    
    //[userController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:userController animated:YES completion:nil];
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
    PFObject* styleObj = [object objectForKey:@"styleId"];
    // find a better way to query table
    if(userObj && styleObj) {
        PFObject* styleInfo = [StyleItems getStyleForId:styleObj.objectId];
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