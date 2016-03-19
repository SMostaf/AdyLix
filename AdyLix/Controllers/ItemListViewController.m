//
//  itemTableViewController.m
//  AdyLix
//
//  Created by Sahar Mostafa on 10/22/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemListViewController.h"
#import "ItemsController.h"


@interface ItemListViewController()
@end

@implementation ItemListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnAddItem:(id)sender {
    ItemsController * itemsAdd = [[ItemsController alloc] init];
   // [self presentViewController:itemsAdd animated:YES completion:nil];
    [self.navigationController pushViewController:itemsAdd animated: YES];
}

@end
