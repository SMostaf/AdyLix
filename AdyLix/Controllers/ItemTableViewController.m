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
@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property BOOL isLoaded;
@end

typedef enum {
    NameLabelTag = 100,
    PriceLabelTag = 101,
    ThumbnailTag = 103,
    LikeCountTag = 104,
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

- (void) viewDidAppear:(BOOL)animated
{
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *itemTableIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }
    
    [[cell.contentView viewWithTag:CustomeTag]removeFromSuperview];
    // Configure the cell
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:NameLabelTag];
    nameLabel.text = [object objectForKey:@"name"];
    
//    UILabel *priceLabel = (UILabel*) [cell viewWithTag:PriceLabelTag];
//    priceLabel.text = [NSString stringWithFormat:@"%@%@", @"$", [object objectForKey:@"price"]];

    //UILabel *descLabel = (UILabel*) [cell viewWithTag:102];
//    CGRect contentRect = CGRectMake(priceLabel.frame.origin.x, priceLabel.frame.origin.y + 45, 240, 40);
//    UILabel *descLabel = [[UILabel alloc] initWithFrame:contentRect];
//    descLabel.tag = CustomeTag;
//    descLabel.numberOfLines = 2;
//    descLabel.textColor = [UIColor darkGrayColor];
//    descLabel.font = [UIFont systemFontOfSize:12];
//    descLabel.text = [object objectForKey:@"description"];
//    [cell.contentView addSubview:descLabel];

    
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
