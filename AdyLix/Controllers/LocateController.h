//
//  LocateController.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef LocateController_h
#define LocateController_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface StyleDetail : NSObject
@property NSArray* items;
@property NSInteger currentItemIndex;
@end
    
@interface LocateController : UIViewController<CLLocationManagerDelegate, UITableViewDelegate>


@end


#endif /* LocateController_h */
