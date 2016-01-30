//
//  CZJMyInfoOrderListController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoOrderListController.h"
#import "CZJBaseDataManager.h"
#import "NIDropDown.h"
#import "CZJOrderForm.h"
#import "CZJPageControlView.h"
#import "CZJOrderListAllController.h"
#import "CZJOrderListNoPayController.h"
#import "CZJOrderListNoBuildController.h"
#import "CZJOrderListNoReceiveController.h"
#import "CZJOrderListNoEvaController.h"
#import "CZJMyOrderDetailController.h"

@interface CZJMyInfoOrderListController ()
<
NIDropDownDelegate,
CZJOrderListDelegate
>
{
    NIDropDown *dropDown;
    CZJOrderListForm* currentTouchedOrderListForm;
//    UIButton *rightBtn;
}
@property (strong, nonatomic) UIView *backgroundView;

@end

@implementation CZJMyInfoOrderListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    [self initViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDateIntervalButton:) name:kCZJNotifikOrderListType object:nil];
}

- (void)updateDateIntervalButton:(NSNotification*)notif
{
    NSString* index = [notif.userInfo objectForKey:@"currentIndex"];
    if ([index isEqualToString:@"0"])
    {
        VIEWWITHTAG(self.naviBarView, 2999).hidden = NO;
    }
    else
    {
        VIEWWITHTAG(self.naviBarView, 2999).hidden = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCZJNotifikOrderListType object:nil];
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self hiddenButton:YES];
    //右按钮
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(PJ_SCREEN_WIDTH - 100 , 0 , 100 , 44 );
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [rightBtn setTitle:@"一个月内" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    [rightBtn setTag:2999];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    [self.naviBarView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];

    
    CZJOrderListAllController* allVC = [[CZJOrderListAllController alloc]init];
    allVC.delegate = self;
    CZJOrderListNoPayController* nopayVC = [[CZJOrderListNoPayController alloc]init];
    nopayVC.delegate = self;
    CZJOrderListNoBuildController* nobuildVC = [[CZJOrderListNoBuildController alloc]init];
    nobuildVC.delegate = self;
    CZJOrderListNoReceiveController* noReceiveVC = [[CZJOrderListNoReceiveController alloc]init];
    noReceiveVC.delegate =  self;
    CZJOrderListNoEvaController* noEvaVC = [[CZJOrderListNoEvaController alloc]init];
    noEvaVC.delegate = self;
    
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT);
    CZJPageControlView* pageview = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:_orderListTypeIndex];
    [pageview setTitleArray:@[@"全部",@"待付款",@"待施工",@"待收货",@"待评价"] andVCArray:@[allVC, nopayVC, nobuildVC,noReceiveVC, noEvaVC]];
    pageview.backgroundColor = CZJNAVIBARBGCOLOR;
    [self.view addSubview:pageview];
    
    _backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGBA(240, 240, 240, 0);
    [self.view addSubview:_backgroundView];
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
}

- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }
}

- (void)edit:(id)sender
{
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@{@"一个月内" : @""}, @{@"三个月内":@""}, @{@"一年内" :@""},@{@"全部" : @""},nil];
    if(dropDown == nil) {
        CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 150 - 14, StatusBar_HEIGHT + 78, 150, arr.count * 50);
        _backgroundView.hidden = NO;
        dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr];
        [dropDown setTrangleLayerPositioin:kCZJLayerPositionTypeRight];
        dropDown.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
//    [rightBtn setTitle:btnStr forState:UIControlStateNormal];
    [((UIButton*)VIEWWITHTAG(self.naviBarView, 2999)) setTitle:btnStr forState:UIControlStateNormal];
    DLog(@"%@",btnStr);
    [self tapBackground:nil];
}

#pragma mark -CZJOrderListDelegate
- (void)clickOneOrder:(CZJOrderListForm *)orderListForm
{
    currentTouchedOrderListForm = orderListForm;
    [self performSegueWithIdentifier:@"segueToOrderDetail" sender:self];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToOrderDetail"])
    {
        CZJMyOrderDetailController* orderDetailVC = segue.destinationViewController;
        [orderDetailVC setOrderNo:currentTouchedOrderListForm.orderNo];
    }
}
@end
