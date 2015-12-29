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
+(UINavigationItem*) getNavForProfile:(id) obj {
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
//    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -50, 380, 40)];
//    navbar.backgroundColor = [UIColor redColor];
//
//    UIImage* imageMain = [UIImage imageNamed:@"menu.png"];
//    CGRect frameimg = CGRectMake(0, 0, imageMain.size.width, imageMain.size.height);
//    UIButton *imgButton = [[UIButton alloc] initWithFrame:frameimg];
//    [imgButton setBackgroundImage:imageMain forState:UIControlStateNormal];
//    [imgButton addTarget:obj action:@selector(showProfile:)
//        forControlEvents:UIControlEventTouchUpInside];
//    [imgButton setShowsTouchWhenHighlighted:YES];
//
//    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithCustomView:imgButton];
//    navigationItem.leftBarButtonItem = menuButton;


    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                                                             style:UIBarButtonItemStylePlain target:obj action:@selector(back:)];
    

    
    UIImage* imageSnap = [UIImage imageNamed:@"camera.png"];
    CGRect snapFrameimg = CGRectMake(0, 0, imageSnap.size.width, imageSnap.size.height);
    UIButton *imgSnapButton = [[UIButton alloc] initWithFrame:snapFrameimg];
    [imgSnapButton setBackgroundImage:imageSnap forState:UIControlStateNormal];
    [imgSnapButton addTarget:obj action:@selector(showSelfie:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgSnapButton setShowsTouchWhenHighlighted:YES];

    UIBarButtonItem *snapButton =[[UIBarButtonItem alloc] initWithCustomView:imgSnapButton];
    navigationItem.rightBarButtonItem = snapButton;

    return navigationItem;
}

// function building the main menu navigation for all views except the profile
// shows four icons: main menu + wardrobe + disocvery + reel
+(UINavigationItem*) getNavMainMenu:(id) obj {

    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -50, 380, 40)];
    
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
    UIImage* imageWardrobe = [UIImage imageNamed:@"wardrobe.png"];
    CGRect wardrobeFrameimg = CGRectMake(0, 0, imageWardrobe.size.width, imageWardrobe.size.height);
    UIButton *imgWardrobeButton = [[UIButton alloc] initWithFrame:wardrobeFrameimg];
    [imgWardrobeButton setBackgroundImage:imageWardrobe forState:UIControlStateNormal];
    [imgWardrobeButton addTarget:obj action:@selector(showWardrobe:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgWardrobeButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *wardrobeButton =[[UIBarButtonItem alloc] initWithCustomView:imgWardrobeButton];
   
    // discovery icon shows locate view
    UIImage* imageMap = [UIImage imageNamed:@"map.png"];
    CGRect mapFrameimg = CGRectMake(0, 0, imageMap.size.width, imageMap.size.height);
    UIButton *imgMapButton = [[UIButton alloc] initWithFrame:mapFrameimg];
    [imgMapButton setBackgroundImage:imageMap forState:UIControlStateNormal];
    [imgMapButton addTarget:obj action:@selector(showLocater:)
           forControlEvents:UIControlEventTouchUpInside];
    [imgMapButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *mapButton =[[UIBarButtonItem alloc] initWithCustomView:imgMapButton];
    
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceBarButtonItem.width = 70;

    
    navigationItem.leftBarButtonItems = @[menuButton, fixedSpaceBarButtonItem, wardrobeButton, fixedSpaceBarButtonItem, mapButton];
    

    // reel icon shows notification
    UIImage* imageReel = [UIImage imageNamed:@"reel.png"];
    CGRect reelFrameimg = CGRectMake(0, 0, imageReel.size.width, imageReel.size.height);
    UIButton *imgReelButton = [[UIButton alloc] initWithFrame:reelFrameimg];
    [imgReelButton setBackgroundImage:imageReel forState:UIControlStateNormal];
    [imgReelButton addTarget:obj action:@selector(showNotify:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgReelButton setShowsTouchWhenHighlighted:YES];
    
    
    UIBarButtonItem *reelButton =[[UIBarButtonItem alloc] initWithCustomView:imgReelButton];
    navigationItem.rightBarButtonItems = @[reelButton];
    
    
//    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
//    
//    //    // Optional: if you want to add space between the refresh & profile buttons
//    //    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    //    fixedSpaceBarButtonItem.width = 12;
//    
//    UIBarButtonItem *profileBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(goToProfile)];
//    profileBarButtonItem.style = UIBarButtonItemStyleBordered;
//    
//    self.navigationItem.rightBarButtonItems = @[profileBarButtonItem, /* fixedSpaceBarButtonItem, */ refreshBarButtonItem]
    
    return navigationItem;

}


@end