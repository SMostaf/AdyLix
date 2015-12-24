//
//  Utility.m
//  AdyLix
//
//  Created by Sahar Mostafa on 12/24/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"


@implementation Utility

+(UINavigationItem*) getNavItem {
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -50, 380, 40)];
    navbar.backgroundColor = [UIColor redColor];

    UIImage* imageMain = [UIImage imageNamed:@"menu.png"];
    CGRect frameimg = CGRectMake(0, 0, imageMain.size.width, imageMain.size.height);
    UIButton *imgButton = [[UIButton alloc] initWithFrame:frameimg];
    [imgButton setBackgroundImage:imageMain forState:UIControlStateNormal];
    [imgButton addTarget:self action:@selector(showProfile:)
        forControlEvents:UIControlEventTouchUpInside];
    [imgButton setShowsTouchWhenHighlighted:YES];

    UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithCustomView:imgButton];
    navigationItem.leftBarButtonItem = menuButton;


    UIImage* imageSnap = [UIImage imageNamed:@"camera.png"];
    CGRect snapFrameimg = CGRectMake(0, 0, imageSnap.size.width, imageSnap.size.height);
    UIButton *imgSnapButton = [[UIButton alloc] initWithFrame:snapFrameimg];
    [imgSnapButton setBackgroundImage:imageSnap forState:UIControlStateNormal];
    [imgSnapButton addTarget:self action:@selector(showSelfie:)
            forControlEvents:UIControlEventTouchUpInside];
    [imgSnapButton setShowsTouchWhenHighlighted:YES];

    UIBarButtonItem *snapButton =[[UIBarButtonItem alloc] initWithCustomView:imgSnapButton];
    navigationItem.rightBarButtonItem = snapButton;

    return navigationItem;
    
}

@end