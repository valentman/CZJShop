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
#import "CZJOrderListReturnedController.h"
#import "CZJPopPayViewController.h"
#import "CZJMiaoShaTimesView.h"
#import "CZJPaymentManager.h"

@interface CZJMyInfoOrderListController ()
<
NIDropDownDelegate,
CZJOrderListDelegate,
CZJPopPayViewDelegate
>
{
    NIDropDown *dropDown;
    CZJOrderListForm* currentTouchedOrderListForm;
    NSString* orderNoString;
    NSInteger currentIndex;
    CZJGeneralBlock hidePayViewBlock;
    float totalMoney;
}
@property (strong, nonatomic) UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *settlePanelView;

- (IBAction)mergeToPayAction:(id)sender;

@end

@implementation CZJMyInfoOrderListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDateIntervalButton:) name:kCZJNotifikOrderListType object:nil];
}

- (void)updateDateIntervalButton:(NSNotification*)notif
{
    NSString* index = [notif.userInfo objectForKey:@"currentIndex"];
    currentIndex = [index integerValue];
    if ([index isEqualToString:@"0"])
    {
        VIEWWITHTAG(self.naviBarView, 2999).hidden = NO;
    }
    else
    {
        VIEWWITHTAG(self.naviBarView, 2999).hidden = YES;
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.settlePanelView setPosition:CGPointMake(0, PJ_SCREEN_HEIGHT - ([index isEqualToString:@"1"] ? 50 : 0)) atAnchorPoint:CGPointZero];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCZJNotifikOrderListType object:nil];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"我的订单";
    
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
        dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr andType:CZJNIDropDownTypeNormal];
        [dropDown setTrangleLayerPositioin:kCZJLayerPositionTypeRight];
        dropDown.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    [((UIButton*)VIEWWITHTAG(self.naviBarView, 2999)) setTitle:btnStr forState:UIControlStateNormal];
    [self tapBackground:nil];
}

#pragma mark -CZJOrderListDelegate
- (void)clickOneOrder:(CZJOrderListForm *)orderListForm
{
    currentTouchedOrderListForm = orderListForm;
    [self performSegueWithIdentifier:@"segueToOrderDetail" sender:self];
}

- (void)clickOrderListCellButton:(UIButton*)sender
                   andButtonType:(CZJOrderListCellButtonType)buttonType
                    andOrderForm:(CZJOrderListForm*)orderListForm
{
    currentTouchedOrderListForm = orderListForm;
    switch (buttonType)
    {
        case CZJOrderListCellBtnTypeReturnAble:
            [self performSegueWithIdentifier:@"segueToMyReturnableList" sender:self];
            break;
        case CZJOrderListCellBtnTypeConfirm:
        {
            __weak typeof(self) weak = self;
            [self showCZJAlertView:@"你要想好哦，确认收货就不能退款了哦" andConfirmHandler:^{
                [weak hideWindow];
            } andCancleHandler:nil];
        }
            break;
        case CZJOrderListCellBtnTypeCheckCar:
            [self performSegueWithIdentifier:@"segueToCarCheck" sender:self];
            break;
        case CZJOrderListCellBtnTypeShowBuildingPro:
            [self performSegueWithIdentifier:@"segueToBuildingProgress" sender:self];
            break;
        case CZJOrderListCellBtnTypeCancel:
        {
            __weak typeof(self) weak = self;
            [self showCZJAlertView:@"确定取消该订单" andConfirmHandler:^{
                [CZJBaseDataInstance generalPost:@{} success:^(id json) {
                    
                } andServerAPI:kCZJServerAPICancelOrder];
                [weak hideWindow];
            } andCancleHandler:nil];
        }
            break;
        case CZJOrderListCellBtnTypePay:
            [self showPopPayView:[currentTouchedOrderListForm.orderMoney floatValue] andOrderNoSting:currentTouchedOrderListForm.orderNo];
            break;
        case CZJOrderListCellBtnTypeGoEvaluate:
            [self performSegueWithIdentifier:@"segueToEvaluate" sender:self];
            break;
            
        default:
            break;
    }
}

