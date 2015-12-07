//
//  LocateController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import <Addressbook/ABPerson.h>
#import "LocateController.h"
#import "Parse/Parse.h"
#import "Parse/PFImageView.h"
#import "ItemInfo.h"
#import "ItemCell.h"
#import "PaymentHandler.h"
#import "SenderController.h"
#import "User.h"
#import "Item.h"
#import "Stripe/Stripe.h"

#define MERCHANTID @"merchant.com.adylix"
#define DESC_CUSTOM_TAG 1445

@interface LocateController ()
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property  (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, copy) NSArray* itemsArray;
@property UIImageView *activityImageView;
@property BOOL alertShown;
@end

@implementation LocateController


- (void)viewDidAppear:(BOOL)animated
{
    self.itemsArray = [[NSArray alloc]init];
    [self.itemsTableView reloadData];
     UIImage *firstImage = [UIImage imageNamed:@"hat.png"];
     _activityImageView = [[UIImageView alloc]
                          initWithImage:firstImage];
    
    
     //Add more images which will be used for the animation
     _activityImageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"Icon@2x rot2.png"],
                                          [UIImage imageNamed:@"Icon@2x rot3.png"],
                                          [UIImage imageNamed:@"Icon@2x copy.png"],
                                          nil];
    
    
    _activityImageView.animationDuration = 0.8;
    
    
    //Position the activity image view somewhere in
    //the middle of your current view
    _activityImageView.frame = CGRectMake(
                                          self.view.frame.size.width/2
                                          -firstImage.size.width/2,
                                          self.view.frame.size.height/2
                                          -firstImage.size.height/2,
                                          firstImage.size.width,
                                          firstImage.size.height);
    
    [self.view addSubview:_activityImageView];
    
    [_activityImageView startAnimating];
    
    [self startStandardUpdates];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    


 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [_locationManager stopUpdatingLocation];
}



- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 250; // meters
    
    _locationManager.allowsBackgroundLocationUpdates = YES;
    
    [_locationManager requestAlwaysAuthorization ];
    
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        // keep updating current user location
        PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation: location];
        [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
        [[PFUser currentUser] saveInBackground];

        [self getNearbyItems: location];
    }
}

-(void) shareBlock {
      // add default item to be added
      NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
      ItemInfo *item = [[ItemInfo alloc] init];
      item.name = @"unknown-default";
      
      [items addObject:item];
      
      self.itemsArray = items;
      
      [self.itemsTableView reloadData];
      
      // no items nearby
      // show share action
      [_activityImageView stopAnimating];
      _activityImageView.hidden = YES;
      
      [self.locationManager stopUpdatingLocation];
      
      if(!self.alertShown)
      {
          self.alertShown = true;
          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Items found", nil) message:NSLocalizedString(@"Share our App to spread the word", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
          
          
          NSString *textToShare = @"AdyLix is a cool App helps you locate your interest in the street, check it out!";
          NSURL *website = [NSURL URLWithString:@"http://www.adylix.com/"];
          
          NSArray *objectsToShare = @[textToShare, website];
          
          UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
          
          NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                         UIActivityTypePrint,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo];
          
          activityController.excludedActivityTypes = excludeActivities;
          
          
          [self presentViewController:activityController animated:YES completion:nil];
      }
}

