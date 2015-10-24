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

@interface LocateController ()
@property (weak, nonatomic) IBOutlet UITableView *itemsTblView;
@property  (nonatomic, strong) CLLocationManager* locationManager;
@property PFGeoPoint* geoPoint;
@property UIImageView *activityImageView;
@property (assign, nonatomic) NSTimeInterval timeout;
@end

@implementation LocateController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.timeout = 10.0;
   
    UIImage *firstImage = [UIImage imageNamed:@"hat.png"];
    _activityImageView = [[UIImageView alloc]
                                      initWithImage:firstImage];
    
    
    //Add more images which will be used for the animation
    _activityImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"Icon@2x rot2.png"],
                                         [UIImage imageNamed:@"Icon@2x rot3.png"],
                                         [UIImage imageNamed:@"Icon@2x copy.png"],
                                         nil];
    
    
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
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
    
    // update current user location
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [_activityImageView stopAnimating];
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            self.geoPoint = geoPoint;
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            
            [self getNearbyItems];
        }
    }];
    

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
     
        [self getNearbyItems];
    }
}

-(void) getNearbyItems {
    
    // get users nearby
    PFGeoPoint *userGeoPoint = self.geoPoint;
    // Create a query for places
    PFQuery *usersQuery = [PFQuery queryWithClassName:@"User"];
    // Interested in locations near user.
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:userGeoPoint];
    // Limit what could be a lot of points.
    usersQuery.limit = 50;
    
    // query nearby users and find their items
    PFQuery *query = [PFQuery queryWithClassName:@"ItemDetail"];
    [query whereKey:@"userId" containedIn:[usersQuery findObjects]];
    //[query orderByDescending:@"createdAt"];
    
    NSArray* arrItemsFound = [query findObjects];
    if(arrItemsFound.count == 0)
    {
        
        return;
    }

}

@end