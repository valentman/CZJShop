//
//  CZJOrderListNoPayController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/28/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListNoPayController.h"

@interface CZJOrderListNoPayController ()

@end

@implementation CZJOrderListNoPayController

- (void)viewDidLoad {
    _params = @{@"type":@"1", @"page":@"1", @"timeType":@"0"};
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getOrderListFromServer];
    } afterDelay:0.5];
}

- (void)getOrderListFromServer
{
    
    [super getOrderListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
