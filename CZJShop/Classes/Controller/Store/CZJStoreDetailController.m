//
//  CZJStoreDetailController.m
//  CZJShop
//
//  Created by PJoe on 16-1-12.
//  Copyright (c) 2016年 JoeP. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CZJStoreDetailController.h"
#import "CZJStoreDetailHeadCell.h"
#import "CZJStoreDescribeTwoCell.h"
#import "CZJStoreDescribeCell.h"
#import "CZJGoodsRecommendCell.h"
#import "CZJGoodsRecoCellHeader.h"
#import "CZJStoreDetailMenuCell.h"
#import "CZJCouponsCell.h"
#import "CZJAdBanerCell.h"
#import "CZJBaseDataManager.h"
#import "CheckInstalledMapAPP.h"
#import "LocationChange.h"
#import "CZJOtherStoreListController.h"
#import "NIDropDown.h"
#import "WyzAlbumViewController.h"
#import "CZJReceiveCouponsController.h"
#import "MXPullDownMenu.h"
#import "CZJDetailViewController.h"


@interface CZJStoreDetailController ()
<
MXPullDownMenuDelegate,
CZJStoreDetailHeadCellDelegate,
CZJImageViewTouchDelegate,
NIDropDownDelegate,
CZJNaviagtionBarViewDelegate,
CZJGoodsRecommendCellDelegate,
UIGestureRecognizerDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
MKMapViewDelegate
>
{
    NSArray* _activityArray;                //活动数据
    NSArray* _imgsArray;                    //服务列表
    NSArray* _nativeRecommendArray;         //未经处理爆款商品列表
    NSArray* _recommendArray;               //爆款商品列表
    NSArray* _couponsArray;                 //优惠券数据
    NSArray* _bannerOneArray;               //广告条
    NSArray* _goodsTypesArray;              //商品类型
    NSArray* _serviceTypesArray;            //服务类型
    NSArray* _nativeServiceAndGoodsArray;   //未经处理服务和商品数组
    NSArray* _serviceAndGoodsArray;         //服务和商品
    
    NIDropDown *dropDown;
    CZJStoreDetailForm* _storeDetailForm;
    float lastContentOffsetY;
    CGRect popViewRect;
    NSString* _touchedStoreItemPid;
    NSInteger _touchedType;
    BOOL isSearchBarShow;
    
    NSString* _bigTypeId;                   //第一个大类型
    NSString* _typeId;                      //第二个类型
    NSString* _q;                           //搜索内容
    NSString* _sortType;                    //销量1 最新2 价高3 价低4
    
    CGFloat tableCellHeight;
    NSInteger numberOfLoad;
    NSInteger goodCellHeight;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet MXPullDownMenu* topView;
@property (strong, nonatomic) UIView *backgroundView;
@property (assign, nonatomic) CLLocationCoordinate2D naviCoordsGd;
@property (assign, nonatomic) CLLocationCoordinate2D naviCoordsBd;
@property (assign, nonatomic) CLLocationCoordinate2D nowCoords;

- (IBAction)callAction:(id)sender;
- (IBAction)callNaviAction:(id)sender;
@end

@implementation CZJStoreDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getStoreDetailDataFromServer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MXPullDownMenuTitleChange" object:nil];
}

- (void)initDatas
{
    lastContentOffsetY = 0;
    _activityArray = [NSMutableArray array];
    _imgsArray = [NSMutableArray array];
    _recommendArray = [NSMutableArray array];
    _couponsArray = [NSMutableArray array];
    _bannerOneArray = [NSMutableArray array];
    _goodsTypesArray = [NSMutableArray array];
    _serviceTypesArray = [NSMutableArray array];
    _serviceAndGoodsArray = [NSMutableArray array];
    
    _bigTypeId = @"2";
    _typeId = @"0";
    _q = @"";
    _sortType = @"1";
    
    //除去顶部导航栏，状态栏，下拉菜单高度，底部导航栏之后的中间区域高度
    tableCellHeight = PJ_SCREEN_HEIGHT - 64 - 54 - 49;
    goodCellHeight = (PJ_SCREEN_WIDTH - 30) / 2 + 5 + 40 + 10 +15 + 10 + 10;
    numberOfLoad = ceilf(tableCellHeight / goodCellHeight);
}

