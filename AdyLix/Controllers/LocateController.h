//
//  LocateController.h
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#ifndef LocateController_h
#define LocateController_h

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface LocateController : BaseViewController<CLLocationManagerDelegate, UITableViewDelegate>


@end


#endif /* LocateController_h */
