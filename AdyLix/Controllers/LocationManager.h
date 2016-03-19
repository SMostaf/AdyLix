//
//  LocationManager.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef LocationManager_h
#define LocationManager_h

#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

-(void) onReceiveLocationError:(NSError* __nullable) err;
-(void) onReceiveLocationUpdate:(CLLocation*) location;

@end

@interface LocationManager : NSObject<CLLocationManagerDelegate>
-(void) startUpdatingLocation;
-(void) stopUpdatingLocation;
@property(assign, nonatomic, nullable) id<LocationManagerDelegate> delegate;
@end


#endif /* LocationManager_h */
