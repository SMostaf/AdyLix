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

@interface ItemTableViewController()
@end

@implementation ItemTableViewController

//-(void)viewDidLoad {
//    self.parseClassName = @"ItemDetail";
//    self.pullToRefreshEnabled = YES;
//    self.paginationEnabled = YES;
//    self.objectsPerPage = 15;
//
//}
//- (id)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:style];
//    if (self) {
//        // This table displays items in the Todo class
//        self.parseClassName = @"ItemDetail";
//        self.pullToRefreshEnabled = YES;
//        self.paginationEnabled = NO;
//        self.objectsPerPage = 25;
//    }
//    return self;
//}

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
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath
//                        object:(PFObject *)object {
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
//                                      reuseIdentifier:CellIdentifier];
//    }
//    
//    // Configure the cell to show todo item with a priority at the bottom
//    cell.textLabel.text = [object objectForKey:@"name"];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", @"$", [object objectForKey:@"price"]];
//    PFFile *imageFile = [object objectForKey:@"imageFile"];
//    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            cell.imageView.image = [UIImage imageWithData:data];
//    }];
//     
//     return cell;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *itemTableIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }
    

    // Configure the cell
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
    nameLabel.text = [object objectForKey:@"name"];
    
    UILabel *descLabel = (UILabel*) [cell viewWithTag:102];
    descLabel.text = [object objectForKey:@"description"];
    
    UILabel *priceLabel = (UILabel*) [cell viewWithTag:101];
    priceLabel.text = [object objectForKey:@"price"];
    
//    
    PFFile *thumbnail = [object objectForKey:@"imageFile"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    thumbnailImageView.image = [UIImage imageWithData:data];
    }];

//    
//    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                cell.imageView.image = [UIImage imageWithData:data];
//        }];
    
    
//    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
//    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//         thumbnailImageView.file = thumbnail;
//    }];
    
//    thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
//    thumbnailImageView.file = thumbnail;
//    [thumbnailImageView loadInBackground];
    
    
    return cell;
}

@end