- (void)initViews
{
    //topView
    [self addCZJNaviBarView:CZJNaviBarViewTypeStoreDetail];
    self.naviBarView.customSearchBar.alpha = 0;
    self.naviBarView.customSearchBar.placeholder = @"搜索门店内服务、商品";
    [self.buttomView setBackgroundColor:RGBA(255, 255, 255, 0.9)];
    self.topView.hidden = YES;
    
    //TableView
    NSArray* nibArys = @[@"CZJStoreDetailHeadCell",
                         @"CZJStoreDescribeCell",
                         @"CZJStoreDescribeTwoCell",
                         @"CZJGoodsRecommendCell",
                         @"CZJAdBanerCell",
                         @"CZJCouponsCell",
                         @"CZJGoodsRecoCellHeader",
                         @"CZJStoreDetailMenuCell"
                         ];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //背景触摸层
    _backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    [self.view addSubview:_backgroundView];
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"全部", @"服务", @"商品", @"套餐",@"促销"];
    NSArray* filterTypes = @[@"销量"];
    NSArray* latestTypes = @[@"最新"];
    NSArray* storeTypes = @[@"价格"];
    NSArray* menuArray = @[sortTypes,filterTypes,latestTypes,storeTypes];
    [self.topView initWithArray:menuArray AndType:CZJMXPullDownMenuTypeStoreDetail WithFrame:self.topView.frame].delegate = self;
    
    //添加下拉菜单选项改变通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableViewMenu) name:@"MXPullDownMenuTitleChange" object:nil];
}

- (void)refreshTableViewMenu
{
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)getStoreDetailDataFromServer
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJBaseDataInstance loadStoreInfo:@{@"storeId" : self.storeId} success:^(id json) {
        [self dealWithStoreDetailInfoData:json];
        [self.myTableView reloadData];
        [self getStoreGoodsAndServiceDataFromServer];
    } fail:nil];
}

- (void)getStoreGoodsAndServiceDataFromServer
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary* params = @{@"bigTypeId" : _bigTypeId,
                             @"typeId" : _typeId,
                             @"q" : _q,
                             @"sortType" : _sortType,
                             @"storeId" : _storeDetailForm.storeId,
                             @"storeCityId" : _storeDetailForm.cityId};
    [CZJBaseDataInstance loadStoreDetail:params success:^(id json) {
        CZJGeneralBlock block = ^()
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self dealWithGoodsServiceData:json];
        };
        [CZJUtils performBlock:block afterDelay:0.5];
        
    } fail:nil];
}

- (void)dealWithStoreDetailInfoData:(id)json
{
    NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    
    _imgsArray = [dict valueForKey:@"imgs"];
    _activityArray = [CZJStoreDetailActivityForm objectArrayWithKeyValuesArray:[dict valueForKey:@"activitys"]];
    _bannerOneArray = [CZJStoreDetailBannerForm objectArrayWithKeyValuesArray:[dict valueForKey:@"banners"]];
    _couponsArray = [CZJCouponForm objectArrayWithKeyValuesArray:[dict valueForKey:@"coupons"]];
    _goodsTypesArray = [CZJStoreDetailTypesForm objectArrayWithKeyValuesArray:[dict valueForKey:@"goodsTypes"]];
    CZJBaseDataInstance.goodsTypesAry = [_goodsTypesArray mutableCopy];
    _nativeRecommendArray = [CZJStoreDetailGoodsAndServiceForm objectArrayWithKeyValuesArray:[dict valueForKey:@"recommends"]];
    _recommendArray = [CZJUtils getAggregationArrayFromArray:_nativeRecommendArray];
    _serviceTypesArray = [CZJStoreDetailTypesForm objectArrayWithKeyValuesArray:[dict valueForKey:@"serviceTypes"]];
    CZJBaseDataInstance.serviceTypesAry = [_serviceTypesArray mutableCopy];
    _storeDetailForm = [CZJStoreDetailForm objectWithKeyValues:[dict valueForKey:@"store"]];
}

