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
#import "Parse/Parse.h"
#import "MainController.h"
#import "User.h"
#import "Style.h"


typedef enum {
    DecLabelTag = 100,
    ThumbnailTag = 101,
    CustomeTag = 102
} NotifyTagID;


@interface NotificationController ()


@end

@implementation NotificationController

- (void)viewDidLoad {
   
    [super viewDidLoad];
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

    PFUser* userObj = [object objectForKey:@"userFrom"];
    PFObject* styleObj = [object objectForKey:@"styleId"];
    if(userObj && styleObj) {
        PFObject* styleInfo = [StyleItems getStyleForId:styleObj.objectId];
        PFQuery* userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:userObj.objectId];
        PFObject* userInfo = [userQuery getFirstObject];
        NSString* userName = [userInfo valueForKey:@"username"];
        NSString* styleName = [styleInfo valueForKey:@"name"];
        // User name liked your name style
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@%@", userName, @" likes your ", styleName, @" style"];
    }
    
    // [[cell.contentView viewWithTag:CustomeTag]removeFromSuperview];
    
//    CGRect contentRect = CGRectMake(priceLabel.frame.origin.x, priceLabel.frame.origin.y + 45, 240, 40);
//    UILabel *descLabel = [[UILabel alloc] initWithFrame:contentRect];
//    descLabel.tag = CustomeTag;
//    descLabel.numberOfLines = 2;
//    descLabel.textColor = [UIColor darkGrayColor];
//    descLabel.font = [UIFont systemFontOfSize:12];
//    descLabel.text = [object objectForKey:@"description"];
//    [cell.contentView addSubview:descLabel];
    
    
//    PFFile *thumbnail = [object objectForKey:@"imageFile"];
//    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:ThumbnailTag];
//    
//    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        thumbnailImageView.image = [UIImage imageWithData:data];
//    }];
    
//    Item* item = [[Item alloc] init];
//    unsigned long countLikes = [item getLikesForItem: [object valueForKey:@"objectId"]];
//    if (countLikes > 0)
//    {
//        UILabel *likeLabel = (UILabel*) [cell viewWithTag:LikeCountTag];
//        likeLabel.text = [NSString stringWithFormat:@"%d%@", countLikes, @" Likes"];
//    }
    
    return cell;
}




@end