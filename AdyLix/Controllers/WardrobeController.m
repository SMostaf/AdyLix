//
//  WardrobeController.m
//  AdyLix
//  Controller to list all items owned by user
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ParseUI/PFImageView.h>
#import "WardrobeController.h"
#import "UserController.h"
#import "RegisterController.h"
#import "NotificationController.h"
#import "LocateController.h"
#import "Style.h"
#import "Utility.h"

//#define DESC_CUSTOM_TAG 1444

@interface WardrobeController()

//@property (strong, nonatomic) IBOutlet UITableView *tblview;

@property (strong, nonatomic) IBOutlet UITableView *tblView;

@property BOOL loaded;
@end

typedef enum {
    NameLabelTag = 100,
    PriceLabelTag = 101,
    ThumbnailTag = 103,
    LikeCountTag = 104,
    IDTag = 105,
    CustomeTag = 1444
} ItemTagID;


@implementation WardrobeController

-(void) showLocater:(id)sender {

  [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void) showWardrobe:(id)sender {

}

-(void) showNotify:(id)sender {
    
    NSArray * controllerArray = [[self navigationController] viewControllers];
    // if controller already on stack, pop 
    for (UIViewController *controller in controllerArray) {
        if ([NSStringFromClass([controller class]) isEqualToString:@"NotificationController"]) {
            [self.navigationController popToViewController:controller animated:NO];
            return;
        }
    }
    // not on stack, push
    NotificationController *notifyController = [self.storyboard instantiateViewControllerWithIdentifier:@"notifyController"];

    [self.navigationController pushViewController:notifyController animated:NO];
}

-(void) showProfile:(id)sender {
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    //[self presentViewController:userController animated:NO completion:nil];
    [self.navigationController pushViewController:userController animated:NO];
}


-(void) viewDidLoad {
    [super viewDidLoad];
    self.tblView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

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

- (void) viewWillDisappear:(BOOL)animated
{
    // make sure back menu item does not appear
    // self.navigationController.navigationBar.hidden = true;
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
        likeLabel.text = [NSString stringWithFormat:@"%lu %@%@", countLikes, @"Aww", (countLikes > 1) ? @"s" : @""];
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Editing");
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        PFObject *object = [self.objects objectAtIndex:indexPath.row];
//        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            [self loadObjects];
//        }];
//    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        PFObject *object = [self.objects objectAtIndex:indexPath.row];
                                        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            [self loadObjects];
                                        }];
                                    }];
    delete.backgroundColor = [UIColor redColor];
    
    
    UITableViewRowAction *edit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@" Update " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                  {
                                      UITableViewCell *cell = [self.tblView cellForRowAtIndexPath:indexPath];
                                      NSString *objectId = ((UILabel*)([cell viewWithTag:IDTag])).text;
                                      
                                      
                                      RegisterController *itemController = [self.storyboard instantiateViewControllerWithIdentifier:@"registerController"];
                                      itemController.editStyleId = objectId;
                                      
                                      [self presentViewController:itemController animated: YES completion:nil];
                                      
                                      
                                  }];

    edit.backgroundColor = [UIColor colorWithRed:0.188 green:0.514 blue:0.984 alpha:1];
    
    return @[delete, edit]; //array with all the buttons you want. 1,2,3, etc...
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 1;
    if ([self.objects count])
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        self.tblView.backgroundView   = nil;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tblView.bounds.size.width, self.tblView.bounds.size.height)];
        noDataLabel.text             = @"No style added";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tblView.backgroundView = noDataLabel;
        self.tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numOfSections;
}
@end