-(void) getNearbyItems:(CLLocation*) location {
    // query db for nearby items
    NSArray* arrItemsFound = [Item getItemsNearby:location];
    if(arrItemsFound.count == 0)
    {
        // no items found, ask user to share adylix link
        [self shareBlock];
        return;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:arrItemsFound.count];
    for(NSDictionary *itemsInfo in arrItemsFound) {
        
        ItemInfo *item = [[ItemInfo alloc] init];
        item.objectId = [itemsInfo valueForKey:@"objectId"];
        item.userObjectId = itemsInfo[@"userObjectId"];
        item.name = itemsInfo[@"name"];
        item.desc = itemsInfo[@"description"];
        item.price = itemsInfo[@"price"];
        item.imageData = itemsInfo[@"imageFile"];
        
        
        [items addObject:item];
    }

    self.itemsArray = items;
   [self.itemsTableView reloadData];

    [_activityImageView stopAnimating];
    _activityImageView.hidden = YES;

}
// --------------------------------------------- table view handlers -------------------------------------- //
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemTableIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }
    
    [[cell.contentView viewWithTag:DESC_CUSTOM_TAG]removeFromSuperview] ;
    // Configure the cell
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
    nameLabel.text = @"";
    
    UILabel *priceLabel = (UILabel*) [cell viewWithTag:101];
    priceLabel.text = @"";
    
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
    
    CGRect contentRect = CGRectMake(priceLabel.frame.origin.x, priceLabel.frame.origin.y + 45, 240, 40);
    UILabel *descLabel = [[UILabel alloc] initWithFrame:contentRect];
    [descLabel removeFromSuperview];
    descLabel.tag = DESC_CUSTOM_TAG;
    descLabel.text = @"";
    descLabel.numberOfLines = 2;
    descLabel.textColor = [UIColor darkGrayColor];
    descLabel.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:descLabel];
    
    ItemInfo *itemFound = self.itemsArray[indexPath.row];
    if(itemFound.name == @"unknown-default")
    {
        // show hat by default when no items discovered
        nameLabel.text = @"The Hat";
        descLabel.text  = @"Items discovered nearby will appear here, spread the word!";
        priceLabel.text = @"$$";
        
        UIImage *img = [UIImage imageNamed:@"Icon-40@2x.png"];
        NSData *data = UIImagePNGRepresentation(img);
        thumbnailImageView.image = [UIImage imageWithData:data];
    }
    else {
        nameLabel.text = itemFound.name;

        descLabel.text = itemFound.desc;
        
        priceLabel.text = [NSString stringWithFormat:@"%@%@", @"$", itemFound.price];

        PFFile *thumbnail = itemFound.imageData;

        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(!error)
                thumbnailImageView.image = [UIImage imageWithData:data];
        }];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemsArray count];
}

// -------------------------------------- push notify flow -------------------------------------------- //
- (IBAction)btnLike:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.itemsTableView];
    NSIndexPath *indexPath = [self.itemsTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        ItemInfo *itemFound = self.itemsArray[indexPath.row];
        NSString* userId = itemFound.userObjectId;
        NSString* itemId = itemFound.objectId;
        
        Item* item = [[Item alloc] init];
        [item like:itemId ownerId:userId];
    }
   
}
// -------------------------------------- payment flow ----------------------------------------------- //
#ifdef PAY
-(void) handleResponse:(bool) success {
    
    if(!success)
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, Payment failed...try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Thank you for your payment", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

}

- (IBAction)btnPurchase:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.itemsTableView];
    NSIndexPath *indexPath = [self.itemsTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        ItemInfo *itemFound = self.itemsArray[indexPath.row];
        NSString* userId = itemFound.userObjectId;
        // get price of item
        NSString *price = itemFound.price;
        if (!userId || !price)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Item not available for Purchase", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];

            return;
        }
        // get the recepient who owns this item
        User* userQuery = [[User alloc]init];
        PFUser* recepient= [userQuery getUserForId: userId];
        // get token for recepient
        NSString* recepientId = [recepient valueForKey:@"tokenId"];
        if(!recepientId) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Item not available for Purchase", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            
            return;
        }

        // show payment forms
        User* userInfo = [[User alloc] init];
        NSString* tokenId = [userInfo getTokenId];
        // user have a token already
        if (tokenId != nil)
        {
            [PaymentHandler submitPayment:price tokenId: tokenId bankId: recepientId completion:^void(bool success)        {
              [self handleResponse: success];
            }];
            
        } else
        {
        
             SenderController* payController = [[SenderController alloc] init];
             payController.price = price;
             payController.recepientId = recepientId;
             payController.itemId = itemFound.objectId;
             [self.navigationController pushViewController:payController animated:NO];
        }
    }
}
#endif

@end