- (void)dealWithGoodsServiceData:(id)json
{
    NSDictionary* dict = [CZJUtils DataFromJson:json];
    _nativeServiceAndGoodsArray = [GoodsRecommendForm objectArrayWithKeyValuesArray:[dict valueForKey:@"msg"]];
    _serviceAndGoodsArray = [CZJUtils getAggregationArrayFromArray:_nativeServiceAndGoodsArray];
    if (_serviceAndGoodsArray > 0)
    {
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 3;
    }
    if (1 == section)
    {
        return _couponsArray.count > 0 ? 1 : 0;
    }
    if (2 == section)
    {
        return _bannerOneArray.count > 0 ? 1 : 0;
    }
    if (3 == section)
    {
        return _imgsArray.count;
    }
    if (4 == section)
    {
        return _recommendArray.count > 0 ? _recommendArray.count + 1 : 0;
    }
    if (5 == section)
    {
        if (0 == _serviceAndGoodsArray.count)
        {//第一种没有数据
            return 2 + 1;
        }
        //第二种有数据，但又填充不满屏幕的情况
        else if (_serviceAndGoodsArray.count > 0 &&
                 _serviceAndGoodsArray.count < numberOfLoad)
        {
            return _serviceAndGoodsArray.count + 2 + 1;
        }
        //第三种有数据，可以正常填满屏幕的情况
        else
        {
            return _serviceAndGoodsArray.count + 2;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJStoreDetailHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailHeadCell" forIndexPath:indexPath];
            cell.storeAddrLabel.text = _storeDetailForm.storeAddr;
            cell.storeNameLabel.text = _storeDetailForm.storeName;
            cell.attentionCountLabel.text = _storeDetailForm.attentionCount;
            [cell.attentionBtn setImage:IMAGENAMED(_storeDetailForm.attentionFlag ? @"shop_icon_guanzhu_sel" : @"shop_icon_guanzhu") forState:UIControlStateNormal];
            cell.headImgLayoutWidth.constant = 0;
            cell.storeNameLayoutWidth.constant = [CZJUtils calculateStringSizeWithString:_storeDetailForm.storeName Font:SYSTEMFONT(16) Width:200].width;
            cell.delegate = self;
            cell.attentionDelegate = self;
            if (!cell.isInit && _imgsArray.count > 0) {
                [cell someMethodNeedUse:indexPath DataModel:[@[_imgsArray.firstObject]mutableCopy]];
            }
            
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJStoreDescribeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDescribeCell" forIndexPath:indexPath];
            cell.envirmentScoreLabel.text = _storeDetailForm.environmentScore;
            cell.describeScoreLabel.text = _storeDetailForm.descScore;
            cell.deliveryScoreLabel.text = _storeDetailForm.deliveryScore;
            cell.serviceScoreLabel.text = _storeDetailForm.serviceScore;
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJStoreDescribeTwoCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDescribeTwoCell" forIndexPath:indexPath];
            cell.serviceLabel.text = [NSString stringWithFormat:@"服务 %@",_storeDetailForm.serviceCount];
            cell.promotionLabel.text = [NSString stringWithFormat:@"促销 %@",_storeDetailForm.promotionCount];
            cell.setMenuLabel.text = [NSString stringWithFormat:@"套餐 %@",_storeDetailForm.setmenuCount];
            cell.goodsLabel.text = [NSString stringWithFormat:@"商品 %@",_storeDetailForm.goodsCount];
            CZJButtonClickHandler buttonClickHandler = ^(id data)
            {
                UIButton* btn = (UIButton*)data;
                _touchedType = btn.tag;
                [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [self.topView confiMenuWithSelectRow:_touchedType];
                _bigTypeId = [NSString stringWithFormat:@"%ld",_touchedType];
                [self getStoreGoodsAndServiceDataFromServer];
            };
            cell.buttonClick = buttonClickHandler;
            return cell;
        }
    }
    if (1 == indexPath.section && 0 == indexPath.row)
    {//领券
        CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
        if (cell && _couponsArray.count > 0 && !cell.isInit)
        {
            [cell initWithCouponDatas:_couponsArray];
        }
        return cell;
    }
    if (2 == indexPath.section && 0 == indexPath.row)
    {//广告一
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
//        [cell initBannerOneWithDatas:_bannerOneArray];
        return cell;
    }
    if (3 == indexPath.section)
    {//广告二
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
//        [cell initBannerWithImg:_imgsArray[indexPath.row]];
        return cell;
    }
    if (4 == indexPath.section)
    {//爆款专区
        if (0 == indexPath.row)
        {
            CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
            headerView.backgroundColor = [UIColor clearColor];
            headerView.backgroundView.backgroundColor = [UIColor clearColor];
            headerView.recoImg.hidden = YES;
            headerView.recoLabel.hidden = YES;
            headerView.recoMenuLabel.hidden = NO;
            headerView.recoMenuLabel.text = @"爆款专区";
            return headerView;
        }
        else
        {
            CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
            float width = (PJ_SCREEN_WIDTH - 30) / 2;
            cell.delegate = self;
            cell.imageTwoHeight.constant = width;
            cell.imageOneHeight.constant = width;
            if (cell && _recommendArray.count > 0) {
                [cell initGoodsRecommendWithDatas:_recommendArray[indexPath.row - 1]];
            }
            return cell;
        }
    }
    if (5 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
            headerView.backgroundColor = [UIColor clearColor];
            headerView.backgroundView.backgroundColor = [UIColor clearColor];
            headerView.recoImg.hidden = YES;
            headerView.recoLabel.hidden = YES;
            headerView.recoMenuLabel.hidden = NO;
            headerView.recoMenuLabel.text = @"服务和商品";
            headerView.recoViewLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:@"服务和商品" WithFont:headerView.recoMenuLabel.font].width;
            return headerView;
        }
        else if (1 == indexPath.row)
        {
            CZJStoreDetailMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailMenuCell" forIndexPath:indexPath];
            ((CATextLayer*)cell.titles[0]).string = [self.topView getMenuTitleByCurrentMenuIndex];
            CZJButtonClickHandler buttonClickHandler = ^(id data)
            {
                NSString* tagStr = (NSString*)data;
                _touchedType = [tagStr integerValue];
                [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [self.topView confiMenuWithSelectRow:_touchedType];
                if (_touchedType == 0)
                {
                    _bigTypeId = [NSString stringWithFormat:@"%ld",_touchedType];
                }
                else
                {
                    _sortType = [NSString stringWithFormat:@"%ld",_touchedType];
                }
                [self getStoreGoodsAndServiceDataFromServer];
            };
            cell.buttonClick = buttonClickHandler;
            return cell;
        }
        else
        {
            //第一种没有数据的情况
            if (0 == _serviceAndGoodsArray.count)
            {
                CZJTableViewCell* cell = (CZJTableViewCell*)[CZJUtils getBackgroundPromptViewWithPrompt:@"该店没有商品或服务"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            //第二种有数据，但又填充不满屏幕的情况
            else if (_serviceAndGoodsArray.count > 0 &&
                     _serviceAndGoodsArray.count < numberOfLoad)
            {
                if (indexPath.row < _serviceAndGoodsArray.count + 2 &&
                    indexPath.row > 1)
                {//有数据的goodcell
                    CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
                    float width = (PJ_SCREEN_WIDTH - 30) / 2;
                    cell.delegate = self;
                    cell.imageTwoHeight.constant = width;
                    cell.imageOneHeight.constant = width;
                    if (cell && _serviceAndGoodsArray.count > 0) {
                        [cell initGoodsRecommendWithDatas:_serviceAndGoodsArray[indexPath.row - 2]];
                    }
                    return cell;
                }
                else
                {//空白的cell
                    CZJTableViewCell* cell = [[CZJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = CLEARCOLOR;
                    return cell;
                }
            }
            //第三种有数据，可以正常填满屏幕的情况
            else
            {
                CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
                float width = (PJ_SCREEN_WIDTH - 30) / 2;
                cell.delegate = self;
                cell.imageTwoHeight.constant = width;
                cell.imageOneHeight.constant = width;
                if (cell && _serviceAndGoodsArray.count > 0) {
                    [cell initGoodsRecommendWithDatas:_serviceAndGoodsArray[indexPath.row - 2]];
                }
                return cell;
            }
        }
    }
    return nil;
}


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 280;
        }
        if (1 == indexPath.row)
        {
            return 60;
        }
        if (2 == indexPath.row)
        {
            return 139;
        }
    }
    if (1 == indexPath.section)
    {
        return 50;
    }
    if (2 == indexPath.section)
    {
        return 100;
    }
    if (3 == indexPath.section)
    {
        return 150;
    }
    if (4 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 50;
        }
        if (1 == indexPath.row)
        {
            float width = (PJ_SCREEN_WIDTH - 30) / 2;
            return width + 5 + 40 + 10 +15 + 10 + 10;
        }
    }
    if (5 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 54;
        }
        else if (1 == indexPath.row)
        {
            return 54;
        }
        else
        {
            //第一种没有数据的情况
            if (0 == _serviceAndGoodsArray.count)
            {
                return tableCellHeight;
            }
            //第二种有数据，但又填充不满屏幕的情况
            else if (_serviceAndGoodsArray.count > 0 &&
                _serviceAndGoodsArray.count < numberOfLoad)
            {
                if (indexPath.row < _serviceAndGoodsArray.count + 2 &&
                    indexPath.row > 1)
                {//有数据的goodcell
                    return goodCellHeight;
                }
                else
                {//空白的cell
                    return tableCellHeight - _serviceAndGoodsArray.count*goodCellHeight;
                }
            }
            //第三种有数据，可以正常填满屏幕的情况
            else
            {
                return goodCellHeight;
            }
        }
    }
    return 180;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section)
    {
        CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
        self.popWindowInitialRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        self.popWindowDestineRect = CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        [CZJUtils showMyWindowOnTarget:self withMyVC:receiveCouponsController];
        __weak typeof(self) weak = self;
        [receiveCouponsController setCancleBarItemHandle:^{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weak.window.frame = weak.popWindowInitialRect;
                self.upView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [weak.upView removeFromSuperview];
                    [weak.window resignKeyWindow];
                    weak.window  = nil;
                    weak.upView = nil;
                    weak.navigationController.interactivePopGestureRecognizer.enabled = YES;
                }
            }];
        }];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section ||
        3 == section)
    {
        return 0;
    }
    return 10;
}


