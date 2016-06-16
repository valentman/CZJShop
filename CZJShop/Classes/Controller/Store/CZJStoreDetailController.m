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
#import "ShareMessage.h"
#import "CZJMyInfoAttentionController.h"
#import "CZJMyInfoRecordController.h"
#import "CZJChatViewController.h"
#import "ChatViewController.h"
#import "CZJMyMessageCenterController.h"

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
    NSArray* _imgsArray;                    //门店图片
    NSArray* _nativeRecommendArray;         //未经处理爆款商品列表
    NSArray* _recommendArray;               //爆款商品列表
    NSArray* _couponsArray;                 //优惠券数据
    NSArray* _bannerOneArray;               //广告条
    NSArray* _goodsTypesArray;              //商品类型
    NSArray* _serviceTypesArray;            //服务类型
    __block NSMutableArray* _nativeServiceAndGoodsArray;   //未经处理服务和商品数组
    __block NSMutableArray* _serviceAndGoodsArray;         //服务和商品
    
    NIDropDown *dropDown;
    CZJStoreDetailForm* _storeDetailForm;
    float lastContentOffsetY;
    CGRect popViewRect;
    NSString* _touchedStoreItemPid;
    __block NSInteger _touchedType;
    BOOL isSearchBarShow;
    MJRefreshAutoNormalFooter* refreshFooter;
    CZJStoreDetailMenuCell* menuCell;
    
    __block NSString* _bigTypeId;                   //第一个大类型
    __block NSString* _typeId;                      //第二个类型
    NSString* _q;                           //搜索内容
    NSString* _sortType;                    //销量1 最新2 价高3 价低4
    
    CGFloat tableCellHeight;
    NSInteger numberOfLoad;
    NSInteger goodCellHeight;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UIView *buttomView2;
@property (weak, nonatomic) IBOutlet MXPullDownMenu* topView;
@property (strong, nonatomic) UIView *backgroundView;
@property (assign, nonatomic) CLLocationCoordinate2D naviCoordsGd;
@property (assign, nonatomic) CLLocationCoordinate2D naviCoordsBd;
@property (assign, nonatomic) CLLocationCoordinate2D nowCoords;
@property (assign, nonatomic) __block NSInteger page;

- (IBAction)callAction:(id)sender;
- (IBAction)callNaviAction:(id)sender;
- (IBAction)contactServiceAction:(id)sender;
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

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillLayoutSubviews
{
    
    _buttomView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT - 50, PJ_SCREEN_WIDTH, 50);
}

- (void)viewDidLayoutSubviews
{
    _buttomView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT - 50, PJ_SCREEN_WIDTH, 50);
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
    _nativeServiceAndGoodsArray = [NSMutableArray array];
    
    _bigTypeId = @"0";
    _typeId = @"0";
    _q = @"";
    _sortType = @"1";
    _page = 1;
    
    //除去顶部导航栏，状态栏，下拉菜单高度，底部导航栏之后的中间区域高度
    tableCellHeight = PJ_SCREEN_HEIGHT - 64 - 54 - 49;
    goodCellHeight = (PJ_SCREEN_WIDTH - 30) / 2 + 5 + 40 + 10 +15 + 10 + 10;
    numberOfLoad = ceilf(tableCellHeight / goodCellHeight);
}

