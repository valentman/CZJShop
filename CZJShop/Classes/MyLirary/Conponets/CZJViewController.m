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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 * @naviBarViewType 这里根据传入自定义导航栏的类型初始相应的导航栏视图加入到当前视图控制器上
 */
- (void)addCZJNaviBarView:(CZJNaviBarViewType)naviBarViewType
{
    self.navigationController.navigationBarHidden = YES;
    _naviBarView = [[CZJNaviagtionBarView alloc]initWithFrame:CGRectMake(0, 20, PJ_SCREEN_WIDTH, 44) AndType:naviBarViewType];
    _naviBarView.delegate = self;
    [self.view addSubview:_naviBarView];
}

#pragma mark - CZJNaviagtionBarViewDelegate(自定义导航栏按钮回调)
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

/* 每当跳转到继承自当前自定义视图控制器时，都进行网络状态检查，以提示用户当前网络状况 */
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
@end
