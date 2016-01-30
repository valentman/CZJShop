//
//  CZJMyOrderDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyOrderDetailController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderForm.h"

@interface CZJMyOrderDetailController ()
{
    CZJOrderDetailForm* orderDetailForm;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation CZJMyOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getOrderDetailFromServer];
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    
}

- (void)getOrderDetailFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getOrderDetail:params Success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        orderDetailForm = [CZJOrderDetailForm objectWithKeyValues:dict];
        
    } fail:^{
        
    }];
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
