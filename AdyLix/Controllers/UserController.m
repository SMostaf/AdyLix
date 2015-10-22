//
//  UserController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "UserController.h"
#import "ASStarRatingView.h"

@interface UserController ()
@property ASStarRatingView* staticStarRatingView;
@end

@implementation UserController

- (void)viewDidLoad {
    [super viewDidLoad];
    _staticStarRatingView = [[ASStarRatingView alloc]init];
    _staticStarRatingView.canEdit = NO;
    _staticStarRatingView.maxRating = 5;
    _staticStarRatingView.rating = 5;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setStaticStarRatingView:nil];
    [super viewDidUnload];
}

@end