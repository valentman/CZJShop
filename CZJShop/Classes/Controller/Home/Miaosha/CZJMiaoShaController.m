//
//  CZJMiaoShaController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMiaoShaController.h"
#import "CZJMiaoShaListBaseController.h"
#import "CZJPageControlView.h"
#import "CZJBaseDataManager.h"
#import "CZJMiaoShaControlHeaderCell.h"

@interface CZJMiaoShaController ()
<
CZJMiaoShaListDelegate
>
{
    CZJMiaoShaControllerForm* miaoShaControllerForm;
}
@end

@implementation CZJMiaoShaController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMiaoShaData];
    [self initMiaoShaViews];
}

- (void)initMiaoShaData
{
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] objectForKey:@"msg"];
        miaoShaControllerForm = [CZJMiaoShaControllerForm  objectWithKeyValues:dict];
    } andServerAPI:kCZJServerAPIGetKillTimeList];
}

- (void)initMiaoShaViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"秒杀专场";
    
    CZJMiaoShaControlHeaderCell* headerCell = [CZJUtils getXibViewByName:@"CZJMiaoShaControlHeaderCell"];
    headerCell.frame = CGRectMake(0, 114, PJ_SCREEN_WIDTH, 30);
    [self.view addSubview:headerCell];
    
    CZJMiaoShaOneController* allVC = [[CZJMiaoShaOneController alloc]init];
    allVC.delegate = self;
    CZJMiaoShaTwoController* nopayVC = [[CZJMiaoShaTwoController alloc]init];
    nopayVC.delegate = self;
    CZJMiaoShaThreeController* nobuildVC = [[CZJMiaoShaThreeController alloc]init];
    nobuildVC.delegate = self;
    CZJMiaoShaFourController* noReceiveVC = [[CZJMiaoShaFourController alloc]init];
    noReceiveVC.delegate =  self;
    CZJMiaoShaFiveController* noEvaVC = [[CZJMiaoShaFiveController alloc]init];
    noEvaVC.delegate = self;
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT);
    CZJPageControlView* pageview = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:0];
    [pageview setTitleArray:@[@"8:00",@"12:00",@"16:00",@"20:00",@"00:00"] andVCArray:@[allVC, nopayVC, nobuildVC,noReceiveVC, noEvaVC]];
    pageview.backgroundColor = CLEARCOLOR;
    [self.view addSubview:pageview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark- CZJMiaoShaListDelegate


@end
