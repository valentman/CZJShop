//
//  CZJChooseCouponController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChooseCouponController.h"
#import "CZJBaseDataManager.h"
#import "CZJReceiveCouponsCell.h"
#import "CZJOrderCouponHeaderCell.h"
#import "CZJOrderForm.h"
#import "CZJShoppingCartForm.h"
@interface CZJChooseCouponController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* _storeAry;
    NSMutableArray* _choosedCouponAry;
}
@property (weak, nonatomic) IBOutlet UITableView *chooseCouponTableView;
- (IBAction)confirmToUseAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end

@implementation CZJChooseCouponController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"选择优惠券";
    _storeAry = [NSArray array];
    _choosedCouponAry = [NSMutableArray array];
    
    UINib* nib1 = [UINib nibWithNibName:@"CZJOrderCouponHeaderCell" bundle:nil];
    UINib* nib2 = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [self.chooseCouponTableView registerNib:nib1 forCellReuseIdentifier:@"CZJOrderCouponHeaderCell"];
    [self.chooseCouponTableView registerNib:nib2 forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
    self.chooseCouponTableView.delegate = self;
    self.chooseCouponTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.chooseCouponTableView.tableFooterView = [[UIView alloc] init];
    self.chooseCouponTableView.backgroundColor = CZJTableViewBGColor;
    
    [self getCouponsListFromServer];
}

- (void)getCouponsListFromServer
{
    NSMutableArray* _storeIds = [NSMutableArray array];
    for (CZJOrderStoreForm* form in _orderStores)
    {
        [_storeIds addObject:form.storeId];
    }
    NSDictionary* params = @{@"storeIds" : [_storeIds componentsJoinedByString:@","]};
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray* tmpAry = [dict valueForKey:@"msg"];
        _storeAry = [CZJOrderStoreCouponsForm objectArrayWithKeyValuesArray:tmpAry];
        [weak dealWithCouponData];
    } andServerAPI:kCZJServerAPIGetUseableCouponList];
}

- (void)dealWithCouponData
{
    for (CZJOrderStoreCouponsForm* storeCouponsForm in _storeAry)
    {
        CZJOrderStoreForm* storeForm = [self getOrderStoreFormWithStoreId:storeCouponsForm.storeId];
        NSMutableArray* storeCouponAry = storeCouponsForm.coupons;
        NSArray * array = [NSArray arrayWithArray: storeCouponAry];
        for (CZJShoppingCouponsForm* couponForm in array)
        {
            if ([couponForm.validMoney floatValue] > [storeForm.orderPrice floatValue])
            {//剔除掉不满足
                [storeCouponAry removeObject:couponForm];
            }
        }
    }
    if (_choosedCoupons.count > 0)
    {
        for (CZJShoppingCouponsForm* couponForm in _choosedCoupons)
        {
            for (CZJOrderStoreCouponsForm* storeCouponsForm in _storeAry)
            {
                if ([couponForm.storeId isEqualToString:storeCouponsForm.storeId])
                {
                    storeCouponsForm.selectedCouponId = couponForm.couponId;
                }
            }
        }
        _choosedCouponAry = [_choosedCoupons mutableCopy];
    }
    [_chooseCouponTableView reloadData];
    [self countCoupons];
}

- (CZJOrderStoreForm*)getOrderStoreFormWithStoreId:(NSString*)storeId
{
    CZJOrderStoreForm* storeForm;
    for (storeForm in _orderStores)
    {
        if ([storeId isEqualToString:storeForm.storeId])
        {
            break;
        }
    }
    return storeForm;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _storeAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((CZJOrderStoreCouponsForm*)_storeAry[section]).coupons.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJOrderStoreCouponsForm* storeCouponForm = (CZJOrderStoreCouponsForm*)_storeAry[indexPath.section];
    NSArray* _storeCoupons = storeCouponForm.coupons;
    if (0 == indexPath.row)
    {
        CZJOrderCouponHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCouponHeaderCell" forIndexPath:indexPath];
        NSString* storeName = storeCouponForm.storeName;
        CGSize storeNameSize = [CZJUtils calculateStringSizeWithString:storeName Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 60];
        cell.storeNameLayoutWidth.constant = storeNameSize.width;
        cell.storeName.text = storeName;
        cell.couponNumLabel.text = @"";
        cell.selfImg.highlighted = storeCouponForm.isSelfFlag;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    else
    {
        CZJReceiveCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJReceiveCouponsCell" forIndexPath:indexPath];
        cell.couponsViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 40;
        CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)_storeCoupons[indexPath.row - 1];
        NSString* priceStri = [NSString stringWithFormat:@"￥%@",couponForm.value];
        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(45)];
        cell.couponPriceLabelLayout.constant = priceSize.width + 5;
        cell.couponPriceLabel.text = priceStri;
        
        NSString* storeNameStr = couponForm.storeName;
        int width = PJ_SCREEN_WIDTH - 40 - 80 - priceSize.width - 10;
        CGSize storeNameSize = [storeNameStr boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: BOLDSYSTEMFONT(15)} context:nil].size;
        cell.storeNameLabelLayoutheight.constant = storeNameSize.height;
        cell.storeNameLabelLayoutWidth.constant = width;
        cell.storeNameLabel.text = storeNameStr;
        cell.receiveTimeLabel.text = couponForm.validEndTime;
        cell.useableLimitLabel.text = couponForm.name;
        

        NSString* bgImgStr;
        if ([couponForm.type integerValue] == 3)
        {
            bgImgStr = @"coupon_icon_base_blue";
        }
        else
        {
            bgImgStr = @"coupon_icon_base_red";
        }
        [cell.couponBgImg setImage:IMAGENAMED(bgImgStr)];
        cell.couponPriceLabel.textColor = [UIColor redColor];
        cell.storeNameLabel.textColor = [UIColor redColor];
        
        if ([storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId])
        {
            cell.couponsViewLeadingToSuperView.constant = 40;
            cell.selectBtn.hidden = NO;
            cell.selectBtn.selected = YES;
        }
        else
        {
            cell.couponsViewLeadingToSuperView.constant = 20;
            cell.selectBtn.hidden = YES;
            cell.selectBtn.selected = NO;
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        return 46;
    }
    else {
        return 160;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return;
    }
    
    CZJOrderStoreCouponsForm* storeCouponForm = (CZJOrderStoreCouponsForm*)_storeAry[indexPath.section];
    NSArray* _storeCoupons = storeCouponForm.coupons;
    CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)_storeCoupons[indexPath.row - 1];
    if ([storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId])
    {
        storeCouponForm.selectedCouponId = @"";
        [_choosedCouponAry removeObject:couponForm];
    }
    else
    {
        storeCouponForm.selectedCouponId = couponForm.couponId;
        [_choosedCouponAry addObject:couponForm];
    }
    [self countCoupons];
    [self.chooseCouponTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)countCoupons
{
    float totalCoupon = 0;
    for (CZJOrderStoreCouponsForm* storeCouponForm in _storeAry)
    {
        if (![storeCouponForm.selectedCouponId isEqualToString:@""])
        {
            NSArray* _storeCoupons = storeCouponForm.coupons;
            for (CZJShoppingCouponsForm* couponForm in _storeCoupons)
            {
                if ([storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId])
                {
                    totalCoupon += [couponForm.value floatValue];
                }
            }
        }
    }
    self.totalLabel.text = [NSString stringWithFormat:@"%.1f",totalCoupon];
}


- (IBAction)confirmToUseAction:(id)sender
{
    [self.delegate clickToConfirmUse:_choosedCouponAry];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