#pragma mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    
    //判断是否是上拉还是下滑动作
    bool isDraggingDown = (lastContentOffsetY - contentOffsetY) > 0 ;
    lastContentOffsetY = contentOffsetY;

    CGRect frame = [self.myTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5]];
//    DLog(@"contentOffsetY:%f, frameY:%f",contentOffsetY,frame.origin.y);
    if ((contentOffsetY <= frame.origin.y - 64 && isDraggingDown)||
        (contentOffsetY >= frame.origin.y - 64 && !isDraggingDown))
    {
        self.topView.hidden = isDraggingDown;
    }

    if (contentOffsetY <=0)
    {
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(0)];
        self.naviBarView.customSearchBar.alpha = 0;
        isSearchBarShow = NO;
    }
    else if (contentOffsetY > 0)
    {
        if (contentOffsetY > 300 && !isSearchBarShow)
        {
            isSearchBarShow = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.naviBarView.customSearchBar.alpha = 1;
            }];
        }
        else if (contentOffsetY <= 300 && isSearchBarShow)
        {
            isSearchBarShow = NO;
            [UIView animateWithDuration:0.2 animations:^{
                self.naviBarView.customSearchBar.alpha = 0;
            }];
        }
        
        float alphaValue = contentOffsetY / 300;
        alphaValue = alphaValue >= 0.99 ? 1 : alphaValue;
        [self.naviBarView.btnBack setBackgroundColor:RGBA(200, 200, 200,(1 - alphaValue))];
        [self.naviBarView.btnMore setBackgroundColor:RGBA(200, 200, 200,(1 - alphaValue))];
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(alphaValue)];
    }
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeSearchBar:
            
            break;
            
        case CZJButtonTypeNaviBarMore:
        {
            NSArray * arr = [[NSArray alloc] init];
            arr = [NSArray arrayWithObjects:@{@"消息" : @"prodetail_icon_msg"}, @{@"首页":@"prodetail_icon_home"}, @{@"分享" :@"prodetail_icon_share"},nil];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 120 - 14, StatusBar_HEIGHT + 78, 120, 150);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr];
                dropDown.delegate = self;
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete
{
    if (show) {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
        }];
    }
    complete();
}


