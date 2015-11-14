//
//  itemTableViewController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemTableViewController.h"
#import "Item.h"

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


- (void) viewDidAppear:(BOOL)animated
{
  [self loadObjects];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"ItemDetail";
        
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
        [query whereKey:@"userObjectId" equalTo:[[PFUser currentUser]
                                                valueForKey:@"objectId"]];


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
    
    UILabel *priceLabel = (UILabel*) [cell viewWithTag:PriceLabelTag];
    priceLabel.text = [NSString stringWithFormat:@"%@%@", @"$", [object objectForKey:@"price"]];

    //UILabel *descLabel = (UILabel*) [cell viewWithTag:102];
    CGRect contentRect = CGRectMake(priceLabel.frame.origin.x, priceLabel.frame.origin.y + 25, 240, 40);
    UILabel *descLabel = [[UILabel alloc] initWithFrame:contentRect];
    descLabel.tag = CustomeTag;
    descLabel.numberOfLines = 2;
    descLabel.textColor = [UIColor darkGrayColor];
    descLabel.font = [UIFont systemFontOfSize:12];
    descLabel.text = [object objectForKey:@"description"];
    [cell.contentView addSubview:descLabel];

    
    PFFile *thumbnail = [object objectForKey:@"imageFile"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:ThumbnailTag];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    thumbnailImageView.image = [UIImage imageWithData:data];
    }];

    Item* item = [[Item alloc] init];
    unsigned long countLikes = [item getLikesForItem: [object valueForKey:@"objectId"]];
    UILabel *likeLabel = (UILabel*) [cell viewWithTag:LikeCountTag];
    likeLabel.text = [NSString stringWithFormat:@"%@%@", @"Likes",  countLikes];


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