- (void)showPopPayView:(float)orderMoney andOrderNoSting:(NSString*)orderNostr
{
    orderNoString = orderNostr;
    totalMoney = orderMoney;
    CZJPopPayViewController* payPopView = [[CZJPopPayViewController alloc]init];
    payPopView.delegate = self;
    payPopView.orderMoney = orderMoney;
    
    float popViewHeight = CZJBaseDataInstance.orderPaymentTypeAry.count * 70 + 60 +50.5;
    self.popWindowInitialRect = VERTICALHIDERECT(0);
    self.popWindowDestineRect = VERTICALSHOWRECT(popViewHeight);
    [CZJUtils showMyWindowOnTarget:self withMyVC:payPopView];
    __weak typeof(self) weak = self;
    
    hidePayViewBlock = ^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weak.window.frame = weak.popWindowInitialRect;
            weak.upView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [weak.upView removeFromSuperview];
                [weak.window resignKeyWindow];
                weak.window  = nil;
                weak.upView = nil;
                weak.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
        }];
    };
    [payPopView setCancleBarItemHandle:hidePayViewBlock];
}

#pragma mark- CZJPopPayViewDelegate
- (void)payViewToPay:(id)sender
{
    CZJOrderTypeForm* selectOrderTypeForm = (CZJOrderTypeForm*)sender;
    NSDictionary* params = @{@"orderIds" : orderNoString, @"totalMoney" : [NSString stringWithFormat:@"%f",totalMoney]};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils performBlock:hidePayViewBlock afterDelay:0.5];
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        CZJPaymentOrderForm* paymentOrderForm = [[CZJPaymentOrderForm alloc] init];
        paymentOrderForm.order_no = [dict valueForKey:@"payNo"];
        paymentOrderForm.order_name = [NSString stringWithFormat:@"订单%@",[dict valueForKey:@"payNo"]];
        paymentOrderForm.order_description = @"支付宝你个SB";
        paymentOrderForm.order_price = [dict valueForKey:@"totalMoney"];
        if ([selectOrderTypeForm.orderTypeName isEqualToString:@"微信支付"])
        {
            [CZJPaymentInstance weixinPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
                DLog(@"微信支付成功");
            } Fail:^(NSDictionary *message, NSError *error) {
                [CZJUtils tipWithText:@"微信支付失败" andView:weak.view];
            }];
        }
        if ([selectOrderTypeForm.orderTypeName isEqualToString:@"支付宝"])
        {
            [CZJPaymentInstance aliPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
                DLog(@"支付宝支付成功");
            } Fail:^(NSDictionary *message, NSError *error) {
                [CZJUtils tipWithText:@"支付宝支付失败" andView:weak.view];
            }];
        }
    } andServerAPI:kCZJServerAPIOrderToPay];

}

- (IBAction)mergeToPayAction:(id)sender
{
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToOrderDetail"])
    {
        CZJMyOrderDetailController* orderDetailVC = segue.destinationViewController;
        [orderDetailVC setOrderNo:currentTouchedOrderListForm.orderNo];
        [orderDetailVC setOrderDetailType:CZJOrderDetailTypeGeneral];
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
        CZJOrderDetailForm* evalutaeDetailForm = [[CZJOrderDetailForm alloc] init];
        evalutaeDetailForm.orderNo = currentTouchedOrderListForm.orderNo;
        evalutaeDetailForm.storeId = currentTouchedOrderListForm.storeId;
        evalutaeDetailForm.items = currentTouchedOrderListForm.items;
        evalutaeDetailForm.createTime = currentTouchedOrderListForm.createTime;
        orderEvaluateVC.orderDetailForm = evalutaeDetailForm;
        [orderEvaluateVC setOrderNo:currentTouchedOrderListForm.orderNo];
    }
    if ([segue.identifier isEqualToString:@"segueToMyReturnableList"])
    {
        CZJOrderListReturnedController* returnList = segue.destinationViewController;
        returnList.returnListType = CZJReturnListTypeReturnable;
        returnList.orderNo = currentTouchedOrderListForm.orderNo;
    }
}

@end
