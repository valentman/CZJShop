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
#import "CZJBaseDataManager.h"
#import "CZJShoppingCartForm.h"

@interface CZJMyWalletCouponController ()

@end

@implementation CZJMyWalletCouponController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"优惠券";
    self.naviBarView.buttomSeparator.hidden = YES;
    
    CZJMyWalletCouponUnUsedController* unUsed = [[CZJMyWalletCouponUnUsedController alloc]init];
    CZJMyWalletCouponUsedController* used = [[CZJMyWalletCouponUsedController alloc]init];
    CZJMyWalletCouponOutOfTimeController* outOfTime = [[CZJMyWalletCouponOutOfTimeController alloc]init];
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
    CZJPageControlView* pageview = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:0];
    [pageview setTitleArray:@[@"未使用",@"已使用",@"已过期"] andVCArray:@[unUsed, used, outOfTime]];
    pageview.backgroundColor = CZJNAVIBARBGCOLOR;
    
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
@property (strong, nonatomic)NSArray* couponList;
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
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 114);
    _myTableView = [[PullTableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    
    _myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
}

- (void)getCouponListFromServer
{
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:_params success:^(id json) {
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        _couponList = [CZJShoppingCouponsForm objectArrayWithKeyValuesArray:dict];
        if (_couponList.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有对应优惠券/(ToT)/~~"];
            self.view.hidden = YES;
        }
        else
        {
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            self.myTableView.pullDelegate = self;
            [self.myTableView reloadData];
        }
    }  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getCouponListFromServer];
        }];
    } andServerAPI:kCZJServerAPIShowCouponsList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _couponList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJReceiveCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJReceiveCouponsCell" forIndexPath:indexPath];
    cell.selectBtn.hidden = YES;
    cell.receivedImg.hidden = YES;
    
    cell.couponsViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 40;
    CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)_couponList[indexPath.section];
    NSString* priceStri = [NSString stringWithFormat:@"￥%.f",[couponForm.value floatValue]];
    CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(44)];
    cell.couponPriceLabelLayout.constant = priceSize.width + 5;
    cell.couponPriceLabel.text = priceStri;

    NSString* storeNameStr = couponForm.storeName;
    int width = PJ_SCREEN_WIDTH - 40 - 80 - priceSize.width - 50;
    CGSize storeNameSize = [CZJUtils calculateStringSizeWithString:storeNameStr Font:SYSTEMFONT(15) Width:width];
    cell.storeNameLabelLayoutheight.constant = storeNameSize.height;
    cell.storeNameLabelLayoutWidth.constant = width;
    cell.storeNameLabel.text = storeNameStr;
    cell.receiveTimeLabel.text = couponForm.validEndTime;
    cell.useableLimitLabel.text = [NSString stringWithFormat:@"满%@可用",couponForm.validMoney];
    cell.backgroundColor = CLEARCOLOR;
    
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
    cell.couponPriceLabel.textColor = CZJREDCOLOR;
    cell.storeNameLabel.textColor = CZJREDCOLOR;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
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
    _params = @{@"type":@"0", @"page":@"1"};
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
    _params = @{@"type":@"1", @"page":@"1"};
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
    _params = @{@"type":@"2", @"page":@"1"};
    [super getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

