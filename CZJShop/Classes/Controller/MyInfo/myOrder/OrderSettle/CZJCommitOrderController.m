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
#import "CZJOrderPaySuccessController.h"


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
CZJRedPacketCellDelegate,
CZJNaviagtionBarViewDelegate
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
    BOOL isNeedReceiveAddr;                     //是否需要地址（商品和选择自行安装服务需要地址，选择门店安装不定需要地址）
    BOOL isHaveSelfShop;                        //是否有车之健自营商品
    BOOL isRedPacketSelectd;                    //红包是否选中
    BOOL isBalanceSelectd;                      //余额是否选中
    
    id touchedCell;
    float orderTotalPrice;                      //初始订单结算额
    float orderFinalPrice;                      //经过使用余额和红包之后的订单结算额
    float useRedPacketPrice;                    //红包使用值
    float useBalancePrice;                      //余额使用值
    NSIndexPath* _currentChooseIndexPath;       //
    
    NSString* choosedRedPacketName;             //选择红包名称（余额、红包）
    NSString* choosedBalanceName;               //选择的余额
    UIButton* choosedRedPacketBtn;              //对应的按钮
    
    NSString* selfShopName;                     //车之健自营名称。
    
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

- (void)setIsUseCouponAble:(BOOL)isUseCouponAble
{
    _isUseCouponAble = isUseCouponAble;
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
    DLog(@"commitData: %@",[[CZJUtils JsonFromData:_settleParamsAry] description]);
    NSDictionary* parmas = @{@"cartsJson" : [CZJUtils JsonFromData:_settleParamsAry]};
    [CZJBaseDataInstance loadSettleOrder:parmas Success:^(id json){
        DLog(@"feedbackData: %@",[[CZJUtils DataFromJson:json] description]);
        _orderForm  = [CZJOrderForm objectWithKeyValues:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        _orderStoreAry = [_orderForm.stores mutableCopy];
        [self dealWithOrderFormDatas];
    } fail:^{
        
    }];
}

- (void)dealWithOrderFormDatas
{
    orderFinalPrice = 0;
    orderTotalPrice = 0;
    useRedPacketPrice = 0;
    useBalancePrice = 0;
    float totalCouponPrice = 0;
    float totalSelfShopPrice = 0;
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
        totalCouponPrice += [form.couponPrice floatValue];
        storeTotalPrice -= [form.fullCutPrice floatValue];
        storeTotalPrice -= [form.couponPrice floatValue];
        storeTotalPrice += [form.transportPrice floatValue];
        storeTotalPrice += storeTotalSetupPrice;
        storeTotalPrice = storeTotalPrice < 0 ? 0 : storeTotalPrice;
        form.orderMoney = [NSString stringWithFormat:@"%.2f",storeTotalPrice];
        
        //单个门店安装费
        form.totalSetupPrice = [NSString stringWithFormat:@"%.2f",storeTotalSetupPrice];
        isNeedReceiveAddr = !storeTotalSetupPrice > 0.01;
        
        //判断当前门店是否是自营店、获取自营店名称以及自营店商品结算额
        if (form.selfFlag)
        {
            isHaveSelfShop = YES;
            selfShopName = form.storeName;
            totalSelfShopPrice = storeTotalPrice;
        }
        
        //单个门店留言，默认为空
        form.note = @"";
        
        //订单总额
        orderTotalPrice += storeTotalPrice;
    }
    orderFinalPrice = orderTotalPrice - useBalancePrice - useRedPacketPrice;
    
    float useableCount = [_orderForm.redpacket floatValue];
    if (!isRedPacketSelectd)
    {
        useRedPacketPrice = 0;
    }
    else
    {
        if (useableCount >= totalSelfShopPrice )
        {
            useRedPacketPrice = totalSelfShopPrice;
        }
        else
        {
            useRedPacketPrice =  useableCount;
        }
    }
    orderFinalPrice = orderTotalPrice - useBalancePrice - useRedPacketPrice;
    

    useableCount = [_orderForm.cardMoney floatValue];
    if (!isBalanceSelectd)
    {
        useBalancePrice = 0;
    }
    else
    {
        if (useableCount >= orderFinalPrice )
        {
            useBalancePrice = orderFinalPrice;
        }
        else
        {
            useBalancePrice = useableCount;
        }
    }
    orderFinalPrice = orderTotalPrice - useBalancePrice - useRedPacketPrice;
    
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",orderFinalPrice];
    [self.myTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5 + _orderStoreAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else if (1 == section)
    {//付款方式选择
        if (isOrderTypeExpand) {
            return _orderTypeAry.count + 1;
        }
        else
        {
            return 2;
        }
    }
    else if (2 == section)
    {//余额
        return 1;
    }
    else if (3 == section)
    {//红包
        return isHaveSelfShop ? 1 : 0;
    }
    else if (4 == section)
    {//优惠券
        return _isUseCouponAble ? 1 : 0;
    }
    else
    {//门店商品
        NSInteger itemCount = 0;
        NSInteger giftCount = 0;
        BOOL isHaveFullCut = NO;
        CZJOrderStoreForm* storeform = (CZJOrderStoreForm*)_orderStoreAry[section - 5];
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
                cell.defaultLabel.layer.backgroundColor = CZJREDCOLOR.CGColor;
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
        CZJRedPacketCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketCell" forIndexPath:indexPath];
        [cell.redPacketImg setImage:IMAGENAMED(@"commit_icon_yue")];
        cell.redPacketNameLabel.text = @"余额";
        cell.leftLabel.text = @"可用余额:";
        NSString* balance = [NSString stringWithFormat:@"￥%.2f",[_orderForm.cardMoney floatValue] - useBalancePrice];
        cell.leftCountLabel.text = balance;
        cell.redBackWidth.constant = [CZJUtils calculateStringSizeWithString:balance Font:SYSTEMFONT(13) Width:200].width + 10;
        cell.delegate = self;
        return cell;
    }
    else if (3 == indexPath.section)
    {
        CZJRedPacketCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketCell" forIndexPath:indexPath];
        [cell.redPacketImg setImage:IMAGENAMED(@"commit_icon_hongbao")];
        cell.redPacketNameLabel.text = @"红包";
        cell.leftLabel.text = @"可用红包:";
        cell.descLabel.text = [NSString stringWithFormat:@"(仅限%@)",selfShopName];
        NSString* redcount = [NSString stringWithFormat:@"￥%.2f",[_orderForm.redpacket floatValue] - useRedPacketPrice];
        cell.leftCountLabel.text = redcount;
        cell.redBackWidth.constant = [CZJUtils calculateStringSizeWithString:redcount Font:SYSTEMFONT(13) Width:200].width + 10;
        cell.delegate = self;
        return cell;
    }
    else if (4 == indexPath.section)
    {
        CZJOrderCouponCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCouponCell" forIndexPath:indexPath];
        [cell setUseableCouponAry:_useableCouponsAry];
        return cell;
    }
    else
    {
        NSInteger itemCount = 0;            //商品数量
        NSInteger giftCount = 0;            //礼品数量
        BOOL isHaveFullCut = NO;            //是否有满减
        BOOL isHaveCoupon = NO;             //是否有优惠券

        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 5];
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
                cell.setupPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:setupPriceStr AndFontSize:14].width + 5;
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
    if (0 == section ||
        3 == section ||
        4 == section)
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
    else if (2 == indexPath.section ||
             3 == indexPath.section ||
             4 == indexPath.section)
    {
        return 44;
    }
    else
    {
        NSInteger itemCount = 0;
        NSInteger giftCount = 0;
        BOOL isHaveFullCut = NO;
        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 5];
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
            CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[indexPath.section - 5];
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
        if (isOrderTypeExpand)
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
    }
    else if (4 == indexPath.section)
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
    if (!((UIButton*)sender).selected)
    {
        if (orderFinalPrice <= 0)
        {//如果支付额已经为0了，点击不可用
            [CZJUtils tipWithText:[NSString stringWithFormat:@"支付额已经为0,%@不可用",typeName] andView:self.view];
            return;
        }
        if (([typeName isEqualToString:@"余额"] && [_orderForm.cardMoney floatValue] <= 0)||
            ([typeName isEqualToString:@"红包"] && [_orderForm.redpacket floatValue] <= 0))
        {//余额或者红包为0时，点击不可用
            return;
        }
    }
    choosedRedPacketBtn = (UIButton*)sender;
    choosedRedPacketName = typeName;
    if ([choosedRedPacketName isEqualToString:@"余额"])
    {
        choosedRedPacketBtn.selected = !choosedRedPacketBtn.selected;
        isBalanceSelectd = choosedRedPacketBtn.selected;
    }
    if ([choosedRedPacketName isEqualToString:@"红包"])
    {
        choosedRedPacketBtn.selected = !choosedRedPacketBtn.selected;
        isRedPacketSelectd = choosedRedPacketBtn.selected;
    }
    
    [self dealWithOrderFormDatas];
}

