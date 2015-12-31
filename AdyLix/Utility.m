//
//  Utility.m
//  AdyLix
//
//  Layer building UI items dynamically are used accross the controller views
//
//  Created by Sahar Mostafa on 12/24/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@implementation Utility

// function building the menu navigation for the profile view
// shows two icons: main menu + quick selfie button
+(UIBarButtonItem*) getNavForProfile:(id) obj {
 //   UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    
    UIImage* imageSnap = [UIImage imageNamed:@"camera.png"];
    CGRect snapFrameimg = CGRectMake(0, 0, imageSnap.size.width, imageSnap.size.height);
    UIButton *imgSnapButton = [[UIButton alloc] initWithFrame:snapFrameimg];
    [imgSnapButton setBackgroundImage:imageSnap forState:UIControlStateNormal];
    [imgSnapButton addTarget:obj action:@selector(showSelfie:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgSnapButton setShowsTouchWhenHighlighted:YES];

    UIBarButtonItem *snapButton =[[UIBarButtonItem alloc] initWithCustomView:imgSnapButton];
    return snapButton;
}

// function building the main menu navigation for all views except the profile
// shows four icons: main menu + wardrobe + disocvery + reel
// called from dscovery loacte menu
+(UINavigationItem*) getNavMainMenu:(id) obj {
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    NSMutableArray* selectedArr = [[NSMutableArray alloc] initWithObjects:@"wardrobe.png", @"discover.png", @"reel.png", nil];
    
    if ([NSStringFromClass([obj class]) isEqualToString: @"WardrobeController"])
        [selectedArr replaceObjectAtIndex:0 withObject:@"wardrobe-selected.png"];
    else if ([NSStringFromClass([obj class]) isEqualToString: @"LocateController"])
        [selectedArr replaceObjectAtIndex:1 withObject: @"discover-selected.png"];
    else if ([NSStringFromClass([obj class]) isEqualToString:@"NotificationController"])
        [selectedArr replaceObjectAtIndex:2 withObject:@"reel-selected.png"];
    
    // menu icon goes to profile
    UIImage* imageMain = [UIImage imageNamed:@"menu.png"];
    CGRect frameimg = CGRectMake(0, 0, imageMain.size.width, imageMain.size.height);
    UIButton *imgButton = [[UIButton alloc] initWithFrame:frameimg];
    [imgButton setBackgroundImage:imageMain forState:UIControlStateNormal];
    [imgButton addTarget:obj action:@selector(showProfile:)
        forControlEvents:UIControlEventTouchUpInside];
    [imgButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithCustomView:imgButton];
    
    // wardrobe menu shows styles owned by users
    UIImage* imageWardrobe = [UIImage imageNamed:[selectedArr objectAtIndex:0]];
    CGRect wardrobeFrameimg = CGRectMake(0, 0, imageWardrobe.size.width, imageWardrobe.size.height);
    UIButton *imgWardrobeButton = [[UIButton alloc] initWithFrame:wardrobeFrameimg];
    [imgWardrobeButton setBackgroundImage:imageWardrobe forState:UIControlStateNormal];
    [imgWardrobeButton addTarget:obj action:@selector(showWardrobe:)
                forControlEvents:UIControlEventTouchUpInside];
    [imgWardrobeButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *wardrobeButton =[[UIBarButtonItem alloc] initWithCustomView:imgWardrobeButton];
    
    // discovery icon shows locate view
    UIImage* imageMap = [UIImage imageNamed:[selectedArr objectAtIndex:1]];
    CGRect mapFrameimg = CGRectMake(0, 0, imageMap.size.width, imageMap.size.height);
    UIButton *imgMapButton = [[UIButton alloc] initWithFrame:mapFrameimg];
    [imgMapButton setBackgroundImage:imageMap forState:UIControlStateNormal];
    [imgMapButton addTarget:obj action:@selector(showLocater:)
           forControlEvents:UIControlEventTouchUpInside];
    [imgMapButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *mapButton =[[UIBarButtonItem alloc] initWithCustomView:imgMapButton];
    
    // reel icon shows notification
    UIImage* imageReel = [UIImage imageNamed:[selectedArr objectAtIndex:2]];
    CGRect reelFrameimg = CGRectMake(0, 0, imageReel.size.width, imageReel.size.height);
    UIButton *imgReelButton = [[UIButton alloc] initWithFrame:reelFrameimg];
    [imgReelButton setBackgroundImage:imageReel forState:UIControlStateNormal];
    [imgReelButton addTarget:obj action:@selector(showNotify:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgReelButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *reelButton =[[UIBarButtonItem alloc] initWithCustomView:imgReelButton];
    
    // space button
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 70;
    
    //navigationItem.rightBarButtonItems = @[reelButton];
    
    navigationItem.leftBarButtonItems = @[menuButton, fixedSpaceBarButtonItem, wardrobeButton, fixedSpaceBarButtonItem, mapButton, fixedSpaceBarButtonItem, reelButton];
    
    return navigationItem;

}
// called from notify or wardrobe menus
+(NSArray<UIBarButtonItem*> *) getNavOtherMenu:(id) obj {

    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    NSMutableArray* selectedArr = [[NSMutableArray alloc] initWithObjects:@"wardrobe.png", @"discover.png", @"reel.png", nil];
  
    if ([NSStringFromClass([obj class]) isEqualToString: @"WardrobeController"])
        [selectedArr replaceObjectAtIndex:0 withObject:@"wardrobe-selected.png"];
    else if ([NSStringFromClass([obj class]) isEqualToString: @"LocateController"])
        [selectedArr replaceObjectAtIndex:1 withObject: @"discover-selected.png"];
    else if ([NSStringFromClass([obj class]) isEqualToString:@"NotificationController"])
        [selectedArr replaceObjectAtIndex:2 withObject:@"reel-selected.png"];

    // menu icon goes to profile
    UIImage* imageMain = [UIImage imageNamed:@"menu.png"];
    CGRect frameimg = CGRectMake(0, 0, imageMain.size.width, imageMain.size.height);
    UIButton *imgButton = [[UIButton alloc] initWithFrame:frameimg];
    [imgButton setBackgroundImage:imageMain forState:UIControlStateNormal];
    [imgButton addTarget:obj action:@selector(showProfile:)
        forControlEvents:UIControlEventTouchUpInside];
    [imgButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithCustomView:imgButton];
    
    // wardrobe menu shows styles owned by users
    UIImage* imageWardrobe = [UIImage imageNamed:[selectedArr objectAtIndex:0]];
    CGRect wardrobeFrameimg = CGRectMake(0, 0, imageWardrobe.size.width, imageWardrobe.size.height);
    UIButton *imgWardrobeButton = [[UIButton alloc] initWithFrame:wardrobeFrameimg];
    [imgWardrobeButton setBackgroundImage:imageWardrobe forState:UIControlStateNormal];
    [imgWardrobeButton addTarget:obj action:@selector(showWardrobe:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgWardrobeButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *wardrobeButton =[[UIBarButtonItem alloc] initWithCustomView:imgWardrobeButton];
   
    // discovery icon shows locate view
    UIImage* imageMap = [UIImage imageNamed:[selectedArr objectAtIndex:1]];
    CGRect mapFrameimg = CGRectMake(0, 0, imageMap.size.width, imageMap.size.height);
    UIButton *imgMapButton = [[UIButton alloc] initWithFrame:mapFrameimg];
    [imgMapButton setBackgroundImage:imageMap forState:UIControlStateNormal];
    [imgMapButton addTarget:obj action:@selector(showLocater:)
           forControlEvents:UIControlEventTouchUpInside];
    [imgMapButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *mapButton =[[UIBarButtonItem alloc] initWithCustomView:imgMapButton];
    
    // reel icon shows notification
    UIImage* imageReel = [UIImage imageNamed:[selectedArr objectAtIndex:2]];
    CGRect reelFrameimg = CGRectMake(0, 0, imageReel.size.width, imageReel.size.height);
    UIButton *imgReelButton = [[UIButton alloc] initWithFrame:reelFrameimg];
    [imgReelButton setBackgroundImage:imageReel forState:UIControlStateNormal];
    [imgReelButton addTarget:obj action:@selector(showNotify:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgReelButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *reelButton =[[UIBarButtonItem alloc] initWithCustomView:imgReelButton];
    
    // space button
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 70;

    //navigationItem.rightBarButtonItems = @[reelButton];

   return @[menuButton, fixedSpaceBarButtonItem, wardrobeButton, fixedSpaceBarButtonItem, mapButton, fixedSpaceBarButtonItem, reelButton];
    
   // return navigationItem;

}


@end