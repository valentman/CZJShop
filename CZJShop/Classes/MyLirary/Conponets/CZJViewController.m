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
    [self checkNetWorkStatus];
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

- (void)checkNetWorkStatus
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusUnknown:
                 DLog(@"未知网络状态");
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 [CZJUtils tipWithText:@"请检查网络设置，确保连接网络" andView:nil];
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
                 DLog(@"手机自有网络连接");
                 break;
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 DLog(@"Wifi连接");
                 break;
             default:
                 break;
         }
     }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

- (void)netWorkStatusChanged:(id)noti
{
    
}
@end