#pragma mark NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"消息"])
    {
        DLog(@"消息");
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        DLog(@"首页");
    }
    if ([btnStr isEqualToString:@"分享"])
    {
        DLog(@"分享");
    }
}


#pragma mark CZJImageTouchViewDelegate
- (void)showDetailInfoWithIndex:(NSInteger)index
{
    WyzAlbumViewController *wyzAlbumVC = [[WyzAlbumViewController alloc]init];
    wyzAlbumVC.currentIndex =index;//这个参数表示当前图片的index，默认是0
    //用url
    wyzAlbumVC.imgArr = [_imgsArray mutableCopy];
    //进入动画
    [self presentViewController:wyzAlbumVC animated:YES completion:^{
    }];
}


#pragma mark CZJStoreDetailHeadCellDelegate
- (void)clickAttentionButton:(id)sender
{
    _storeDetailForm.attentionFlag = !_storeDetailForm.attentionFlag;
    if (_storeDetailForm.attentionFlag) {
        [CZJBaseDataInstance attentionStore:@{@"storeId" : _storeDetailForm.storeId} success:^(id json) {
            
        }];
        _storeDetailForm.attentionCount = [NSString stringWithFormat:@"%ld",[_storeDetailForm.attentionCount integerValue] + 1];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionStore:@{@"storeId" : _storeDetailForm.storeId} success:^(id json) {
            
        }];
        _storeDetailForm.attentionCount = [NSString stringWithFormat:@"%ld",[_storeDetailForm.attentionCount integerValue] - 1];
    }
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark MXPullDownMenuDelegate
- (void)pullDownMenuFirstName:(NSString*)firstName andSecondName:(NSString*)secondName
{
    DLog(@"%@,%@",firstName, secondName);
}
- (void)pullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectCityName:(NSString*)cityName
{
    DLog(@"%@",cityName);
    if ([cityName isEqualToString:@"销量"])
    {
        _sortType = @"1";
    }
    if ([cityName isEqualToString:@"最新"])
    {
        _sortType = @"2";
    }
    if ([cityName isEqualToString:@"价格"])
    {
        if ([_sortType isEqualToString:@"3"])
        {
            _sortType = @"4";
        }
        else if ([_sortType isEqualToString:@"3"])
        {
            _sortType = @"3";
        }
    }
    if ([cityName isEqualToString:@"全部"])
    {
        _bigTypeId = @"0";
    }
    [self getStoreGoodsAndServiceDataFromServer];
}


