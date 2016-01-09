//
//  CZJCommitOrderController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJCommitOrderController.h"
#import "CZJOrderTypeCell.h"
#import "CZJBaseDataManager.h"
#import "CZJAddDeliveryAddrCell.h"
#import "CZJDeliveryAddrCell.h"
#import "CZJOrderTypeCell.h"
#import "CZJRedPacketCell.h"
#import "CZJOrderCouponCell.h"
#import "CZJOrderProductHeaderCell.h"
#import "CZJPromotionCell.h"
#import "CZJOrderProductFooterCell.h"
#import "CZJGiftCell.h"
#import "CZJLeaveMessageCell.h"
#import "CZJOrderTypeExpandCell.h"
#import "CZJChooseCouponController.h"
#import "CZJOrderForm.h"
#import "CZJDeliveryAddrController.h"
#import "CZJShoppingCartForm.h"


@interface CZJCommitOrderController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJOrderTypeExpandCellDelegate,
CZJDeliveryAddrControllerDelegate,
CZJChooseCouponControllerDelegate
>
{
    NSDictionary* _orderInfoDict;               //服务器返回的订单页面是数据
    NSDictionary* _addrDict;                    //收货地址
    CZJOrderTypeForm* _defaultOrderType;        //默认支付方式（为支付宝）
    NSArray* _orderTypeAry;                     //支付方式（支付宝，微信，银联）
    NSMutableArray* _orderStoreAry;             //订单信息中所选商品信息列表
    NSMutableArray* _storeIdAry;                //门店ID数组
    CZJAddrForm* _currentChooseAddr;            //当前选择地址
    NSMutableArray* _useableCouponsAry;         //使用优惠券集合
    NSMutableArray* _useableStoreCouponAry;     //门店优惠券集合
    
    BOOL isOrderTypeExpand;                     //支付方式是否展开
    
    id touchedCell;
    
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
- (IBAction)goToSettleAction:(id)sender;

@end

@implementation CZJCommitOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initDatas];
    [self initViews];
    [self getSettleDataFromServer];
}

- (void)initDatas
{
    _addrDict = [NSDictionary dictionary];
    _orderInfoDict = [NSDictionary dictionary];
    _orderStoreAry = [NSMutableArray array];
    _storeIdAry = [NSMutableArray array];
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
    for (CZJOrderTypeForm* form in _orderTypeAry)
    {
        if (form.isSelect)
        {
            _defaultOrderType = form;
            continue;
        }
    }
    
    isOrderTypeExpand = NO;
    [[CZJBaseDataInstance orderStoreCouponAry] removeAllObjects];
    [self getUsableCouponList];
}

- (void)getUsableCouponList
{
    _useableStoreCouponAry = [CZJBaseDataInstance orderStoreCouponAry];
    //获取可用优惠券列表
    for ( int i = 0; i < _useableStoreCouponAry.count; i++ )
    {
        CZJOrderStoreCouponsForm* storeCouponForm  = _useableStoreCouponAry[i];
        for (CZJShoppingCouponsForm* couponForm in storeCouponForm.coupons)
        {
            if ([storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId])
            {
                [_useableCouponsAry addObject:couponForm];
                continue;
            }
        }
    }
}

