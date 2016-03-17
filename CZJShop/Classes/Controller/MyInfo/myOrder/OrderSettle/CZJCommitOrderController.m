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
#import "CZJPaymentManager.h"


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
    
    NSMutableArray* _useableCouponsAry;         //使用优惠券集合
    NSMutableArray* _useableStoreCouponAry;     //门店优惠券集合
    
    BOOL isOrderTypeExpand;                     //支付方式是否展开
    
    id touchedCell;
    float orderTotalPrice;                      //初始订单结算额
    float orderFinalPrice;                      //经过使用余额和红包之后的订单结算额
    NSIndexPath* _currentChooseIndexPath;       //
    
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
- (IBAction)goToSettleAction:(id)sender;

@end

@implementation CZJCommitOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [SVProgressHUD show];
    [self getSettleDataFromServer];
}


- (void)initDatas
{
    _orderStoreAry = [NSMutableArray array];
    _useableCouponsAry = [NSMutableArray array];

    //支付方式
    _orderTypeAry = CZJBaseDataInstance.orderPaymentTypeAry;
    for (CZJOrderTypeForm* form in _orderTypeAry)
    {
        if (form.isSelect)
        {
            _defaultOrderType = form;
            continue;
        }
    }
    
    //是否展开
    isOrderTypeExpand = NO;
    
    //获取默认地址
    NSDictionary* addrDict = [CZJUtils readDictionaryFromDocumentsDirectoryWithPlistName:kCZJPlistFileDefaultDeliveryAddr];
    if (addrDict)
    {
        _currentChooseAddr = [CZJAddrForm objectWithKeyValues:addrDict];
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
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"提交订单";
}

- (void)getSettleDataFromServer
{
    NSDictionary* parmas = @{@"cartsJson" : [CZJUtils JsonFromData:_settleParamsAry]};
    [CZJBaseDataInstance loadSettleOrder:parmas Success:^(id json){
        [SVProgressHUD dismiss];
        _orderForm  = [CZJOrderForm objectWithKeyValues:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        _orderStoreAry = _orderForm.stores;
        [self dealWithOrderFormDatas];
    } fail:^{
        
    }];
}

- (void)dealWithOrderFormDatas
{
    orderFinalPrice = 0;
    orderTotalPrice = 0;
    //处理订单门店总额
    for (CZJOrderStoreForm* form in _orderStoreAry)
    {
        float storeTotalPrice = 0;          //单个门店总额小计
        float storeTotalSetupPrice = 0;     //单个门店安装费小计
        for (CZJOrderGoodsForm* goodsForm in form.items)
        {
            storeTotalPrice += [goodsForm.itemCount floatValue]*[goodsForm.currentPrice floatValue];
            storeTotalSetupPrice += [goodsForm.setupPrice floatValue];
        }
        //orderPrice仅仅是单个门店商品总额（不包括优惠券、运费、安装费）
        form.orderPrice = [NSString stringWithFormat:@"%.2f",storeTotalPrice];
        
        //如果商品总额大于59，免运费
        if (storeTotalPrice > 59)
        {
            form.transportPrice = @"0";
        }
        
        //orderMoney为单个门店加上优惠、运费、安装费
        storeTotalPrice -= [form.fullCutPrice floatValue];
        storeTotalPrice -= [form.couponPrice floatValue];
        storeTotalPrice += [form.transportPrice floatValue];
        storeTotalPrice += storeTotalSetupPrice;
        storeTotalPrice = storeTotalPrice < 0 ? 0 : storeTotalPrice;
        form.orderMoney = [NSString stringWithFormat:@"%.2f",storeTotalPrice];
        
        //单个门店安装费
        form.totalSetupPrice = [NSString stringWithFormat:@"%.2f",storeTotalSetupPrice];
        
        //单个门店留言，默认为空
        form.note = @"";
        
        //订单总额
        orderTotalPrice += storeTotalPrice;
    }
    orderFinalPrice = orderTotalPrice;
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",orderFinalPrice];
    [self.myTableView reloadData];
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
        CZJOrderStoreForm* storeform = (CZJOrderStoreForm*)_orderStoreAry[section - 3];
        itemCount = storeform.items.count;
        giftCount = storeform.gifts.count;
        isHaveFullCut = ([storeform.fullCutPrice floatValue] > 0.01) || ([storeform.couponPrice floatValue] > 0.01);
        
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
        NSInteger itemCount = 0;            //商品数量
        NSInteger giftCount = 0;            //礼品数量
        BOOL isHaveFullCut = NO;            //是否有满减
        BOOL isHaveCoupon = NO;             //是否有优惠券

        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 3];
        itemCount = storeForm.items.count;
        giftCount = storeForm.gifts.count;
        isHaveFullCut = [storeForm.fullCutPrice floatValue] > 0.01;
        isHaveCoupon = [storeForm.couponPrice floatValue] > 0.01;

        NSInteger fullcutCount = (isHaveFullCut || isHaveCoupon) ? 1 : 0;
        
        
        if (0 == indexPath.row)
        {//门店名
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
        {//商品
            CZJOrderGoodsForm* goodsForm = storeForm.items[indexPath.row - 1];
            CZJOrderProductHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductHeaderCell" forIndexPath:indexPath];
            cell.delegate = self;
            
            //是否需要安装标示,以及选择的安装门店名
            cell.setupView.hidden = !goodsForm.setupFlag;
            cell.selectedSetupStoreNameLabel.text = goodsForm.selectdSetupStoreName;
            //商品图片
            [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:DefaultPlaceHolderImage];
            //商品名称
            cell.goodsNameLabel.text = goodsForm.itemName;
            cell.goodsNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 68 -15 - 8 - 15;
            //商品SKU
            cell.goodsTypeLabel.text = goodsForm.itemSku;
            //商品价格
            NSString* priceStr = [NSString stringWithFormat:@"￥%@",goodsForm.currentPrice];
            cell.priceLabel.text = priceStr;
            cell.priceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:priceStr AndFontSize:13].width + 5;
            //商品数量
            cell.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
            //单个商品小计总价
            float perGoodsTotalPrice = [goodsForm.itemCount integerValue] * [goodsForm.currentPrice floatValue];
            cell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",perGoodsTotalPrice];
            //传参数备用
            cell.storeItemPid = goodsForm.storeItemPid;
            cell.indexPath = indexPath;
            return cell;
        }
        else if (indexPath.row > itemCount &&
                 indexPath.row <= itemCount + fullcutCount)
        {//优惠券
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
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%@",storeForm.couponPrice];
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
                cell.nameOneNumLabel.text = storeForm.couponPrice;
                cell.nameTwoNumLabel.text = [NSString stringWithFormat:@"-￥%.2f",[storeForm.fullCutPrice floatValue]];
            }
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount&&
                 indexPath.row <= itemCount + fullcutCount + 1)
        {//运费商品总计
            CZJOrderProductFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductFooterCell" forIndexPath:indexPath];
            //运费
            NSString* transportPriceStr = [NSString stringWithFormat:@"+￥%@",storeForm.transportPrice];
            cell.transportPriceLabel.text = transportPriceStr;
            cell.transportPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:transportPriceStr AndFontSize:14].width + 5;
            //门店商品总计
            NSString* totalPriceStr = [NSString stringWithFormat:@"￥%@",storeForm.orderMoney];
            cell.totalLabel.text = totalPriceStr;
            cell.totalPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:totalPriceStr AndFontSize:17].width + 5;
            //安装费用总计
            cell.setupPriceLabel.hidden = YES;
            cell.setupLabel.hidden = YES;
            if ([storeForm.totalSetupPrice floatValue] > 0.01)
            {
                cell.setupPriceLabel.hidden = NO;
                cell.setupLabel.hidden = NO;
                NSString* setupPriceStr = [NSString stringWithFormat:@"+￥%@",storeForm.totalSetupPrice];
                cell.setupPriceLabel.text = setupPriceStr;
                cell.setupPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:setupPriceStr AndFontSize:12].width + 5;
            }
            
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount + 1 &&
                 indexPath.row <= itemCount + fullcutCount + giftCount)
        {//赠品
            CZJGiftCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGiftCell" forIndexPath:indexPath];
            return cell;
        }
        else
        {//留言
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
        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 3];
        itemCount = storeForm.items.count;
        giftCount = storeForm.gifts.count;
        isHaveFullCut = ([storeForm.fullCutPrice floatValue] > 0.01) || ([storeForm.couponPrice floatValue] > 0.01);
        
        if (0 == indexPath.row)
        {//门店名
            return 44;
        }
        else if (indexPath.row > 0 &&
                 indexPath.row <= itemCount)
        {//门店商品
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
        {//优惠券、门店合计
            return 44;
        }
        else if (indexPath.row > itemCount + (isHaveFullCut ? 2 : 1) &&
                 indexPath.row <= itemCount + (isHaveFullCut ? 2 : 1) + giftCount)
        {//赠品
            return 30;
        }
        else if (indexPath.row > itemCount + (isHaveFullCut ? 2 : 1) + giftCount &&
                 indexPath.row <= itemCount + (isHaveFullCut ? 2 : 1) + giftCount + 1)
        {//留言
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
    [CZJUtils writeDictionaryToDocumentsDirectory:[_currentChooseAddr.keyValues mutableCopy] withPlistName:kCZJPlistFileDefaultDeliveryAddr];
    
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark- CZJRedPacketCellDelegate  红包和余额使用
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
    {//如果红包或可用余额的金额大于需要支付的金额，则需要支付数量为0
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
- (void)clickToConfirmUse:(NSMutableArray*)choosedCouponAry
{//更新门店的优惠券使用
    _useableCouponsAry = choosedCouponAry;
    for (CZJShoppingCouponsForm* couposForm in _useableCouponsAry)
    {
        for (CZJOrderStoreForm* storeForm in _orderStoreAry)
        {
            if ([storeForm.storeId isEqualToString:couposForm.storeId])
            {
                storeForm.couponPrice = couposForm.value;
                storeForm.chezhuCouponPid = couposForm.chezhuCouponPid;
            }
        }
    }
    [self dealWithOrderFormDatas];
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
{//更新商品的安装费用
    CZJNearbyStoreForm* nearByStoreForm = (CZJNearbyStoreForm*)sender;
    CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 3];
    CZJOrderGoodsForm* goodsForm = storeForm.items[_currentChooseIndexPath.row - 1];
    goodsForm.selectdSetupStoreName = nearByStoreForm.name;
    goodsForm.setupPrice = nearByStoreForm.setupPrice;
    [self dealWithOrderFormDatas];
}

#pragma mark- CZJLeaveMessageViewDelegate
- (void)clickConfirmMessage:(NSString*)message
{
    CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 3];
    storeForm.note = message;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:_currentChooseIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToChooseCoupons"])
    {
        CZJChooseCouponController* chooseCou = segue.destinationViewController;
        chooseCou.delegate = self;
        chooseCou.orderStores = _orderStoreAry;
        chooseCou.choosedCoupons = _useableCouponsAry;
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
                                        @"totalMoney":[NSString stringWithFormat:@"%f",orderTotalPrice]}
                                      mutableCopy];
    //收货地址
    if (_orderForm.needAddr) {
        if (_currentChooseAddr)
        {
            [orderInfo setObject:_currentChooseAddr.keyValues forKey:@"receiver"];
        }
        else
        {
            [CZJUtils tipWithText:@"请填写收货人地址" andView:self.view];
            [self.myTableView setContentOffset:CGPointMake(0,0) animated:YES];
            return;
        }
    }
    
    //获取支付订单编号
    DLog(@"%@",[CZJUtils JsonFromData:orderInfo]);
    NSDictionary* params = @{@"paramJson":[CZJUtils JsonFromData:orderInfo]};
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance submitOrder:params Success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        CZJPaymentOrderForm* paymentOrderForm = [[CZJPaymentOrderForm alloc] init];
        paymentOrderForm.order_no = [dict valueForKey:@"payNo"];
        paymentOrderForm.order_name = [NSString stringWithFormat:@"订单%@",[dict valueForKey:@"payNo"]];
        paymentOrderForm.order_description = @"支付宝你个SB";
        paymentOrderForm.order_price = [dict valueForKey:@"totalMoney"];
        if ([_defaultOrderType.orderTypeName isEqualToString:@"微信支付"])
        {
            [CZJPaymentInstance weixinPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
            } Fail:^(NSDictionary *message, NSError *error) {
                [CZJUtils tipWithText:@"微信支付失败" andView:weak.view];
            }];
        }
        if ([_defaultOrderType.orderTypeName isEqualToString:@"支付宝"])
        {
            [CZJPaymentInstance aliPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
            } Fail:^(NSDictionary *message, NSError *error) {
                [CZJUtils tipWithText:@"支付宝支付失败" andView:weak.view];
            }];
        }
    } fail:^{
        
    }];
}
@end