- (void)initViews
{
    __weak typeof(self) weak = self;
    //NaviBar
    [self addCZJNaviBarView:CZJNaviBarViewTypeStoreDetail];
    self.naviBarView.customSearchBar.alpha = 0;
    self.naviBarView.customSearchBar.placeholder = @"搜索门店内服务、商品";
    [self.buttomView setBackgroundColor:RGBA(255, 255, 255, 0.9)];
    
    
    //TableView
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.backgroundColor = WHITECOLOR;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = YES;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        weak.page++;
        [weak getStoreGoodsAndServiceDataFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    
    //背景触摸层
    _backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    UISwipeGestureRecognizer* leftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer* rightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer* downGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [downGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    UISwipeGestureRecognizer* upGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [upGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [_backgroundView addGestureRecognizer:gesture];
    [_backgroundView addGestureRecognizer:downGesture];
    [_backgroundView addGestureRecognizer:upGesture];
    [_backgroundView addGestureRecognizer:leftGesture];
    [_backgroundView addGestureRecognizer:rightGesture];
    _backgroundView.hidden = YES;
    [self.view addSubview:_backgroundView];
    
    //顶部下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"全部", @"服务", @"商品", @"套餐",@"促销"];
    NSArray* filterTypes = @[@"销量"];
    NSArray* latestTypes = @[@"最新"];
    NSArray* storeTypes = @[@"价格"];
    NSArray* menuArray = @[sortTypes,filterTypes,latestTypes,storeTypes];
    [self.topView initWithArray:menuArray AndType:CZJMXPullDownMenuTypeStoreDetail WithFrame:self.topView.frame].delegate = self;
    self.topView.hidden = YES;
    [self.topView tapIndexSetTitleColor:1];
    self.topView.backgroundColor = WHITECOLOR;
    
    //添加下拉菜单选项改变通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableViewMenu) name:@"MXPullDownMenuTitleChange" object:nil];
}

- (void)refreshTableViewMenu
{
//    [self.myTableView reloadData];
}

- (void)getStoreDetailDataFromServer
{//获取门店信息
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJBaseDataInstance loadStoreDetail:@{@"storeId" : self.storeId} success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self dealWithStoreDetailInfoData:json];
        [self.myTableView reloadData];
        [self getStoreGoodsAndServiceDataFromServer];
    } fail:nil];
}

- (void)dealWithStoreDetailInfoData:(id)json
{
    NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    DLog(@"%@",[dict description]);
    //门店图片
    _imgsArray = [dict valueForKey:@"imgs"];
    
    //门店优惠券
    _couponsArray = [CZJShoppingCouponsForm objectArrayWithKeyValuesArray:[dict valueForKey:@"coupons"]];
    
    //活动
    _activityArray = [CZJStoreDetailActivityForm objectArrayWithKeyValuesArray:[dict valueForKey:@"activitys"]];
    
    //广告
    _bannerOneArray = [CZJStoreDetailBannerForm objectArrayWithKeyValuesArray:[dict valueForKey:@"banners"]];
    
    //爆款未筛选数组
    _nativeRecommendArray = [CZJStoreDetailGoodsAndServiceForm objectArrayWithKeyValuesArray:[dict valueForKey:@"recommends"]];
    
    //爆款筛选后数组
    _recommendArray = [CZJUtils getAggregationArrayFromArray:_nativeRecommendArray];
    
    //商品分类
    _goodsTypesArray = [CZJStoreDetailTypesForm objectArrayWithKeyValuesArray:[dict valueForKey:@"goodsTypes"]];
    CZJBaseDataInstance.goodsTypesAry = [_goodsTypesArray mutableCopy];
    //服务分类
    _serviceTypesArray = [CZJStoreDetailTypesForm objectArrayWithKeyValuesArray:[dict valueForKey:@"serviceTypes"]];
    CZJBaseDataInstance.serviceTypesAry = [_serviceTypesArray mutableCopy];
    
    //门店详情信息
    _storeDetailForm = [CZJStoreDetailForm objectWithKeyValues:[dict valueForKey:@"store"]];
}


- (void)getStoreGoodsAndServiceDataFromServer
{//获取门店商品服务列表
    NSDictionary* params = @{@"bigTypeId" : _bigTypeId,
                             @"typeId" : _typeId,
                             @"sortType" : _sortType,
                             @"q" : _q,
                             @"storeId" : _storeDetailForm.storeId,
                             @"storeCityId" : _storeDetailForm.cityId,
                             @"page": @(self.page)};
    DLog(@"%@",[params description]);
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance loadStoreInfo:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [weak dealWithGoodsServiceData:json];
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.myTableView.footer endRefreshing];
    }];
}

