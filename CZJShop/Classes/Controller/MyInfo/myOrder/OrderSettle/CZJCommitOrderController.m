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
#import "CZJChooseInstallController.h"
#import "CZJOrderForm.h"
#import "CZJDeliveryAddrController.h"
#import "CZJShoppingCartForm.h"
#import "CZJStoreForm.h"
#import "CZJLeaveMessageView.h"


@interface CZJCommitOrderController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJOrderTypeExpandCellDelegate,
CZJDeliveryAddrControllerDelegate,
CZJChooseCouponControllerDelegate,
CZJOrderProductHeaderCellDelegate,
CZJChooseInstallControllerDelegate,
CZJLeaveMessageViewDelegate,
CZJRedPacketCellDelegate
>
{
    CZJOrderForm* _orderForm;                   //服务器返回的订单页面是数据
    CZJOrderTypeForm* _defaultOrderType;        //默认支付方式（为支付宝）
    CZJAddrForm* _currentChooseAddr;            //当前选择地址
    
    NSArray* _orderTypeAry;                     //支付方式（支付宝，微信，银联）
    NSMutableArray* _orderStoreAry;             //订单信息中所选商品信息列表
    NSMutableArray* _storeIdAry;                //门店ID数组
    
    NSMutableArray* _useableCouponsAry;         //使用优惠券集合
    NSMutableArray* _useableStoreCouponAry;     //门店优惠券集合
    
    BOOL isOrderTypeExpand;                     //支付方式是否展开
    
    id touchedCell;
    float orderTotalPrice;                  //初始订单结算额
    float orderFinalPrice;                  //经过使用余额和红包之后的订单结算额
    NSIndexPath* _currentChooseIndexPath;       //
    
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
    [SVProgressHUD show];
    [self getSettleDataFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initDatas
{
    _orderStoreAry = [NSMutableArray array];
    _storeIdAry = [NSMutableArray array];
    _useableCouponsAry = [NSMutableArray array];
    orderTotalPrice = 0;

    _orderTypeAry = CZJBaseDataInstance.orderPaymentTypeAry;
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
    self.myTableView.backgroundColor = CLEARCOLOR;
    self.view.backgroundColor = CZJNAVIBARGRAYBG;
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
    NSDictionary* parmas = @{@"cartsJson" : [CZJUtils JsonFromData:_settleParamsAry]};
    [CZJBaseDataInstance loadSettleOrder:parmas Success:^(id json){
        [SVProgressHUD dismiss];
        _orderForm  = [CZJOrderForm objectWithKeyValues:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        _orderStoreAry = _orderForm.stores;
        [self.myTableView reloadData];
        for (CZJOrderStoreForm* form in _orderForm.stores)
        {
            [_storeIdAry addObject:form.storeId];
            for (CZJOrderGoodsForm* goodsForm in form.items)
            {
                orderTotalPrice += [goodsForm.itemCount floatValue]*[goodsForm.currentPrice floatValue];
            }
            orderTotalPrice += [form.transportPrice floatValue];
        }
        orderFinalPrice = orderTotalPrice;
        _totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f",orderFinalPrice];
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
            cell.deliveryAddrrLayoutWidth.constant = addrSize.width + 20;
            cell.deliveryAddrLabel.text = addrStr;
            if (_currentChooseAddr.dftFlag)
            {
                cell.defaultLabel.hidden = NO;
                cell.defaultLabel.layer.backgroundColor = [[UIColor redColor]CGColor];
                cell.defaultLabel.layer.cornerRadius = 3;
                cell.defaultLabel.textColor = [UIColor whiteColor];
                cell.deliveryAddrLayoutLeading.constant = 80;
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
                [cell setCellType:CZJCellTypeExpand];
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
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
                    cell.expandImg.transform = CGAffineTransformMakeRotation(0 * (M_PI / 180.0f));
                } completion:nil];
                cell.expandNameLabel.text = @"展开";
                [cell setCellType:CZJCellTypeExpand];
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
            cell.leftCountLabel.text = [NSString stringWithFormat:@"￥%.1f",[_orderForm.cardMoney floatValue]];
            cell.delegate = self;
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJRedPacketCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketCell" forIndexPath:indexPath];
            [cell.redPacketImg setImage:IMAGENAMED(@"commit_icon_hongbao")];
            cell.redPacketNameLabel.text = @"红包";
            cell.leftLabel.text = @"可用红包";
            NSString* redcount = [NSString stringWithFormat:@"￥%.1f",[_orderForm.redpacket floatValue]];
            cell.leftCountLabel.text = redcount;
            cell.redBackWidth.constant = [CZJUtils calculateStringSizeWithString:redcount Font:SYSTEMFONT(13) Width:200].width + 10;
            cell.delegate = self;
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
        float totalprice = 0;           //当前门店消费费用小计
        float couponPrice = 0;          //优惠券额
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
            [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:IMAGENAMED(@"home_btn_xiche")];
            cell.goodsNameLabel.text = goodsForm.itemName;
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%@",goodsForm.currentPrice];
            cell.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
            cell.goodsTypeLabel.text = goodsForm.itemSku;
            cell.setupView.hidden = !goodsForm.setupFlag;
            cell.goodsNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 68 -15 - 8 - 15;
            cell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f",[goodsForm.itemCount integerValue] * [goodsForm.currentPrice floatValue]];
            cell.delegate = self;
            cell.storeItemPid = goodsForm.storeItemPid;
            cell.selectedSetupStoreNameLabel.text = goodsForm.selectdSetupStoreName;
            cell.indexPath = indexPath;
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
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%.1f", couponPrice];
            }
            else if (isHaveFullCut && !isHaveCoupon)
            {
                cell.nameOneLabel.hidden = NO;
                cell.nameOneNumLabel.hidden = NO;
                cell.nameTwoLabel.hidden = YES;
                cell.nameTwoNumLabel.hidden = YES;
                cell.nameOneLabel.text = @"促销满减:";
                cell.nameOneNumLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:@"促销满减:" AndFontSize:13].width + 5;
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%@",storeForm.fullCutPrice];
            }
            else
            {
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%.1f",couponPrice];
                cell.nameTwoNumLabel.text = [NSString stringWithFormat:@"-￥%.1f",[storeForm.fullCutPrice floatValue]];
            }
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount&&
                 indexPath.row <= itemCount + fullcutCount + 1)
        {
            CZJOrderProductFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductFooterCell" forIndexPath:indexPath];
            NSString* transportPriceStr = [NSString stringWithFormat:@"￥%@",totalprice > 59 ? @"0" :storeForm.transportPrice];
            cell.transportPriceLabel.text = transportPriceStr;
            cell.totalLabel.text = [NSString stringWithFormat:@"￥%.1f",totalprice];
            cell.transportPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:transportPriceStr AndFontSize:14].width + 5;
            
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
            cell.leaveMessageLabel.text = @"";
            if (![storeForm.note isEqualToString:@""]) {
                cell.leaveMessageView.hidden = YES;
                CGSize size = [CZJUtils calculateStringSizeWithString:storeForm.note Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 30];
                cell.leaveMessageLabel.text = storeForm.note;
                cell.leaveMessageLayoutHeight.constant = size.height;
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, size.height + 30);
            }
            else
            {
                cell.leaveMessageView.hidden = NO;
            }
            cell.separatorInset = HiddenCellSeparator;
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
                 indexPath.row <= itemCount + (isHaveFullCut ? 2 : 1))
        {
            return 44;
        }
        else if (indexPath.row > itemCount + (isHaveFullCut ? 2 : 1) &&
                 indexPath.row <= itemCount + (isHaveFullCut ? 2 : 1) + giftCount)
        {
            return 30;
        }
        else if (indexPath.row > itemCount + (isHaveFullCut ? 2 : 1) + giftCount &&
                 indexPath.row <= itemCount + (isHaveFullCut ? 2 : 1) + giftCount + 1)
        {
            CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 3];
            CGSize size = [CZJUtils calculateStringSizeWithString:storeForm.note Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 30];
            if (size.height == 0)
            {
                return 56;
            }
            else
            {
                return  60 + size.height;
            }
            
        }
        else
        {
            return 44;
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
    else if (1 == indexPath.section)
    {
        for ( int i = 0; i < _orderTypeAry.count; i++)
        {
            CZJOrderTypeForm* typeForm = _orderTypeAry[i];
            typeForm.isSelect = NO;
            if (i == indexPath.row)
            {
                typeForm.isSelect = YES;
                _defaultOrderType = typeForm;
            }
        }
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (2 == indexPath.section && 2 == indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueToChooseCoupons" sender:self];
    }
    else
    {
        touchedCell = [tableView cellForRowAtIndexPath:indexPath];
        if ([touchedCell isKindOfClass:[CZJLeaveMessageCell class]])
        {
            _currentChooseIndexPath = indexPath;
            [self performSegueWithIdentifier:@"segueToLeaveMessage" sender:self];
        }
    }
    
}


//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
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

#pragma mark- CZJRedPacketCellDelegate
- (void)clickToUseRedPacketCallBack:(id)sender andName:(NSString *)typeName
{
    float useableCount = 0;
    if ([typeName isEqualToString:@"余额"])
    {
        useableCount = [_orderForm.cardMoney floatValue];
    }
    if ([typeName isEqualToString:@"红包"])
    {
        useableCount = [_orderForm.redpacket floatValue];

    }
    if (useableCount > orderTotalPrice)
    {
        if (((UIButton*)sender).selected)
        {
            orderFinalPrice = 0;
        }
        else
        {
            orderFinalPrice = orderTotalPrice;
        }
    }
    else
    {
        if (((UIButton*)sender).selected)
        {
            orderFinalPrice = orderTotalPrice - useableCount;
        }
        else
        {
            orderFinalPrice += useableCount;
        }
        
    }
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f",orderFinalPrice];
}

#pragma mark- CZJChooseCouponControllerDelegate
- (void)clickToConfirmUse
{
    [self getUsableCouponList];
    [self.myTableView reloadData];
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f",orderFinalPrice];
}

#pragma mark- CZJOrderProductHeaderCellDelegate
- (void)clickChooseSetupPlace:(id)sender andIndexPath:(NSIndexPath*)indexPath
{
    [self performSegueWithIdentifier:@"segueToChooseInstallStore" sender:sender];
    _currentChooseIndexPath = indexPath;
}

#pragma mark- CZJChooseInstallControllerDelegate
- (void)clickSelectInstallStore:(id)sender
{
    CZJNearbyStoreForm* nearByStoreForm = (CZJNearbyStoreForm*)sender;
    CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 3];
    CZJOrderGoodsForm* goodsForm = storeForm.items[_currentChooseIndexPath.row - 1];
    goodsForm.selectdSetupStoreName = nearByStoreForm.name;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:_currentChooseIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark- CZJLeaveMessageViewDelegate
- (void)clickConfirmMessage:(NSString*)message
{
    CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 3];
    storeForm.note = message;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:_currentChooseIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
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
            CZJAddrForm* addform = ((CZJDeliveryAddrCell*)touchedCell).addrForm;
            deliveryCon.currentAddrId = addform.addrId;
        }
    }
    if ([segue.identifier isEqualToString:@"segueToChooseInstallStore"])
    {
        CZJChooseInstallController* installCon = (CZJChooseInstallController*)segue.destinationViewController;
        installCon.storeItemPid = (NSString*)sender;
        installCon.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"segueToLeaveMessage"])
    {
        CZJLeaveMessageView* leaveMessage = (CZJLeaveMessageView*)segue.destinationViewController;
        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 3];
        leaveMessage.leaveMesageStr =  storeForm.note;
        leaveMessage.delegate = self;
    }
}

- (IBAction)goToSettleAction:(id)sender
{
    NSMutableArray* _convertOrderStoreAry = [NSMutableArray array];
    for (CZJOrderStoreForm* form in _orderStoreAry)
    {
        [_convertOrderStoreAry addObject: form.keyValues];
    }
    NSMutableDictionary* orderInfo = [@{@"redpacket":_orderForm.redpacket,
                                        @"cardMoney":_orderForm.cardMoney,
                                        @"stores":_convertOrderStoreAry,
                                        @"totalMoney":[NSString stringWithFormat:@"%ld",orderTotalPrice]}
                                      mutableCopy];
    if (_orderForm.needAddr) {
        if (_currentChooseAddr) {
            [orderInfo setObject:_currentChooseAddr.keyValues forKey:@"receiver"];
        }
        else
        {
            [CZJUtils tipWithText:@"请填写收货人地址" andView:self.view];
            return;
        }
    }
    NSDictionary* params = @{@"paramJson":[CZJUtils JsonFromData:orderInfo]};
    [CZJBaseDataInstance submitOrder:params Success:^(id json) {
        
    } fail:^{
        
    }];
}
@end
