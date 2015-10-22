//
//  LocateController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "LocateController.h"
#import <CoreLocation/CoreLocation.h>
#import "ActivityIndicator.h"

@interface LocateController ()
@property (weak, nonatomic) IBOutlet UITableView *itemsTblView;
@property CLLocationManager* locationManager;
@end

@implementation LocateController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    ActivityIndicator *activityIndicator = [[ActivityIndicator alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    
    [self.view addSubview:activityIndicator];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    _locationManager.distanceFilter = 500; // meters
    
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        // query nearby items
//        Connector* connHandler = [Connector getConnector];
//        [connHandler setUIDelegate:self];
//        [connHandler getNearby: location.coordinate.longitude lat:location.coordinate.latitude];
        
    }
}

-(void) receiveStatus:(NSNumber*) state
{
   // update UI
}
@end