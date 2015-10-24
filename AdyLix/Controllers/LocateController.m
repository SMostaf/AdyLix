//
//  LocateController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "LocateController.h"
#import "Parse/Parse.h"
#import "AdyLocationManager.h"
#include "ItemInfo.h"

@interface LocateController ()
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property  (nonatomic, strong) CLLocationManager* locationManager;
@property PFGeoPoint* geoPoint;
@property UIImageView *activityImageView;
@property (nonatomic, copy) NSArray* itemsArray;
@end

@implementation LocateController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    

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
   
//    // update current user location for others to discover my items
//    // #todo make sure this gets updated when user is on the move
//    // if that is the case no
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//            [_activityImageView stopAnimating];
//            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
//            self.geoPoint = geoPoint;
//            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
//            [[PFUser currentUser] saveInBackground];
//            
//            [self startStandardUpdates];
//            
//        }
//    }];
    

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
    
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
  
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
     
        [self getNearbyItems: location];
    }
}

-(void) getNearbyItems:(CLLocation*) location {
    
    void (^shareBlock)(void) = ^{
        // no items nearby
        // show share action
        [_activityImageView stopAnimating];
        [self.locationManager stopUpdatingLocation];
        
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

    };
    
    // #TODO: move to a class with completion block
    
    // get users nearby
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation: location];
    // Create a query for places
    //PFQuery *usersQuery = [PFQuery queryWithClassName:@"User"];
    PFQuery *usersQuery = [PFUser query];
    // Interested in locations near user
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:userGeoPoint];
    //[usersQuery whereKey:@"email" notEqualTo:[[PFUser currentUser] email]];
    [usersQuery whereKey: @"objectId" notEqualTo: [[PFUser currentUser] valueForKey:@"objectId"]];
    //[usersQuery orderByAscending:@"orderByAscending"];

    // Limit what could be a lot of points.
    usersQuery.limit = 100;
    
    NSArray* arrUsers = [usersQuery findObjects];
    // no users nearby
    if(arrUsers.count == 0)
    {
        shareBlock();
        return;
    }

    // query nearby users and find their items
    PFQuery *query = [PFQuery queryWithClassName:@"ItemDetail"];
    NSMutableArray *arrUsersItems=[[NSMutableArray alloc]init];
    for (PFObject *object in arrUsers) {
        [arrUsersItems addObject:[object objectId]];
    }
    [query whereKey:@"userObjectId" containedIn:arrUsersItems];
    //[query orderByDescending:@"createdAt"];
    NSArray* arrItemsFound = [query findObjects];
    if(arrItemsFound.count == 0)
    {
        shareBlock();
        return;
    }
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:arrItemsFound.count];
    for(NSDictionary *itemsInfo in arrItemsFound) {
        
        ItemInfo *item = [[ItemInfo alloc] init];
        item.name = itemsInfo[@"name"];
        item.desc = itemsInfo[@"description"];
        item.price = itemsInfo[@"price"];
        item.imageData = itemsInfo[@"imageFile"];
        
        
        [items addObject:item];
    }
    self.itemsArray = items;
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.itemsTableView reloadData];
    });
    
    
    [_activityImageView stopAnimating];
    _activityImageView.hidden = YES;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemTableIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }
    ItemInfo *item = self.itemsArray[indexPath.row];
    
    // Configure the cell
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
    nameLabel.text = item.name;
    
    UILabel *descLabel = (UILabel*) [cell viewWithTag:102];
    descLabel.text = item.desc;
    
    UILabel *priceLabel = (UILabel*) [cell viewWithTag:101];
    priceLabel.text = [NSString stringWithFormat:@"%@%@", @"$", item.price];
    
    PFFile *thumbnail = item.imageData;
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        thumbnailImageView.image = [UIImage imageWithData:data];
    }];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.itemsArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio
{
    return 1;
}


- (IBAction)btnPurchase:(id)sender {
    // show random message
    NSArray *array = [NSArray arrayWithObjects: @"Purchase feature not available", @"The CEO is working on this feature herself!", @"This feature is going to be awesome!", @"Patience, feature coming soon!", @"We are glad you are interested in this feature, coming soon...", nil];
    int random = arc4random()%[array count];
    NSString *key = [array objectAtIndex:random];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Coming Soon", nil) message:NSLocalizedString(key, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

@end