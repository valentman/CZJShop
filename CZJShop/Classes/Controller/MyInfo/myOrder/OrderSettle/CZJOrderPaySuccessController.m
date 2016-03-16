//
//  CZJOrderPaySuccessController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/8/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderPaySuccessController.h"
#import "CZJBaseTabBarController.h"
#import "CZJMyInformationController.h"
#import "AppDelegate.h"
#import "CZJMyInfoOrderListController.h"

@interface CZJOrderPaySuccessController ()

@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *payNumber;
- (IBAction)showOrderAction:(id)sender;
- (IBAction)backToHomeAction:(id)sender;

@end

@implementation CZJOrderPaySuccessController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeBack];
    self.naviBarView.btnShop.hidden = YES;
    self.naviBarView.customSearchBar.hidden = YES;
    self.naviBarView.buttomSeparator.hidden = YES;
    [self.naviBarView setBackgroundColor:CLEARCOLOR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidAppear:(BOOL)animated
{
    self.orderNumber.text = self.orderNo;
    self.payNumber.text = self.orderPrice;
}

- (IBAction)showOrderAction:(id)sender
{
    CZJMyInfoOrderListController *orderListVC = (CZJMyInfoOrderListController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDMyOrderList];
    [self.navigationController pushViewController:orderListVC animated:YES];
    orderListVC.orderListTypeIndex = 0;
}

- (IBAction)backToHomeAction:(id)sender
{
    UIViewController *_CZJRootViewController = [CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDHomeView];
    AppDelegate* mydelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    mydelegate.window.rootViewController = nil;
    mydelegate.window.rootViewController = _CZJRootViewController;
}
@end
