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
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block NSInteger page;
}
@property (strong, nonatomic)NSMutableArray* couponList;
@property (strong, nonatomic)UITableView* myTableView;
@end
@implementation CZJMyWalletCouponListBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    _couponList = [NSMutableArray array];
    [self initViews];
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 114);
    _myTableView = [[UITableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    
    _myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
    
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        page++;
        [weak getCouponListFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
}

- (void)getCouponListFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [_params setValue:@(page) forKey:@"page"];
    [CZJBaseDataInstance generalPost:_params success:^(id json) {
        
        //========获取数据返回，判断数据大于0不==========
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [_couponList addObjectsFromArray: [CZJShoppingCouponsForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 20)
            {
                [refreshFooter noticeNoMoreData];
            }
            else
            {
                [weak.myTableView.footer endRefreshing];
            }
        }
        else
        {
            _couponList = [[CZJShoppingCouponsForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
        }
        
        if (_couponList.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有对应优惠券/(ToT)/~~"];
        }
        else
        {
            self.myTableView.hidden = (_couponList.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
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
    _params = @{@"type":@"0", @"page":@"1"};
    [self getCouponListFromServer];
}

- (void)getCouponUnUsedListFromServer
{
    
    [super getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

@implementation CZJMyWalletCouponUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    _params = @{@"type":@"1", @"page":@"1"};
    [self getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

@implementation CZJMyWalletCouponOutOfTimeController

- (void)viewDidLoad {
    [super viewDidLoad];
    _params = @{@"type":@"2", @"page":@"1"};
    [self getCouponListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