- (void)dealWithGoodsServiceData:(id)json
{
    NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    if (tmpAry.count < 20)
    {
        [refreshFooter noticeNoMoreData];
    }
    else
    {
        [self.myTableView.footer endRefreshing];
    }
    [_nativeServiceAndGoodsArray addObjectsFromArray:[GoodsRecommendForm objectArrayWithKeyValuesArray:tmpAry]];
    DLog(@"筛选后个数:%zi",_nativeServiceAndGoodsArray.count);
    _serviceAndGoodsArray = [CZJUtils getAggregationArrayFromArray:_nativeServiceAndGoodsArray];
    if (_serviceAndGoodsArray > 0)
    {
        [self.myTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5 + _bannerOneArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {//门店信息
        return 3;
    }
    if (1 == section)
    {//优惠券领取
        return _couponsArray.count > 0 ? 1 : 0;
    }
    if (2 == section)
    {//活动
        return _activityArray.count > 0 ? 1 : 0;
    }
    if (section > 2 && section < _bannerOneArray.count + 3)
    {//广告
        return 1;
    }
    if (_bannerOneArray.count + 3 == section)
    {//爆款商品
        return _recommendArray.count > 0 ? _recommendArray.count + 1 : 0;
    }
    if (_bannerOneArray.count + 4 == section)
    {//一般商品
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
            //门店名称
            cell.headImgLayoutWidth.constant = 0;
            cell.storeNameLabel.text = _storeDetailForm.storeName;
            cell.storeNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 15 - 120;
            CGSize storeSize = [CZJUtils calculateStringSizeWithString:_storeDetailForm.storeName Font:cell.storeNameLabel.font Width:PJ_SCREEN_WIDTH - 15 - 120];
            cell.storeNameHeight.constant = storeSize.height > 20 ? 40 : 20;
            //门店地址
            cell.storeAddrLabel.text = _storeDetailForm.storeAddr;
            CGSize addrSize = [CZJUtils calculateStringSizeWithString:_storeDetailForm.storeAddr Font:cell.storeAddrLabel.font Width:PJ_SCREEN_WIDTH - 15 - 120];
            cell.storeAddrLabelHeight.constant = addrSize.height > 15 ? 30 : 15;
            //关注
            cell.attentionCountLabel.text = _storeDetailForm.attentionCount;
            [cell.attentionBtn setImage:IMAGENAMED(_storeDetailForm.attentionFlag ? @"shop_icon_guanzhu_sel" : @"shop_icon_guanzhu") forState:UIControlStateNormal];
            
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
            cell.serviceLabel.text = [NSString stringWithFormat:@"服务 %@",_storeDetailForm.serviceCount == nil ? @"" : _storeDetailForm.serviceCount];
            cell.promotionLabel.text = [NSString stringWithFormat:@"促销 %@",_storeDetailForm.promotionCount == nil ? @"" : _storeDetailForm.promotionCount];
            cell.setMenuLabel.text = [NSString stringWithFormat:@"套餐 %@",_storeDetailForm.setmenuCount == nil ? @"" : _storeDetailForm.setmenuCount];
            cell.goodsLabel.text = [NSString stringWithFormat:@"商品 %@",_storeDetailForm.goodsCount == nil ? @"" : _storeDetailForm.goodsCount];
            __weak typeof(self) weakSelf = self;
            CZJButtonClickHandler buttonClickHandler = ^(id data)
            {
                UIButton* btn = (UIButton*)data;
                _touchedType = btn.tag;
                _bigTypeId = [NSString stringWithFormat:@"%ld",_touchedType * 10000];
                _typeId = _bigTypeId;
                [_nativeServiceAndGoodsArray removeAllObjects];
                [_serviceAndGoodsArray removeAllObjects];
                
                weakSelf.page = 1;
                [weakSelf getStoreGoodsAndServiceDataFromServer];
                [weakSelf.topView storeDetailConfiMenuWithSelectRow:_touchedType];
                
                [weakSelf.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_bannerOneArray.count + 4] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
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
    {//活动
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
        NSMutableArray* _imageArray = [NSMutableArray array];
        for (CZJStoreDetailActivityForm* tmp in _activityArray) {
            NSString* imgStr = [NSString stringWithFormat:@"%@",tmp.img];
            [_imageArray addObject:imgStr];
        }
        __weak typeof(self) weak = self;
        cell.buttonClick = ^(id data)
        {
            NSInteger inde = [data integerValue];
            NSString* composeUrl = [NSString stringWithFormat:@"%@?storeId=%@&storeName=%@",((CZJStoreDetailActivityForm*)_activityArray[inde]).url,self.storeId,_storeDetailForm.storeName];
            NSString* encodedString = [composeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [weak showWebViewWithURL: encodedString];
            
        };
        [cell initBannerWithImg:_imageArray];
        return cell;
    }
    if (indexPath.section > 2 && indexPath.section < _bannerOneArray.count + 3)
    {//广告
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
        CZJStoreDetailBannerForm* tmpStoreDetailBannerForm = _bannerOneArray[indexPath.section - 3];
        
        __weak typeof(self) weak = self;
        cell.buttonClick = ^(id data)
        {
            NSString* storeItemPid = tmpStoreDetailBannerForm.storeItemPid;
            CZJDetailViewController* detaiVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDGoodsDetailVC];
            detaiVC.storeItemPid = storeItemPid;
            detaiVC.promotionPrice = @"";
            detaiVC.promotionType = CZJGoodsPromotionTypeGeneral;
            [weak.navigationController pushViewController:detaiVC animated:YES];
        };
        
        
        NSString* imgStr = [NSString stringWithFormat:@"%@%@",tmpStoreDetailBannerForm.itemImg, SUOLUE_PIC_400];
        [cell initBannerWithImg:@[imgStr]];
        return cell;
    }
    if (_bannerOneArray.count + 3 == indexPath.section)
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
                [cell initGoodsRecommendWithDatas:_recommendArray[indexPath.row - 1] andPromotionType:CZJGoodsPromotionTypeBaoKuan];
            }
            return cell;
        }
    }
    if (_bannerOneArray.count + 4 == indexPath.section)
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
        {//下拉菜单栏
            menuCell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailMenuCell" forIndexPath:indexPath];
            ((CATextLayer*)menuCell.titles[0]).string = [self.topView getMenuTitleByCurrentMenuIndex];
            __weak typeof(self) weakSelf = self;

            CZJButtonClickHandler buttonClickHandler = ^(id data)
            {
                NSString* tagStr = (NSString*)data;
                _touchedType = [tagStr integerValue];
                
                if (_touchedType != 0)
                {
                    _sortType = [NSString stringWithFormat:@"%ld",_touchedType];
                }
                
                [_nativeServiceAndGoodsArray removeAllObjects];
                [_serviceAndGoodsArray removeAllObjects];
                
                weakSelf.page = 1;
                [weakSelf.topView touchMXPullDownMenuAtMenuIndex:_touchedType];
                [weakSelf getStoreGoodsAndServiceDataFromServer];
                [weakSelf.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_bannerOneArray.count + 4] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            };
            menuCell.buttonClick = buttonClickHandler;
            return menuCell;
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
        return 55;
    }
    if (2 == indexPath.section)
    {
        return 150;
    }
    if (indexPath.section > 2 && indexPath.section < _bannerOneArray.count + 3)
    {
        return 150;
    }
    if (_bannerOneArray.count + 3 == indexPath.section)
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
    if (_bannerOneArray.count + 4 == indexPath.section)
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
        receiveCouponsController.storeId = _storeDetailForm.storeId;
        receiveCouponsController.popWindowInitialRect = self.popWindowInitialRect;
        [CZJUtils showMyWindowOnTarget:self withPopVc:receiveCouponsController];
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
        (1 == section && _couponsArray.count == 0) ||
        (2 == section && _activityArray.count == 0) ||
        (3 == section && _bannerOneArray.count == 0) ||
        (_bannerOneArray.count + 3 == section && _recommendArray.count == 0)
        )
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

    CGRect frame = [self.myTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:_bannerOneArray.count + 4]];
