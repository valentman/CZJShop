//
//  CZJMyWalletBalanceController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletBalanceController.h"
#import "CZJBaseDataManager.h"

@interface CZJMyWalletBalanceController ()
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notifiImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *balanceLabelWidth;
@end

@implementation CZJMyWalletBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self hiddenButton:YES];
    //UIButton
    UIButton *leftBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(- 20 , 0 , 88 , 44 )];
    [leftBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [leftBtn setTitle:@"使用说明" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(useGuideAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal]; //将leftItem设置为自定义按钮
    
    //UIBarButtonItem
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self getBalanceDataFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)getBalanceDataFromServer
{
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        self.balanceLabel.text = [dict valueForKey:@"money"];
        self.balanceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:[dict valueForKey:@"money"] AndFontSize:24].width + 5;
        self.notificationLabel.text = [dict valueForKey:@"title"];
        self.notifiImg.hidden = [[dict valueForKey:@"title"] isEqualToString:@""];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIGetBalanceInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)useGuideAction:(id)sender
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = [NSString stringWithFormat:@"%@%@",kCZJServerAddr,YUE_HINT];
    [self.navigationController pushViewController:webView animated:YES];
}
@end