#pragma mark- CZJChooseCouponControllerDelegate
- (void)clickToConfirmUse:(NSMutableArray*)choosedCouponAry
{//更新门店的优惠券使用
    [_useableCouponsAry removeAllObjects];
    _useableCouponsAry = choosedCouponAry;
    for (CZJOrderStoreForm* storeForm in _orderStoreAry)
    {
        storeForm.couponPrice = @"0";
        storeForm.chezhuCouponPid = @"";
        for (CZJShoppingCouponsForm* couposForm in _useableCouponsAry)
        {
            if ([storeForm.storeId isEqualToString:couposForm.storeId])
            {
                storeForm.couponPrice = couposForm.value;
                storeForm.chezhuCouponPid = couposForm.chezhuCouponPid;
            }
        }
    }
    [self dealWithOrderFormDatas];
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",orderFinalPrice];
}


#pragma mark- CZJOrderProductHeaderCellDelegate
- (void)clickChooseSetupPlace:(id)sender andIndexPath:(NSIndexPath*)indexPath
{
    _currentChooseIndexPath = indexPath;
    [self performSegueWithIdentifier:@"segueToChooseInstallStore" sender:sender];
}

#pragma mark- CZJChooseInstallControllerDelegate
- (void)clickSelectInstallStore:(id)sender
{//更新商品的安装费用
    CZJNearbyStoreForm* nearByStoreForm = (CZJNearbyStoreForm*)sender;
    CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 5];
    CZJOrderGoodsForm* goodsForm = storeForm.items[_currentChooseIndexPath.row - 1];
    goodsForm.selectdSetupStoreName = nearByStoreForm.name;
    goodsForm.setupPrice = nearByStoreForm.setupPrice;
    goodsForm.setupStoreId = nearByStoreForm.storeId;
    [self dealWithOrderFormDatas];
}

