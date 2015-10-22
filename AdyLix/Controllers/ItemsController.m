//
//  ItemsController.m
//  Ady
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import "ItemsController.h"
#import <CoreLocation/CoreLocation.h>


@interface ItemsController ()
@property (weak, nonatomic) IBOutlet UITableView *itemsTblView;
@end

@implementation ItemsController

- (void)viewDidLoad {
    // query nearby items
    Connector* connHandler = [[Connector alloc]init];
    [connHandler setUIDelegate:self];
    [connHandler getItems];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) receiveStatus:(NSDictionary*) state
{
   // update UI
}
@end