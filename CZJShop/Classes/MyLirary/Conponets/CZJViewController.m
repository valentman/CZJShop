//
//  CZJViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/22/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJViewController.h"

@interface CZJViewController ()<CZJNaviagtionBarViewDelegate>

@end

@implementation CZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCZJNaviBarView:(CZJNaviBarViewType)naviBarViewType
{
    self.navigationController.navigationBarHidden = YES;
    _naviBarView = [[CZJNaviagtionBarView alloc]initWithFrame:CGRectMake(0, 20, PJ_SCREEN_WIDTH, 44) AndType:naviBarViewType];
    _naviBarView.delegate = self;
    [self.view addSubview:_naviBarView];
}

#pragma mark - CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}
@end
