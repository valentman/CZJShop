//
//  CZJOrderListAllController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/28/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListAllController.h"


@interface CZJOrderListAllController ()

@end

@implementation CZJOrderListAllController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getOrderListFromServer];
    } afterDelay:0.5];
}

- (void)getOrderListFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getOrderListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
