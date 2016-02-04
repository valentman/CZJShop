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
#import "CZJOrderBuildingController.h"
#import "CZJOrderEvaluateController.h"
#import "CZJOrderLogisticsController.h"
#import "CZJOrderCarCheckController.h"
#import "CZJOrderTypeCell.h"
#import "CZJOrderPayCell.h"
#import "CZJOrderPayHeadCell.h"

@interface CZJMyInfoOrderListController ()
<
NIDropDownDelegate,
CZJOrderListDelegate,
UITableViewDataSource,
UITableViewDelegate,
CZJViewControllerDelegate
>
{
    NIDropDown *dropDown;
    CZJOrderListForm* currentTouchedOrderListForm;
    NSArray* _orderTypeAry;
    UITableView* payTypeView;
    CZJOrderTypeForm* _defaultOrderType;        //默认支付方式（为支付宝）
    //    UIButton *rightBtn;
}
@property (strong, nonatomic) UIView *backgroundView;

@end

@implementation CZJMyInfoOrderListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    
}

- (void)viewDidAppear:(BOOL)animated
{
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
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"我的订单";
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
    if (0 == _orderListTypeIndex)
    {
        rightBtn.hidden = NO;
    }
    else
    {
        rightBtn.hidden = YES;
    }
    
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

- (void)clickOrderListCellButton:(CZJOrderListCellButtonType)buttonType andOrderForm:(CZJOrderListForm*)orderListForm
{
    currentTouchedOrderListForm = orderListForm;
    switch (buttonType)
    {
        case CZJOrderListCellBtnTypeReturnAble:
            DLog(@"可退换货列表");
            break;
        case CZJOrderListCellBtnTypeConfirm:
        {
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"确定取消该订单" message:@""];
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancle handler:^(TYAlertAction *action) {
                
            }]];
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
                
            }]];
            
            TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case CZJOrderListCellBtnTypeCheckCar:
            [self performSegueWithIdentifier:@"segueToCarCheck" sender:self];
            DLog(@"查看车况");
            break;
        case CZJOrderListCellBtnTypeShowBuildingPro:
            [self performSegueWithIdentifier:@"segueToBuildingProgress" sender:self];
            DLog(@"查看施工进度");
            break;
        case CZJOrderListCellBtnTypeCancel:
        {
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"确定取消该订单" message:@""];
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancle handler:^(TYAlertAction *action) {
                
            }]];
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
                
            }]];
            
            TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            DLog(@"取消订单");
            break;
        case CZJOrderListCellBtnTypePay:
        {
            CZJOrderTypeForm* zhifubao = [[CZJOrderTypeForm alloc]init];
            zhifubao.orderTypeName = @"支付宝";
            zhifubao.orderTypeImg = @"commit_icon_zhifubao";
            zhifubao.isSelect = YES;
            CZJOrderTypeForm* weixin = [[CZJOrderTypeForm alloc]init];
            weixin.orderTypeName = @"微信支付";
            weixin.orderTypeImg = @"commit_icon_weixin";
            weixin.isSelect = NO;
            CZJOrderTypeForm* uniCard = [[CZJOrderTypeForm alloc]init];
            uniCard.orderTypeName = @"银联支付";
            uniCard.orderTypeImg = @"commit_icon_yinlian";
            uniCard.isSelect = NO;
            
            _orderTypeAry = @[zhifubao,weixin,uniCard];     //目前只支持的三个支付方式
            payTypeView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, 3*80 + 2*60) style:UITableViewStylePlain];
            payTypeView.tableFooterView = [[UIView alloc]init];
            payTypeView.bounces = NO;
            payTypeView.delegate = self;
            payTypeView.dataSource = self;
            
            NSArray* nibArys = @[@"CZJOrderTypeCell",
                                 @"CZJOrderPayCell",
                                 @"CZJOrderPayHeadCell"
                                 ];
            
            for (id cells in nibArys) {
                UINib *nib=[UINib nibWithNibName:cells bundle:nil];
                [payTypeView registerNib:nib forCellReuseIdentifier:cells];
            }
            [payTypeView reloadData];
            
            TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:payTypeView preferredStyle:TYAlertControllerStyleActionSheet];
            alertController.backgoundTapDismissEnable = YES;
            [self presentViewController:alertController animated:YES completion:nil];
        }
            DLog(@"付款");
            break;
        case CZJOrderListCellBtnTypeGoEvaluate:
            [self performSegueWithIdentifier:@"segueToEvaluate" sender:self];
            DLog(@"去评价");
            break;
        case CZJOrderListCellBtnTypeSelectToPay:
            DLog(@"选中未付款项");
            break;
            
        default:
            break;
    }
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orderTypeAry.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        CZJOrderPayHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderPayHeadCell" forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
    
    if (indexPath.row >0 && indexPath.row <_orderTypeAry.count + 1)
    {
        CZJOrderTypeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeCell" forIndexPath:indexPath];
        [cell setOrderTypeForm:_orderTypeAry[indexPath.row - 1]];
        return cell;
    }
    if (_orderTypeAry.count + 1 == indexPath.row)
    {
        CZJOrderPayCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"CZJOrderPayCell" forIndexPath:indexPath];
        cell.totalLabel.text = [NSString stringWithFormat:@"￥%@",@"100"];
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        return 60;
    }
    if (indexPath.row >0 && indexPath.row < _orderTypeAry.count + 1)
    {
        return 80;
    }
    if (_orderTypeAry.count + 1 == indexPath.row)
    {
        return 60;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0 && indexPath.row < _orderTypeAry.count + 1)
    {
        for ( int i = 0; i < _orderTypeAry.count; i++)
        {
            CZJOrderTypeForm* typeForm = _orderTypeAry[i];
            typeForm.isSelect = NO;
            if (i == indexPath.row - 1)
            {
                typeForm.isSelect = YES;
                _defaultOrderType = typeForm;
            }
        }
        [payTypeView reloadData];
    }
}

- (void)didCancel:(id)controller
{
    [self dismissViewControllerAnimated:true completion:nil];
    DLog();
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToOrderDetail"])
    {
        CZJMyOrderDetailController* orderDetailVC = segue.destinationViewController;
        [orderDetailVC setOrderNo:currentTouchedOrderListForm.orderNo];
    }
    if ([segue.identifier isEqualToString:@"segueToBuildingProgress"])
    {
        CZJOrderBuildingController* orderBuildProgressVC = segue.destinationViewController;
        [orderBuildProgressVC setOrderNo:currentTouchedOrderListForm.orderNo];
    }
    if ([segue.identifier isEqualToString:@"segueToCarCheck"])
    {
        CZJOrderCarCheckController* orderCarCheckVC = segue.destinationViewController;
        [orderCarCheckVC setOrderNo:currentTouchedOrderListForm.orderNo];
    }
    if ([segue.identifier isEqualToString:@"segueToEvaluate"])
    {
        CZJOrderEvaluateController* orderEvaluateVC = segue.destinationViewController;
        [orderEvaluateVC setOrderNo:currentTouchedOrderListForm.orderNo];
    }
}
@end
