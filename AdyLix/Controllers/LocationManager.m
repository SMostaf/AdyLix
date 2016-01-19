//
//  LocationManager.m
//  Ady
//
//  LocationManager registers for CLLocationManager location events
//  Finds nearby styles
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "LocationManager.h"
#import "Parse/Parse.h"
#import "User.h"
#import "Style.h"

@interface LocationManager ()
@property  (nonatomic, strong) CLLocationManager* clLocationManager;
@end

@implementation LocationManager

-(id) init {
    self = [super init];
    if (self) {
        // Create the location manager if this object does not
        // already have one.
        if (nil == _clLocationManager)
            _clLocationManager = [[CLLocationManager alloc] init];

        _clLocationManager.delegate = self;

        _clLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

        // Set a movement threshold for new events.
        _clLocationManager.distanceFilter = 250; // meters

        _clLocationManager.allowsBackgroundLocationUpdates = YES;

        [_clLocationManager requestAlwaysAuthorization ];

        [self startUpdatingLocation];
    }
    return self;
}

-(void) startUpdatingLocation {
    [_clLocationManager startUpdatingLocation];
}

-(void) stopUpdatingLocation {
    
    [_clLocationManager stopUpdatingLocation];
}

#pragma mark - location manager delegate

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
   [self.delegate onReceiveLocationError:error];
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval recentTime = [eventDate timeIntervalSinceNow];
    
    if (abs(recentTime) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        // keep updating current user location
        [User saveLocation: location];
        // query for nearby styles
        [self.delegate onReceiveLocationUpdate: location];
        
    }
}




@end