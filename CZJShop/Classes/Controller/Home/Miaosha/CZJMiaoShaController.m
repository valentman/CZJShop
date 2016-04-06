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
#import "CZJDetailViewController.h"
#import "CZJMiaoShaTimesView.h"

@interface CZJMiaoShaController ()
<
CZJMiaoShaListDelegate,
CZJNaviagtionBarViewDelegate
>
{
    CZJMiaoShaControllerForm* miaoShaControllerForm;
    
    CZJMiaoShaTimesView* miaoShaTimesView;                  //秒杀场次view
    CZJMiaoShaControlHeaderCell* headerCell;                //秒杀抢购倒计时栏
    CZJPageControlView* pageControlView;                    //秒杀商品区
    
    UIImageView* trangleView;                               //红色小三角图形
    NSArray* pageControls;
    NSInteger currentIndex;
    NSInteger _timestamp;
    NSTimer *timer;
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
        DLog(@"%@",miaoShaControllerForm.keyValues);
        [self initMiaoShaPageView];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIGetKillTimeList];
}

- (void)initMiaoShaViews
{
    //导航栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"秒杀专场";
    
    //秒杀场次栏
    miaoShaTimesView = [CZJUtils getXibViewByName:@"CZJMiaoShaTimesView"];
    miaoShaTimesView.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 50);
    [self.view addSubview:miaoShaTimesView];
    for (UIView* cellView in [miaoShaTimesView.contentView subviews])
    {
        cellView.backgroundColor = RGB(37, 38, 38);
        ((UILabel*)VIEWWITHTAG(cellView, 101)).textColor = WHITECOLOR;
        ((UILabel*)VIEWWITHTAG(cellView, 102)).textColor = WHITECOLOR;
        if (cellView.tag == currentIndex)
        {
            cellView.backgroundColor = CZJREDCOLOR;
        }
    }
    
    //秒杀倒计时栏
    headerCell = [CZJUtils getXibViewByName:@"CZJMiaoShaControlHeaderCell"];
    headerCell.frame = CGRectMake(0, 114, PJ_SCREEN_WIDTH, 35);
    [self.view addSubview:headerCell];
    
    //提示小三角
    trangleView = [[UIImageView alloc]initWithImage:IMAGENAMED(@"miaosha_icon_angle")];
    [trangleView setSize:CGSizeMake(21, 6)];
    [trangleView setPosition:CGPointMake(miaoShaTimesView.viewOne.frame.size.width * 0.5, 113) atAnchorPoint:CGPointTopMiddle];
    [self.view addSubview:trangleView];
    
    //秒杀内容
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

    pageControls = @[allVC, nopayVC, nobuildVC,noReceiveVC, noEvaVC];
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT + 50 +  35, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT);
    CZJPageControlViewConfig* config = [[CZJPageControlViewConfig alloc]init];
    config.pageControllerFrame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - (StatusBar_HEIGHT + NavigationBar_HEIGHT + 50 +  35));
    
    pageControlView = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:0];
    [pageControlView setPageControlViewConfig:config];
    pageControlView.backgroundColor = CLEARCOLOR;
    [self.view addSubview:pageControlView];
}

- (void)initMiaoShaPageView
{
    for (int i = 0; i < pageControls.count; i++)
    {
        CZJMiaoShaListBaseController* baseVC = pageControls[i];
        baseVC.miaoShaTimes = miaoShaControllerForm.skillTimes[i];
        
        
        UIView* topTimeView = VIEWWITHTAG(miaoShaTimesView, 3000 + i);
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];

        [topTimeView addGestureRecognizer:tapGes];
    }
    [pageControlView setTitleArray:@[@"",@"",@"",@"",@""] andVCArray:pageControls];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMiaoShaTime:) name:kCZJNotifikOrderListType object:nil];
    
    [self setTimestamp:[((CZJMiaoShaTimesForm*)miaoShaControllerForm.skillTimes[4]).skillTime integerValue] - [miaoShaControllerForm.currentTime integerValue]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTimestamp:(NSInteger)timestamp{
    _timestamp = timestamp;
    if (_timestamp != 0) {
        [self refreshTimeStamp];
        timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimeStamp) userInfo:nil repeats:YES];
    }
}

- (void)refreshTimeStamp
{
    _timestamp--;
    CZJDateTime mydateTime = [CZJUtils getLeftDatetime:_timestamp];
    NSString* hourStr = [NSString stringWithFormat:@"%ld", mydateTime.hour];
    if (mydateTime.hour < 10)
    {
        hourStr =[NSString stringWithFormat:@"0%ld", mydateTime.hour];
    }
    
    NSString* minutesStr = [NSString stringWithFormat:@"%ld", mydateTime.minute];
    if (mydateTime.minute < 10)
    {
        minutesStr = [NSString stringWithFormat:@"0%ld", mydateTime.minute];
    }

    NSString* secondStr = [NSString stringWithFormat:@"%ld", mydateTime.second];
    if (mydateTime.second < 10)
    {
        secondStr = [NSString stringWithFormat:@"0%ld", mydateTime.second];
    }

    
    headerCell.hourLabel.text = hourStr;
    headerCell.minutesLabel.text = minutesStr;
    headerCell.secondLabel.text = secondStr;
    
    if (_timestamp == 0) {
        [timer invalidate];
        timer = nil;
        // 执行block回调
        [self timeStop];
    }
}

- (void)timeStop
{
    
}

#pragma mark- CZJMiaoShaListDelegate
- (void)clickMiaoShaCell:(CZJMiaoShaCellForm*)cellForm
{
    CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDGoodsDetailVC];
    detailVC.storeItemPid = cellForm.storeItemPid;
    detailVC.detaiViewType = CZJDetailTypeGoods;
    detailVC.promotionType = CZJGoodsPromotionTypeMiaoSha;
    detailVC.promotionPrice = cellForm.currentPrice;
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark- PageControl改变页面通知反馈
- (void)updateMiaoShaTime:(NSNotification*)notif
{
    currentIndex = [[notif.userInfo objectForKey:@"currentIndex"] integerValue];
}

- (void)clickEventCallBack:(id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarBack:
            for (CZJMiaoShaListBaseController* baseMiaoshaVC in pageControls) {
                [baseMiaoshaVC removeNotificationFromMiaoSha];
            }
            [self.navigationController popViewControllerAnimated:true];
            break;
        default:
            break;
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)tapGesture
{
    DLog(@"");
}

@end
