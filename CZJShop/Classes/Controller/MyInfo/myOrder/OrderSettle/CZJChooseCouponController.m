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
    NSMutableArray* _storeCoupons;
}
@property (weak, nonatomic) IBOutlet UITableView *chooseCouponTableView;
- (IBAction)confirmToUseAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end

@implementation CZJChooseCouponController
@synthesize storeIds = _storeIds;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"选择优惠券";
    _storeAry = [NSArray array];
    _storeCoupons = [NSMutableArray array];
    
    UINib* nib1 = [UINib nibWithNibName:@"CZJOrderCouponHeaderCell" bundle:nil];
    UINib* nib2 = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [self.chooseCouponTableView registerNib:nib1 forCellReuseIdentifier:@"CZJOrderCouponHeaderCell"];
    [self.chooseCouponTableView registerNib:nib2 forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
    self.chooseCouponTableView.delegate = self;
    self.chooseCouponTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.chooseCouponTableView.tableFooterView = [[UIView alloc] init];
    
    [self getCouponsListFromServer];
}

- (void)getCouponsListFromServer
{
    NSDictionary* params = @{@"storeIds" : _storeIds};
    if (CZJBaseDataInstance.orderStoreCouponAry.count <= 0)
    {
        [CZJBaseDataInstance loadUseableCouponsList:params Success:^(id json) {
            _storeAry = CZJBaseDataInstance.orderStoreCouponAry;
            [_chooseCouponTableView reloadData];
        } fail:^{
            
        }];
    }
    else
    {
        _storeAry = CZJBaseDataInstance.orderStoreCouponAry;
    }
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
    _storeCoupons = storeCouponForm.coupons;
    if (0 == indexPath.row)
    {
        CZJOrderCouponHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCouponHeaderCell" forIndexPath:indexPath];
        NSString* storeName = storeCouponForm.storeName;
        CGSize storeNameSize = [CZJUtils calculateStringSizeWithString:storeName Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 60];
        cell.storeNameLayoutWidth.constant = storeNameSize.width;
        cell.storeName.text = storeName;
        cell.couponNumLabel.text = [NSString stringWithFormat:@"%ld",_storeCoupons.count];
        cell.selfImg.highlighted = storeCouponForm.isSelfFlag;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        CZJReceiveCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJReceiveCouponsCell" forIndexPath:indexPath];
        cell.couponsViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 40;
        CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)_storeCoupons[indexPath.row - 1];
        NSString* priceStri = [NSString stringWithFormat:@"￥%@",couponForm.value];
        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(40)];
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
        [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            cell.couponsViewLeadingToSuperView.constant = [storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId] ? 40 : 20;
        } completion:nil];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        return 140;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return;
    }
    CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)_storeCoupons[indexPath.row - 1];
    CZJOrderStoreCouponsForm* storeCouponForm = (CZJOrderStoreCouponsForm*)_storeAry[indexPath.section];
    if ([storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId])
    {
        storeCouponForm.selectedCouponId = @"";
    }
    else
    {
        storeCouponForm.selectedCouponId = couponForm.couponId;
    }
    
    [self.chooseCouponTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}


- (IBAction)confirmToUseAction:(id)sender
{
    [self.delegate clickToConfirmUse];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
