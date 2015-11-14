//
//  AdyLixTests.m
//  AdyLixTests
//
//  Created by Sahar Mostafa on 10/18/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Parse/Parse.h"
#import "item.h"
#import <CoreLocation/CoreLocation.h>

@interface AdyLixTests : XCTestCase
@property PFUser* userSelling;
@property PFUser* userBuying;
@property (nonatomic,retain) CLLocationManager *locationManager;

@end

@implementation AdyLixTests

- (void)setUp {
    [super setUp];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
    
    self.userSelling = [[PFUser alloc]init];
    self.userBuying = [[PFUser alloc]init];
    
    [self.userSelling setObject:@"name" forKey:@"sellername"];
    [self.userSelling setObject:@"email" forKey:@"sellername@gmail.com"];
    [self.userSelling save];

    [self.userBuying setObject:@"name" forKey:@"buyername"];
    [self.userBuying setObject:@"email" forKey:@"buyername@gmail.com"];
    [self.userBuying save];

    // add items to user selling
    PFObject *item = [PFObject objectWithClassName:@"ItemDetail"];
    [item setObject:@"testItem" forKey:@"name"];
    [item setObject:@"10" forKey:@"price"];
    [item setObject:@"Item for testing" forKey:@"description"];

    [item setObject:[NSNumber numberWithBool:YES] forKey:@"isDiscoverable"];
    
    [item setObject:[NSDate date] forKey:@"timeStamp"];
    [item setObject:[self.userSelling valueForKey:@"objectId"] forKey:@"userObjectId"];
    // hard code loc
    // 45.54120033517996, -122.8795679380399
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testNearbyRange {
    
  //  self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    // get a user in current location
    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation: self.locationManager.location];
    [self.userSelling setValue:geoPoint forKey:@"currentLocation"];
    [self.userSelling save];
   
    [self.userBuying setValue:geoPoint forKey:@"currentLocation"];
    [self.userBuying save];
 
    PFQuery *usersQuery = [PFUser query];
    CGFloat km = 1.0f;
    [usersQuery whereKey:@"currentLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude] withinKilometers:(double)km];
    [usersQuery whereKey: @"objectId" notEqualTo: [self.userSelling valueForKey:@"objectId"]];
    
    
    NSArray* arrUsers = [usersQuery findObjects];
    
    XCTAssertGreaterThanOrEqual([arrUsers count], 0, @"Found nearby item");
}

-(void) testItemLike {
    
    Item* item = [[Item alloc] init];
    [item like:@"ZXkQlCQcIU"
       ownerId:@"c0Y1ueO3xU"];
    
    //  XCTAssertGreaterThanOrEqual([arrUsers count], 0, @"Found nearby item");
    
}

- (void)testExample {
    // XCTAssertEqual(matchCount, 0, @"No matches, right?");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
