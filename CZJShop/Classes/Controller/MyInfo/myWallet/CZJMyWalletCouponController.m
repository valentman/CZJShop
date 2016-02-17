//
//  CZJMyWalletCouponController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletCouponController.h"
#import "CZJPageControlView.h"
#import "PullTableView.h"
#import "CZJReceiveCouponsCell.h"

@interface CZJMyWalletCouponController ()

@end

@implementation CZJMyWalletCouponController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)initViews
{
    CZJMyWalletCouponUnUsedController* unUsed = [[CZJMyWalletCouponUnUsedController alloc]init];
    CZJMyWalletCouponUsedController* used = [[CZJMyWalletCouponUsedController alloc]init];
    CZJMyWalletCouponOutOfTimeController* outOfTime = [[CZJMyWalletCouponOutOfTimeController alloc]init];
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT);
    CZJPageControlView* pageview = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:0];
    [pageview setTitleArray:@[@"未使用",@"已使用",@"已过期"] andVCArray:@[unUsed, used, outOfTime]];
    [self.view addSubview:pageview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end



@interface CZJMyWalletCouponListBaseController ()
<
UITableViewDataSource,
UITableViewDelegate,
PullTableViewDelegate
>
{
    
}
@property (strong, nonatomic)NSMutableArray* couponList;
@property (strong, nonatomic)PullTableView* myTableView;
@end
@implementation CZJMyWalletCouponListBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    _couponList = [NSMutableArray array];
    [self initViews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.myTableView.pullTableIsRefreshing = NO;
    self.myTableView.pullTableIsLoadingMore = NO;
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 128);
    _myTableView = [[PullTableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    
    _myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
}

- (void)getCouponListFromServer
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _couponList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJReceiveCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJReceiveCouponsCell" forIndexPath:indexPath];
//    cell.couponsViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 40;
//    CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)_storeCoupons[indexPath.row - 1];
//    NSString* priceStri = [NSString stringWithFormat:@"￥%@",couponForm.value];
//    CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(40)];
//    cell.couponPriceLabelLayout.constant = priceSize.width + 5;
//    cell.couponPriceLabel.text = priceStri;
//    
//    NSString* storeNameStr = couponForm.storeName;
//    int width = PJ_SCREEN_WIDTH - 40 - 80 - priceSize.width - 10;
//    CGSize storeNameSize = [storeNameStr boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: BOLDSYSTEMFONT(15)} context:nil].size;
//    cell.storeNameLabelLayoutheight.constant = storeNameSize.height;
//    cell.storeNameLabelLayoutWidth.constant = width;
//    cell.storeNameLabel.text = storeNameStr;
//    cell.receiveTimeLabel.text = couponForm.validEndTime;
//    cell.useableLimitLabel.text = couponForm.name;
//    
//    
//    NSString* bgImgStr;
//    if ([couponForm.type integerValue] == 3)
//    {
//        bgImgStr = @"coupon_icon_base_blue";
//    }
//    else
//    {
//        bgImgStr = @"coupon_icon_base_red";
//    }
//    [cell.couponBgImg setImage:IMAGENAMED(bgImgStr)];
//    cell.couponPriceLabel.textColor = [UIColor redColor];
//    cell.storeNameLabel.textColor = [UIColor redColor];
//    [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
//        cell.couponsViewLeadingToSuperView.constant = [storeCouponForm.selectedCouponId isEqualToString:couponForm.couponId] ? 40 : 20;
//    } completion:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

#pragma mark- pullTableviewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    
}

@end


@implementation CZJMyWalletCouponUnUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCouponUnUsedListFromServer];
}

- (void)getCouponUnUsedListFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

@implementation CZJMyWalletCouponUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCouponUsedListFromServer];
}

- (void)getCouponUsedListFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

@implementation CZJMyWalletCouponOutOfTimeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCouponOutOfTimeListFromServer];
}

- (void)getCouponOutOfTimeListFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