//    DLog(@"contentOffsetY:%f, frameY:%f",contentOffsetY,frame.origin.y);
    if ((contentOffsetY < frame.origin.y - 64 && isDraggingDown)||
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
            NSArray * arr = @[@{@"消息" : @"prodetail_icon_msg"},
                              @{@"首页":@"prodetail_icon_home"},
                              @{@"分享" :@"prodetail_icon_share"},
                              @{@"我的关注" :@"all_pop_attention"},
                              @{@"浏览记录" :@"all_pop_record"}
                              ];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 150 - 14, StatusBar_HEIGHT + 78, 150, 250);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr andType:CZJNIDropDownTypeNormal];
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
    [self tapBackground:nil];
    if ([btnStr isEqualToString:@"消息"])
    {
        DLog(@"消息");
        CZJMyMessageCenterController* messageCenterVC = (CZJMyMessageCenterController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"MessageCenterSBID"];
        [self.navigationController pushViewController:messageCenterVC animated:YES];
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if ([btnStr isEqualToString:@"我的关注"])
    {
        CZJMyInfoAttentionController* attentionVC = (CZJMyInfoAttentionController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"myAttentionSBID"];
        [self.navigationController pushViewController:attentionVC animated:YES];
    }
    if ([btnStr isEqualToString:@"浏览记录"])
    {
        CZJMyInfoRecordController* recordVC = (CZJMyInfoRecordController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"myScanRecordSBID"];
        [self.navigationController pushViewController:recordVC animated:YES];
    }
    if ([btnStr isEqualToString:@"分享"])
    {
        DLog(@"分享");
        NSString* shareUrl = [NSString stringWithFormat:@"%@%@?storeId=%@",kCZJServerAddr,kCZJStoreShare,self.storeId];
        NSString* desc = @"我在车之健发现一个不错的门店，赶快去看看吧~";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [CZJUtils downloadImageWithURL:_imgsArray.firstObject andFileName:@"storeShare_icon.png" withSuccess:^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSData* imageData =[NSData dataWithContentsOfFile:[DocumentsDirectory stringByAppendingPathComponent:@"storeShare_icon.png"]];
            [[ShareMessage shareMessage] showPanel:self.view
                                              type:1
                                             title:_storeDetailForm.storeName
                                              body:desc
                                              link:shareUrl
                                             image:imageData];
        } andFail:^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSData* imageData =[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
            [[ShareMessage shareMessage] showPanel:self.view
                                              type:1
                                             title:_storeDetailForm.storeName
                                              body:desc
                                              link:shareUrl
                                             image:imageData];
        }];
        
        
        
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
    if ([firstName isEqualToString:@"全部"])
    {
        _bigTypeId = @"0";
    }
    if ([firstName isEqualToString:@"服务"])
    {
        _bigTypeId = @"10000";
        _typeId = secondName;
    }
    if ([firstName isEqualToString:@"商品"])
    {
        _bigTypeId = @"20000";
        _typeId = secondName;
    }
    
    [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_bannerOneArray.count + 4] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [_nativeServiceAndGoodsArray removeAllObjects];
    [_serviceAndGoodsArray removeAllObjects];
    self.page = 1;
    [self getStoreGoodsAndServiceDataFromServer];
}
- (void)pullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectCityName:(NSString*)cityName
{
    DLog(@"%@",cityName);
    if ([cityName isEqualToString:@"销量"])
    {
        _sortType = @"1";
        [menuCell updateCellTitleColor:1];
    }
    if ([cityName isEqualToString:@"最新"])
    {
        _sortType = @"2";
        [menuCell updateCellTitleColor:2];
    }
    if ([cityName isEqualToString:@"价格"])
    {
        [menuCell updateCellTitleColor:3];
        if ([_sortType isEqualToString:@"3"])
        {
            _sortType = @"4";
        }
        else if ([_sortType isEqualToString:@"4"])
        {
            _sortType = @"3";
        }
        else
        {
            _sortType = @"3";
        }
    }
    if ([cityName isEqualToString:@"全部"])
    {
        _bigTypeId = @"0";
    }
    if ([cityName isEqualToString:@"套餐"])
    {
        _bigTypeId = @"30000";
    }
    if ([cityName isEqualToString:@"促销"])
    {
        _bigTypeId = @"40000";
    }
    
    [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_bannerOneArray.count + 4] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [_nativeServiceAndGoodsArray removeAllObjects];
    [_serviceAndGoodsArray removeAllObjects];
    self.page = 1;
    [self getStoreGoodsAndServiceDataFromServer];
}


