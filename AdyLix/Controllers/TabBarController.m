//
//  TabBarController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 10/24/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabBarController.h"

@implementation TabBarController


-(void) viewDidLoad
  {
      self.selectedIndex = 1;

  }

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    //NSUInteger index=[[tabBarController viewControllers] indexOfObject:viewController];
    
    return YES;
}

@end