#pragma mark CZJGoodsRecommendCellDelegate
- (void)clickRecommendCellWithID:(NSString*)itemID
{
    _touchedStoreItemPid = itemID;
    CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"goodsDetailSBID"];
    detailVC.storeItemPid = itemID;
    NSString* itemType = @"";
    for (CZJStoreDetailGoodsAndServiceForm* mForm in _nativeServiceAndGoodsArray)
    {
        if ([itemID isEqualToString:mForm.storeItemPid])
        {
            itemType = mForm.itemType;
        }
    }
    detailVC.detaiViewType = [itemType intValue];
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark MKMapViewDelegate -user location定位变化
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    self.nowCoords = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
    //    self.userRegion = MKCoordinateRegionMakeWithDistance(self.nowCoords, 200, 200);
    //
    //    if (self.mapType != RegionNavi) {
    //        if (self.updateInt >= 1) {
    //            return;
    //        }
    //        [self showAnnotation:userLocation.location coord:self.nowCoords];
    //        [self.regionMapView setRegion:self.userRegion animated:NO];
    //    }
}
//-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    if (self.mapType == RegionNavi) {
//        return;
//    }
//    if (ISIOS7) {
//        if ([mapView.annotations count]) {
//            [mapView removeAnnotations:mapView.annotations];
//        }
//    }
//
//    if (self.updateInt == 0){
//        return;
//    }
//    self.centerCoordinate = mapView.region.center;
//
//    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.centerCoordinate.latitude longitude:self.centerCoordinate.longitude];
//
//    [self showAnnotation:loc coord:centerCoordinate];
//}
//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
//    if (self.mapType == RegionNavi) {
//        return;
//    }
//    if (ISIOS7) {
//        if ([mapView.annotations count]) {
//            [mapView removeAnnotations:mapView.annotations];
//        }
//    }
//}