#pragma mark CZJGoodsRecommendCellDelegate
- (void)clickRecommendCellWithID:(GoodsRecommendForm*)recoForm andPromotionType:(CZJGoodsPromotionType)promotionType;
{
    _touchedStoreItemPid = recoForm.storeItemPid;

    CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"goodsDetailSBID"];
    detailVC.storeItemPid = _touchedStoreItemPid;
    detailVC.detaiViewType = CZJDetailTypeGoods;
    detailVC.promotionType = promotionType;
    NSString* itemType = @"";
    switch (promotionType) {
        case CZJGoodsPromotionTypeBaoKuan:
            for (CZJStoreDetailGoodsAndServiceForm* mForm in _nativeRecommendArray)
            {
                if ([_touchedStoreItemPid isEqualToString:mForm.storeItemPid])
                {
                    itemType = mForm.itemType;
                    detailVC.promotionPrice = mForm.currentPrice;
                    break;
                }
            }
            break;
        case CZJGoodsPromotionTypeGeneral:
            for (CZJStoreDetailGoodsAndServiceForm* mForm in _nativeServiceAndGoodsArray)
            {
                if ([_touchedStoreItemPid isEqualToString:mForm.storeItemPid])
                {
                    itemType = mForm.itemType;
                    detailVC.promotionPrice = mForm.currentPrice;
                    break;
                }
            }
            break;
            
        default:
            break;
    }
    
    
    detailVC.detaiViewType = [itemType intValue];
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark MKMapViewDelegate -user location定位变化
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    self.nowCoords = [userLocation coordinate];
}