- (void)initViews
{
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    NSArray* nibArys = @[@"CZJAddDeliveryAddrCell",
                         @"CZJDeliveryAddrCell",
                         @"CZJOrderTypeCell",
                         @"CZJOrderTypeExpandCell",
                         @"CZJRedPacketCell",
                         @"CZJOrderCouponCell",
                         @"CZJOrderProductHeaderCell",
                         @"CZJPromotionCell",
                         @"CZJOrderProductFooterCell",
                         @"CZJGiftCell",
                         @"CZJLeaveMessageCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    self.myTableView.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)getSettleDataFromServer
{
    DLog(@"%@",[CZJUtils JsonFromData:_settleParamsAry]);
    NSDictionary* parmas = @{@"cartsJson" : [CZJUtils JsonFromData:_settleParamsAry]};
    [CZJBaseDataInstance loadSettleOrder:parmas Success:^(id json){
        _orderInfoDict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        NSArray* tmpStoreAry = [_orderInfoDict valueForKey:@"stores"];
        for (NSDictionary* dict in tmpStoreAry)
        {
            CZJOrderStoreForm* form = [[CZJOrderStoreForm alloc]initWithDictionary:dict];
            [_orderStoreAry addObject:form];
            [_storeIdAry addObject:form.storeId];
        }
        [self.myTableView reloadData];
    } fail:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3 + _orderStoreAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else if (1 == section)
    {
        if (isOrderTypeExpand) {
            return _orderTypeAry.count + 1;
        }
        else
        {
            return 2;
        }
    }
    else if (2 == section)
    {
        return 3;
    }
    else
    {
        NSInteger itemCount;
        NSInteger giftCount;
        BOOL isHaveFullCut = NO;
        if (_orderStoreAry.count > 0)
        {
            CZJOrderStoreForm* form = (CZJOrderStoreForm*)_orderStoreAry[section - 3];
            itemCount = form.items.count;
            giftCount = form.gifts.count;
            isHaveFullCut = [form.fullCutPrice floatValue] > 0.1;
        }
        if (_useableStoreCouponAry.count > 0)
        {
            CZJOrderStoreCouponsForm* couponForm = (CZJOrderStoreCouponsForm*)_useableStoreCouponAry[section - 3];
            isHaveFullCut = ![couponForm.selectedCouponId isEqualToString:@""];
        }
        
        return  3 + itemCount + giftCount + (isHaveFullCut ? 1 : 0);
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (_currentChooseAddr)
        {
            CZJDeliveryAddrCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDeliveryAddrCell" forIndexPath:indexPath];
            cell.addrForm = _currentChooseAddr;
            cell.deliveryNameLabel.text = _currentChooseAddr.receiver;
            cell.contactNumLabel.text = _currentChooseAddr.mobile;
            NSString* addrStr = [NSString stringWithFormat:@"%@ %@ %@ %@",_currentChooseAddr.province,_currentChooseAddr.city,_currentChooseAddr.county,_currentChooseAddr.addr];
            CGSize addrSize = [CZJUtils calculateStringSizeWithString:addrStr Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 60];
            cell.deliveryAddrrLayoutWidth.constant = addrSize.width + 10;
            cell.deliveryAddrLabel.text = addrStr;
            if (_currentChooseAddr.dftFlag)
            {
                cell.defaultLabel.hidden = NO;
                cell.defaultLabel.layer.backgroundColor = [[UIColor redColor]CGColor];
                cell.defaultLabel.layer.cornerRadius = 3;
                cell.defaultLabel.textColor = [UIColor whiteColor];
                cell.deliveryAddrLayoutLeading.constant = 70;
            }
            else
            {
                cell.defaultLabel.hidden = YES;
                cell.deliveryAddrLayoutLeading.constant = 40;
            }
            return cell;
        }
        else
        {
            CZJAddDeliveryAddrCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJAddDeliveryAddrCell" forIndexPath:indexPath];
            return cell;
        }
        
    }
    else if (1 == indexPath.section)
    {
        if (isOrderTypeExpand)
        {
            if (_orderTypeAry.count == indexPath.row)
            {
                CZJOrderTypeExpandCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeExpandCell" forIndexPath:indexPath];
                cell.expandNameLabel.text = @"收起";
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
                    cell.expandImg.transform = CGAffineTransformMakeRotation(180 * (M_PI / 180.0f));
                } completion:nil];
                cell.delegate = self;
                return cell;
            }
            else
            {
                CZJOrderTypeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeCell" forIndexPath:indexPath];
                [cell setOrderTypeForm:_orderTypeAry[indexPath.row]];
                return cell;
            }
        }
        else
        {
            if (0 == indexPath.row)
            {
                CZJOrderTypeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeCell" forIndexPath:indexPath];
                [cell setOrderTypeForm:_defaultOrderType];
                return cell;
            }
            if (1 == indexPath.row)
            {
                CZJOrderTypeExpandCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeExpandCell" forIndexPath:indexPath];
                cell.expandNameLabel.text = @"展开";
                cell.delegate = self;
                return cell;
            }
        }
    }
    else if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJRedPacketCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketCell" forIndexPath:indexPath];
            [cell.redPacketImg setImage:IMAGENAMED(@"commit_icon_yue")];
            cell.redPacketNameLabel.text = @"余额";
            cell.leftLabel.text = @"可用余额";
            cell.leftCountLabel.text = [NSString stringWithFormat:@"￥%@",[_orderInfoDict valueForKey:@"cardMoney"]];
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJRedPacketCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketCell" forIndexPath:indexPath];
            [cell.redPacketImg setImage:IMAGENAMED(@"commit_icon_hongbao")];
            cell.redPacketNameLabel.text = @"红包";
            cell.leftLabel.text = @"可用红包";
            cell.leftCountLabel.text = [NSString stringWithFormat:@"￥%@",[_orderInfoDict valueForKey:@"redpacket"]];
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJOrderCouponCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCouponCell" forIndexPath:indexPath];
            if (_useableCouponsAry.count > 0) {
                [cell setUseableCouponAry:_useableCouponsAry];
            }
            return cell;
        }
    }
    else
    {
        
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (_currentChooseAddr)
        {
            return 85;
        }
        else
        {
            return 46;
        }
        
    }
    else if (1 == indexPath.section)
    {
        if ((isOrderTypeExpand && _orderTypeAry.count == indexPath.row) ||
            (!isOrderTypeExpand && 1 == indexPath.row))
        {
            return 35;
        }
        else
        {
            return 49;
        }
    }
    else if (2 == indexPath.section)
    {
        return 44;
    }
    else
    {
        
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        touchedCell = [tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"segueToChooseAddr" sender:self];
    }
    if (2 == indexPath.section && 2 == indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueToChooseCoupons" sender:self];
    }
}


#pragma mark- CZJOrderTypeExpandCellDelegate
- (void)clickToExpandOrderType
{
    isOrderTypeExpand = !isOrderTypeExpand;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark- CZJDeliveryAddrControllerDelegate
- (void)clickChooseAddr:(CZJAddrForm*)addForm
{
    _currentChooseAddr = addForm;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark- CZJChooseCouponControllerDelegate
- (void)clickToConfirmUse
{
    [self getUsableCouponList];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToChooseCoupons"])
    {
        CZJChooseCouponController* chooseCou = segue.destinationViewController;
        chooseCou.storeIds = [_storeIdAry componentsJoinedByString:@","];
    }
    if ([segue.identifier isEqualToString:@"segueToChooseAddr"])
    {
        CZJDeliveryAddrController* deliveryCon = segue.destinationViewController;
        deliveryCon.delegate = self;
        if ([touchedCell isKindOfClass:[CZJDeliveryAddrCell class]])
        {
            deliveryCon.currentAddrId = ((CZJDeliveryAddrCell*)touchedCell).addrForm.addrId;   
        }
    }
    
}


- (IBAction)goToSettleAction:(id)sender {
}
@end