#pragma mark- Actions
- (IBAction)callAction:(id)sender {
    [CZJUtils callHotLine:_storeDetailForm.hotline AndTarget:self.view];
    
}

- (IBAction)callNaviAction:(id)sender {
    NSArray *appListArr = [CheckInstalledMapAPP checkHasOwnApp];
    NSString *sheetTitle = [NSString stringWithFormat:@"导航到 %@",_storeDetailForm.storeAddr];
    
    UIActionSheet *sheet;
    if ([appListArr count] == 2) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1], nil];
    }else if ([appListArr count] == 3){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2], nil];
    }else if ([appListArr count] == 4){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3], nil];
    }else if ([appListArr count] == 5){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3],appListArr[4], nil];
    }
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == 0) {
        if (IOS_VERSION < 6) {//ios6 调用goole网页地图
            NSString *urlString = [[NSString alloc]
                                   initWithFormat:@"http://maps.google.com/maps?saddr=&daddr=%.8f,%.8f&dirfl=d",self.naviCoordsGd.latitude,self.naviCoordsGd.longitude];
            
            NSURL *aURL = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:aURL];
        }else{//ios7 跳转apple map
            CLLocationCoordinate2D to;
            
            to.latitude = [_storeDetailForm.lat floatValue];
            to.longitude = [_storeDetailForm.lng floatValue];
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
            
            toLocation.name = _storeDetailForm.storeAddr;
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
        }
    }
    if ([btnTitle isEqualToString:@"google地图"]) {
//        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",self.nowCoords.latitude,self.nowCoords.longitude,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }else if ([btnTitle isEqualToString:@"高德地图"]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"iosamap://navi?sourceApplication=broker&backScheme=openbroker2&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2",_storeDetailForm.storeAddr,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude]];
        [[UIApplication sharedApplication] openURL:url];
        
    }else if ([btnTitle isEqualToString:@"百度地图"]){
        double bdNowLat,bdNowLon;
        bd_encrypt(self.nowCoords.latitude, self.nowCoords.longitude, &bdNowLat, &bdNowLon);
        
        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=%.8f,%.8f&&mode=driving",bdNowLat,bdNowLon,self.naviCoordsBd.latitude,self.naviCoordsBd.longitude];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }else if ([btnTitle isEqualToString:@"显示路线"]){
//        [self drawRout];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToStoreList"])
    {
        CZJOtherStoreListController* vc = segue.destinationViewController;
        vc.storeID = _storeDetailForm.storeId;
        vc.companyId = _storeDetailForm.companyId;
    }
}

@end
