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
#import "UIImageView+WebCache.h"


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
    NSInteger orderTotalPrice;                  //订单总额
    
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
    _useableCouponsAry = [NSMutableArray array];
    orderTotalPrice = 0;
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
    [_useableCouponsAry removeAllObjects];
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
        _totalPriceLabel.text = [NSString stringWithFormat:@"￥%ld",orderTotalPrice];
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
        NSInteger itemCount = 0;
        NSInteger giftCount = 0;
        BOOL isHaveFullCut = NO;
        CZJOrderStoreForm* storeform;
        if (_orderStoreAry.count > 0)
        {
            storeform = (CZJOrderStoreForm*)_orderStoreAry[section - 3];
            itemCount = storeform.items.count;
            giftCount = storeform.gifts.count;
            isHaveFullCut = [storeform.fullCutPrice floatValue] > 0.1;
        }
        if (_useableStoreCouponAry.count > 0)
        {
            for (CZJOrderStoreCouponsForm* couponForm in _useableStoreCouponAry )
            {
                if ([couponForm.storeId isEqualToString:storeform.storeId]) {
                    isHaveFullCut = ![couponForm.selectedCouponId isEqualToString:@""];
                }
            }
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
            [cell setUseableCouponAry:_useableCouponsAry];
            return cell;
        }
    }
    else
    {
        NSInteger totalprice = 0;           //当前门店消费费用小计
        NSInteger couponPrice = 0;          //优惠券额
        NSInteger itemCount = 0;            //商品数量
        NSInteger giftCount = 0;            //礼品数量
        BOOL isHaveFullCut = NO;            //是否有满减
        BOOL isHaveCoupon = NO;             //是否有优惠券
        CZJOrderStoreForm* storeForm;       //当前section的数据模型

        if (_orderStoreAry.count > 0)
        {
            storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 3];
            itemCount = storeForm.items.count;
            giftCount = storeForm.gifts.count;
            isHaveFullCut = [storeForm.fullCutPrice floatValue] > 0.1;
            for (int i = 0; i < itemCount; i++)
            {
                CZJOrderGoodsForm* form = storeForm.items[i];
                totalprice += [form.currentPrice integerValue] * [form.itemCount integerValue];
            }
            totalprice -= [storeForm.fullCutPrice integerValue];
        }
        if (_useableStoreCouponAry.count > 0)
        {
            for (CZJOrderStoreCouponsForm* couponForm in _useableStoreCouponAry )
            {
                if ([couponForm.storeId isEqualToString:storeForm.storeId]) {
                    isHaveCoupon = ![couponForm.selectedCouponId isEqualToString:@""];
                    for (CZJShoppingCouponsForm* shoppingForm in couponForm.coupons)
                    {
                        if ([shoppingForm.couponId isEqualToString:couponForm.selectedCouponId])
                        {
                            couponPrice = [shoppingForm.value integerValue];
                            totalprice -= couponPrice;
                            break;
                        }
                    }
                }
            }
        }
        NSInteger fullcutCount = (isHaveFullCut || isHaveCoupon) ? 1 : 0;
        if (totalprice < 59)
        {
            totalprice += [storeForm.transportPrice integerValue];
        }
        
        
        if (0 == indexPath.row)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"storeHeaer"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"storeHeaer"];
            }
            
            [cell.imageView setImage:IMAGENAMED(storeForm.selfFlag ? @"commit_icon_ziying" : @"commit_icon_shop")];
            cell.textLabel.text = storeForm.storeName;
            return cell;
        }
        else if (indexPath.row > 0 &&
                 indexPath.row <= itemCount)
        {
            CZJOrderGoodsForm* goodsForm = storeForm.items[indexPath.row - 1];
            CZJOrderProductHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductHeaderCell" forIndexPath:indexPath];
            [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:nil];
            cell.goodsNameLabel.text = goodsForm.itemName;
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%@",goodsForm.currentPrice];
            cell.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
            cell.goodsTypeLabel.text = goodsForm.itemSku;
            cell.setupView.hidden = !goodsForm.setupFlag;
            cell.goodsNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 68 -15 - 8 - 15;
            cell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%ld",[goodsForm.itemCount integerValue] * [goodsForm.currentPrice integerValue]];
            return cell;
        }
        else if (indexPath.row > itemCount &&
                 indexPath.row <= itemCount + fullcutCount)
        {
            CZJPromotionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJPromotionCell" forIndexPath:indexPath];
            cell.nameOneLabel.hidden = YES;
            cell.nameOneNumLabel.hidden = YES;
            cell.nameTwoLabel.hidden = YES;
            cell.nameTwoNumLabel.hidden = YES;
            cell.nameOneLabel.text = @"";
            cell.nameOneNumLabel.text = @"";
            cell.nameTwoLabel.text = @"";
            cell.nameTwoNumLabel.text = @"";
            if (isHaveCoupon && !isHaveFullCut)
            {
                cell.nameOneLabel.hidden = NO;
                cell.nameOneNumLabel.hidden = NO;
                cell.nameTwoLabel.hidden = YES;
                cell.nameTwoNumLabel.hidden = YES;
                cell.nameOneLabel.text = @"优惠券:";
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%ld", couponPrice];
            }
            else if (isHaveFullCut && !isHaveCoupon)
            {
                cell.nameOneLabel.hidden = NO;
                cell.nameOneNumLabel.hidden = NO;
                cell.nameTwoLabel.hidden = YES;
                cell.nameTwoNumLabel.hidden = YES;
                cell.nameOneLabel.text = @"促销满减:";
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%@",storeForm.fullCutPrice];
            }
            else
            {
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%ld",couponPrice];
                cell.nameTwoNumLabel.text = [NSString stringWithFormat:@"-￥%@",storeForm.fullCutPrice];
            }
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount&&
                 indexPath.row <= itemCount + fullcutCount + 1)
        {
            CZJOrderProductFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductFooterCell" forIndexPath:indexPath];
            NSString* transportPriceStr = [NSString stringWithFormat:@"￥%@",totalprice > 59 ? @"0" :storeForm.transportPrice];
            cell.transportPriceLabel.text = transportPriceStr;
            cell.totalLabel.text = [NSString stringWithFormat:@"￥%ld",totalprice];
            cell.transportPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:transportPriceStr AndFontSize:14].width + 5;
            orderTotalPrice += totalprice;
            _totalPriceLabel.text = [NSString stringWithFormat:@"￥%ld",orderTotalPrice];
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount + 1 &&
                 indexPath.row <= itemCount + fullcutCount + giftCount)
        {
            CZJGiftCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGiftCell" forIndexPath:indexPath];
            return cell;
        }
        else
        {
            CZJLeaveMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJLeaveMessageCell" forIndexPath:indexPath];
            return cell;
        }
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

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
        NSInteger itemCount = 0;
        NSInteger giftCount = 0;
        BOOL isHaveFullCut = NO;
        CZJOrderStoreForm* storeForm;
        if (_orderStoreAry.count > 0)
        {
            storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 3];
            itemCount = storeForm.items.count;
            giftCount = storeForm.gifts.count;
            isHaveFullCut = [storeForm.fullCutPrice floatValue] > 0.1;
        }
        if (_useableStoreCouponAry.count > 0)
        {
            for (CZJOrderStoreCouponsForm* couponForm in _useableStoreCouponAry )
            {
                if ([couponForm.storeId isEqualToString:storeForm.storeId])
                {
                    isHaveFullCut = ![couponForm.selectedCouponId isEqualToString:@""];
                }
            }
        }
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (indexPath.row > 0 &&
                 indexPath.row <= itemCount)
        {
            CZJOrderGoodsForm* goodsForm = storeForm.items[indexPath.row - 1];
            if (goodsForm.setupFlag)
            {
                return 138;
            }
            else
            {
                return 108;
            }
        }
        else if (indexPath.row > itemCount &&
                 indexPath.row <= (isHaveFullCut ? 2 : 1))
        {
            return 44;
        }
        else if (indexPath.row > itemCount + (isHaveFullCut ? 2 : 1) &&
                 indexPath.row <= itemCount + (isHaveFullCut ? 2 : 1) + giftCount)
        {
            return 30;
        }
        else
        {
            return 60;
        }
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
    [self.myTableView reloadData];
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%ld",orderTotalPrice];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToChooseCoupons"])
    {
        CZJChooseCouponController* chooseCou = segue.destinationViewController;
        chooseCou.delegate = self;
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
