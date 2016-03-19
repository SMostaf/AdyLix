//
//  itemTableViewController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LocateTableViewController.h"
#import "ItemCell.h"
#import "PaymentHandler.h"
#import "User.h"

@interface LocateTableViewController()
@end

@implementation LocateTableViewController


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"ItemDetail";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 15;
    }

    // query other users location
    PFQuery *Location = [PFUser query];
    [Location   selectKeys:@[@"currentLocation",]];
    [Location findObjectsInBackgroundWithBlock:^(NSArray *location, NSError *error)
     {
         // query users near location
         // with isdiscoverable set to true
         
         //Coordinaten = location;
         
     }];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell to show todo item with a priority at the bottom
    cell.textLabel.text = [object objectForKey:@"name"];
    cell.detailTextLabel.text = [object objectForKey:@"price"];
    cell.imageView.image = [object objectForKey:@"imageData"];
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ItemCell *cell = (ItemCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Cell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (ItemCell *)currentObject;
                break;
            }
        }
    }
    // Configure the cell.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //set the position of the button
    button.frame = CGRectMake(cell.frame.origin.x + 100, cell.frame.origin.y + 20, 100, 30);
    [button setTitle:@"purchase" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnPurchase:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor= [UIColor clearColor];
    [cell.contentView addSubview:button];
    
    return cell;
}


-(void)btnPurchase :(id)sender
{
   // show random message
   /* NSArray *array = [NSArray arrayWithObjects: @"Purchase feature not available", @"The CEO is working on this feature herself!", @"This feature is going to be awesome!", @"Patience, feature coming soon", nil];
    int random = arc4random()%[array count];
    NSString *key = [array objectAtIndex:random];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Coming Soon", nil) message:NSLocalizedString(key, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    */
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        ItemCell *selectedCell = (ItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSString* itemId =
        User* userQuery = [[User alloc]init];
        PFUser* recepient= [userQuery getUserForItem: itemId];
        NSString *price = selectedCell.detailTextLabel.text;
    
        PaymentHandler* payHandler = [[PaymentHandler alloc] init];
 
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:price];
    
        [payHandler pay: amount completion: ^(bool success){
            if(!success)
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, Payment failed...try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            else
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Thank you for your payment", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

        }];
    }
}


@end
