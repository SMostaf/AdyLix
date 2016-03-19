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
#import "style.h"
#import <CoreLocation/CoreLocation.h>

#define ASSERT_EQUAL(expr, val) do { int ret = expr; if (ret != val) printf("Line %d failed: 0x%x\n", __LINE__, ret); } while (0)
#define ASSERT_SUCCESS(expr) ASSERT_EQUAL(expr, success)

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

// should return empty
// setting current location to somewhere in London
- (void) testFailNearbyRange {
//    PFQuery* userQuery = [PFUser query];
//    // tester user
//    [userQuery whereKey:@"objectId" equalTo:@"fLBuO0FmQa"];
//    PFUser* tester = [userQuery getFirstObject];
    CLLocation* londonLocation = [[CLLocation alloc] initWithLatitude:[@"54.977614" doubleValue] longitude:[@"-1.933594" doubleValue]];
    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation: londonLocation];
//    [tester setObject:geoPoint forKey:@"currentLocation"];
//  //  [tester saveInBackground];

    PFUser* user = [PFUser user];
    user.username = @"testerLoc";
    user.password = @"1234";
    user.email = @"tester@gmail.com";
    [user setObject:geoPoint forKey:@"currentLocation"];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
        // get current location
        PFGeoPoint* currGeoPoint = [PFGeoPoint geoPointWithLocation: self.locationManager.location];
        PFQuery *currUser = [PFUser query];
        CGFloat mile = 0.5f;
        [currUser whereKey:@"currentLocation" nearGeoPoint:currGeoPoint withinMiles:(double)mile];
        
        XCTAssertEqual([[currUser findObjects] count], 0, @"No nearby item");
        }
    }];
}

//- (void) testNearbyRange {
//    
//  //  self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
//    // get a user in current location
//    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation: self.locationManager.location];
//    [self.userSelling setValue:geoPoint forKey:@"currentLocation"];
//    [self.userSelling save];
//   
//    [self.userBuying setValue:geoPoint forKey:@"currentLocation"];
//    [self.userBuying save];
// 
//    PFQuery *usersQuery = [PFUser query];
//    CGFloat km = 1.0f;
//    [usersQuery whereKey:@"currentLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude] withinKilometers:(double)km];
//    [usersQuery whereKey: @"objectId" notEqualTo: [self.userSelling valueForKey:@"objectId"]];
//    
//    
//    NSArray* arrUsers = [usersQuery findObjects];
//    
//    XCTAssertGreaterThanOrEqual([arrUsers count], 0, @"Found nearby item");
//}

-(void) testStyleSave {
    
   // ItemInfo* info = [[ItemInfo alloc]init];
    // fill stub
    
    PFObject *item = [PFObject objectWithClassName:@"StyleMaster"];
//    [item setObject:[PFUser currentUser] forKey:@"userId"];
//    [item setObject:info.desc forKey:@"description"];
//    [item setObject:info.name forKey:@"name"];
//    [item setObject:info.imageData forKey:@"imageFile"];
    
    [item saveInBackground];
    
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
#pragma mark - fixtures


// for testing: adding fixtures to db
+(void) addObjForTest {
    // for testing
    PFObject* style = [StyleItems getStyleForId:@"ipkTFPi5MF"];
    [style setValue: [PFUser currentUser]  forKey:@"userId"];
    [style save];
    
    PFObject* style2 = [StyleItems getStyleForId:@"A2p2VL6uuX"];
    [style2 setValue: [PFUser currentUser]  forKey:@"userId"];
    [style2 save];
    
    PFObject* style3 = [StyleItems getStyleForId:@"zY3vC5tHRq"];
    [style3 setValue: [PFUser currentUser]  forKey:@"userId"];
    [style3 save];
    
    
    PFObject* item = [Item getItemForId:@"Q9gipHOurW"];
    [item setValue: style forKey:@"styleId"];
    [item save];
    
    
    PFObject* item1 = [Item getItemForId:@"0rnHgmoc6U"];
    [item1 setValue: style forKey:@"styleId"];
    [item1 save];
    
    
    PFObject* item3 = [Item getItemForId:@"4rjRYicxMt"];
    [item3 setValue: style2 forKey:@"styleId"];
    [item3 save];
    
    [[PFUser currentUser] setObject:style forKey:@"currentStyleId"];
    [[PFUser currentUser] save];
    
    
}
@end