#pragma mark- Actions
- (IBAction)contactServiceAction:(id)sender
{
    if ([CZJUtils isLoginIn:self andNaviBar:nil])
    {
        CZJChatViewController *chatController = [[CZJChatViewController alloc] initWithConversationChatter: _storeDetailForm.contactAccount conversationType:EMConversationTypeChat];
        chatController.storeName = _storeDetailForm.storeName;
        chatController.storeId = _storeDetailForm.storeId;
        chatController.storeImg = _imgsArray.firstObject;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}


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
        if (IOS_VERSION < 6)
        {//ios6 调用goole网页地图
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

    if ([btnTitle isEqualToString:@"高德地图"])
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"iosamap://navi?sourceApplication=broker&backScheme=openbroker2&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2",_storeDetailForm.storeAddr,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude]];
        [[UIApplication sharedApplication] openURL:url];
        
    }else if ([btnTitle isEqualToString:@"百度地图"])
    {
        double bdNowLat,bdNowLon;
        bd_encrypt(self.nowCoords.latitude, self.nowCoords.longitude, &bdNowLat, &bdNowLon);
        
        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=%.8f,%.8f&&mode=driving",bdNowLat,bdNowLon,self.naviCoordsBd.latitude,self.naviCoordsBd.longitude];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }else if ([btnTitle isEqualToString:@"显示路线"]){}
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

- (void)showWebViewWithURL:(NSString*)url
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = url;
    [self.navigationController pushViewController:webView animated:YES];
}

@end
