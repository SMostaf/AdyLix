//
//  itemTableViewController.m
//  AdyLix
//  Controller to list all items owned by user
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ParseUI/PFImageView.h>
#import "ItemTableViewController.h"
#import "Style.h"
#import "UserController.h"
#import "ItemsController.h"

//#define DESC_CUSTOM_TAG 1444

@interface ItemTableViewController()
@property (strong, nonatomic) IBOutlet UITableView *tblview;

@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property BOOL isLoaded;
@end

typedef enum {
    NameLabelTag = 100,
    PriceLabelTag = 101,
    ThumbnailTag = 103,
    LikeCountTag = 104,
    IDTag = 105,
    CustomeTag = 1444
} ItemTagID;


@implementation ItemTableViewController

-(void) showProfile:(id)sender {
    
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    
    //  [self.navigationController pushViewController:userController animated:NO];
    
    //[userController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentModalViewController:userController animated:YES];
}

-(void) showSelfie:(id)sender{
    ItemsController* snapController = [self.storyboard instantiateViewControllerWithIdentifier:@"itemController"];
    [self presentViewController:snapController animated:YES completion:NULL];
}

-(void) viewDidLoad {
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated
{
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -50, 380, 40)];
    navbar.backgroundColor = [UIColor redColor];
    
    UIImage* imageMain = [UIImage imageNamed:@"menu.png"];
    CGRect frameimg = CGRectMake(0, 0, imageMain.size.width, imageMain.size.height);
    UIButton *imgButton = [[UIButton alloc] initWithFrame:frameimg];
    [imgButton setBackgroundImage:imageMain forState:UIControlStateNormal];
    [imgButton addTarget:self action:@selector(showProfile:)
        forControlEvents:UIControlEventTouchUpInside];
    [imgButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithCustomView:imgButton];
    navigationItem.leftBarButtonItem = menuButton;

    
    UIImage* imageSnap = [UIImage imageNamed:@"camera.png"];
    CGRect snapFrameimg = CGRectMake(0, 0, imageSnap.size.width, imageSnap.size.height);
    UIButton *imgSnapButton = [[UIButton alloc] initWithFrame:snapFrameimg];
    [imgSnapButton setBackgroundImage:imageSnap forState:UIControlStateNormal];
    [imgSnapButton addTarget:self action:@selector(showSelfie:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgSnapButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *snapButton =[[UIBarButtonItem alloc] initWithCustomView:imgSnapButton];
    navigationItem.rightBarButtonItem = snapButton;
    
    
    navbar.items = @[navigationItem];
    
    [self.view addSubview:navbar];
    
    self.tblView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
    

   [self loadObjects];
    
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"StyleMaster";
        
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
        [query whereKey:@"userId" equalTo:[PFUser currentUser]];


        // If no objects are loaded in memory, we look to the cache
        // first to fill the table and then subsequently do a query
        // against the network.
        if ([self.objects count] == 0) {
            query.cachePolicy = kPFCachePolicyNetworkElseCache;//kPFCachePolicyCacheThenNetwork;
        }

        [query orderByDescending:@"createdAt"];

    }
     return query;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    if(editing)
    {
        NSLog(@"editMode on");
    }
    else
    {
        NSLog(@"Done leave editmode");
    }
    
    [super setEditing:editing animated:animate];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *itemTableIdentifier = @"ItemCell";
    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }
    
    //[[cell.contentView viewWithTag:CustomeTag]removeFromSuperview];
    
    // Configure the cell
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:NameLabelTag];
    nameLabel.text = [object objectForKey:@"name"];
 
    UILabel *idLabel = (UILabel*) [cell viewWithTag:IDTag];
    idLabel.text = object.objectId;
    idLabel.hidden = YES;
 
    
    PFFile *thumbnail = [object objectForKey:@"imageFile"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:ThumbnailTag];
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    thumbnailImageView.image = [UIImage imageWithData:data];
    }];

    unsigned long countLikes = [StyleItems getLikesForStyle: [object valueForKey:@"objectId"]];
    if (countLikes > 0)
    {
        UILabel *likeLabel = (UILabel*) [cell viewWithTag:LikeCountTag];
        likeLabel.text = [NSString stringWithFormat:@"%lu%@", countLikes, @" Likes"];
    }
  
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
}
- (IBAction)btnRowEdit:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UITableViewCell *cell = [self.tblView cellForRowAtIndexPath:indexPath];
    NSString *objectId = ((UILabel*)([cell viewWithTag:IDTag])).text;
    

    ItemsController *itemController = [self.storyboard instantiateViewControllerWithIdentifier:@"itemController"];
    itemController.editStyleId = objectId;
    
    [self presentViewController:itemController animated: YES completion:nil];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Editing");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self loadObjects];
        }];
    }
}

@end