#pragma mark- CZJLeaveMessageViewDelegate
- (void)clickConfirmMessage:(NSString*)message
{
    CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 5];
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
        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 5];
        CZJOrderGoodsForm* goodsForm = storeForm.items[_currentChooseIndexPath.row - 1];
        installCon.delegate = self;
        installCon.orderGoodsForm = goodsForm;
    }
    if ([segue.identifier isEqualToString:@"segueToLeaveMessage"])
    {
        CZJLeaveMessageView* leaveMessage = (CZJLeaveMessageView*)segue.destinationViewController;
        CZJOrderStoreForm* storeForm = (CZJOrderStoreForm*)_orderStoreAry[_currentChooseIndexPath.section - 5];
        leaveMessage.leaveMesageStr =  storeForm.note;
        leaveMessage.delegate = self;
    }
}

- (IBAction)goToSettleAction:(id)sender
{
    DLog(@"点击提交订单！！");
    NSMutableArray* _convertOrderStoreAry = [NSMutableArray array];
    for (CZJOrderStoreForm* form in _orderStoreAry)
    {
        [_convertOrderStoreAry addObject: form.keyValues];
    }
    NSMutableDictionary* orderInfo = [@{@"redpacket":[NSString stringWithFormat:@"%.2f",useRedPacketPrice],
                                        @"cardMoney":[NSString stringWithFormat:@"%.2f",useBalancePrice],
                                        @"stores":_convertOrderStoreAry,
                                        @"totalMoney":[NSString stringWithFormat:@"%.2f",orderFinalPrice]}
                                      mutableCopy];
    //收货地址
    if (_orderForm.needAddr) {
        if (_currentChooseAddr)
        {
            [orderInfo setObject:_currentChooseAddr.keyValues forKey:@"receiver"];
        }
        else if (isNeedReceiveAddr)
        {
            [CZJUtils tipWithText:@"请填写收货人地址" andView:self.view];
            [self.myTableView setContentOffset:CGPointMake(0,0) animated:YES];
            return;
        }
    }
    
    //获取支付订单编号
    NSDictionary* params = @{@"paramJson":[CZJUtils JsonFromData:orderInfo]};
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].mode = MBProgressHUDModeIndeterminate;
    [CZJBaseDataInstance submitOrder:params Success:^(id json) {
        DLog(@"服务器请求订单编号返回");
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        [NSThread sleepForTimeInterval:1.0f];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[dict valueForKey:@"totalMoney"] floatValue] <= 0.0)
        {
            CZJOrderPaySuccessController* paySuccessVC = (CZJOrderPaySuccessController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDPaymentSuccess];
            paySuccessVC.orderNo = [dict valueForKey:@"payNo"];
            paySuccessVC.orderPrice = [dict valueForKey:@"totalMoney"];
            [weak.navigationController pushViewController:paySuccessVC animated:YES];
        }
        else
        {
            CZJPaymentOrderForm* paymentOrderForm = [[CZJPaymentOrderForm alloc] init];
            paymentOrderForm.order_no = [dict valueForKey:@"payNo"];
            paymentOrderForm.order_name = [NSString stringWithFormat:@"订单%@",[dict valueForKey:@"payNo"]];
            paymentOrderForm.order_description = @"支付宝你个SB";
            paymentOrderForm.order_price = [dict valueForKey:@"totalMoney"];
            paymentOrderForm.order_for = @"pay";
            if ([_defaultOrderType.orderTypeName isEqualToString:@"微信支付"])
            {
                DLog(@"提交订单页面请求微信支付");
                [CZJPaymentInstance weixinPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
                } Fail:^(NSDictionary *message, NSError *error) {
                    [CZJUtils tipWithText:@"微信支付失败" andView:weak.view];
                }];
            }
            if ([_defaultOrderType.orderTypeName isEqualToString:@"支付宝支付"])
            {
                DLog(@"提交订单页面请求支付宝支付");
                [CZJPaymentInstance aliPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
                } Fail:^(NSDictionary *message, NSError *error) {
                    [CZJUtils tipWithText:@"支付宝支付失败" andView:weak.view];
                }];
            }
        }

    } fail:^{
        
    }];
}

- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarBack:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

@end
