//
//  CZJDetailInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceListController.h"
#import "CZJBaseDataManager.h"
#import "CZJStoreForm.h"
#import "MXPullDownMenu.h"
#import "CZJStoreCell.h"
#import "CZJStoreServiceCell.h"
#import "CCLocationManager.h"
#import "CZJServiceFilterController.h"
#import "CZJDetailViewController.h"
#import "CZJStoreDetailController.h"

@interface CZJServiceListController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIGestureRecognizerDelegate,
    MXPullDownMenuDelegate,
    CZJNaviagtionBarViewDelegate,
    CZJFilterControllerDelegate
>
{
    NSMutableArray* _serviceListArys;
    CZJHomeGetDataFromServerType _getdataType;
    
    CGPoint pullDownMenuOriginPoint;
    CGPoint naviBraviewOriginPoint;
    
    BOOL _isAnimate;
    BOOL _isOutOfScreen;
    BOOL _isTouch;
    float lastY;
    float lastContentOffsetY;
    
    MXPullDownMenu* _pullDownMenu;
    
    MJRefreshAutoNormalFooter* refreshFooter;
    MJRefreshNormalHeader* refreshHeader;
    
    
    NSString* cityID;           //城市ID
    NSString* sortType;         //排序
    NSString* modelId;          //车型
    NSString* goHouseFlag;           //上门服务
    NSString* goStoreFlag;           //到店服务
    
}
@property (strong, nonatomic) UITableView *serviceTableView;
@property (weak, nonatomic) IBOutlet UIView *refreshLocationBarView;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


@property (assign, nonatomic)NSInteger page;

@end

@implementation CZJServiceListController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [CZJUtils hideSearchBarViewForTarget:self];
    [self initData];
    [self initTableViewAndPullDownMenu];
    [self initRefreshLocationBarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [self.naviBarView refreshShopBadgeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog();
    pullDownMenuOriginPoint = _pullDownMenu.frame.origin;
    naviBraviewOriginPoint = self.naviBarView.frame.origin;
    if (isFirstIn) {
        CGRect currentFrame = _refreshLocationBarView.frame;
        _refreshLocationBarView.frame = CGRectMake(30, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
        _locationButton.tag = CZJViewMoveOrientationLeft;
        isFirstIn = NO;
    }
    
    [_pullDownMenu registNotification];
}

- (void)viewDidLayoutSubviews
{
    DLog();
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [_pullDownMenu removeNotificationObserve];
}

- (void)initData
{
    
    isFirstIn = YES;
    _serviceListArys = [NSMutableArray array];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    
    //参数初始化
    cityID = CZJBaseDataInstance.userInfoForm.cityId;
    sortType = @"0";
    modelId = @"";
    goStoreFlag = @"0";
    goHouseFlag = @"0";
    self.page = 1;
}

- (void)initTableViewAndPullDownMenu
{
    //门店服务列表
    self.serviceTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110) style:UITableViewStylePlain];
    self.serviceTableView.dataSource = self;
    self.serviceTableView.delegate = self;
    self.serviceTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.serviceTableView];
    UINib *nib2=[UINib nibWithNibName:@"CZJStoreServiceCell" bundle:nil];
    [self.serviceTableView registerNib:nib2 forCellReuseIdentifier:@"CZJStoreServiceCell"];
    
    //导航栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeBack];
    self.naviBarView.detailType = CZJDetailTypeService;
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"默认排序", @"距离最近", @"价格最低", @"价格最高", @"评论最多", @"销量最高"];
    NSArray* storeTypes = @[@"筛选"];
    if ([CZJBaseDataInstance storeForm].provinceForms &&
        [CZJBaseDataInstance storeForm].provinceForms.count > 0) {
        NSArray* menuArray = @[[CZJBaseDataInstance storeForm].provinceForms, sortTypes,storeTypes];
        _pullDownMenu  = [[MXPullDownMenu alloc]initWithArray:menuArray AndType:CZJMXPullDownMenuTypeService WithFrame:CGRectMake(0, 200, PJ_SCREEN_WIDTH, 46)];
        _pullDownMenu.delegate = self;
        _pullDownMenu.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46);
        [self.view addSubview:_pullDownMenu];
    }
}


- (void)getStoreServiceListDataFromServer
{
    NSDictionary* storePostParams = @{@"modelId" :modelId, @"typeId" :self.typeId, @"sortType" :sortType, @"q" :self.searchStr ? self.searchStr : @"", @"goHouseFlag":goHouseFlag ,@"goStoreFlag":goStoreFlag, @"page" : [NSString stringWithFormat:@"%ld",(long)self.page]};
    [[MBProgressHUD showHUDAddedTo:self.view animated:YES] setLabelText:@"刷新数据"];
    CZJSuccessBlock successBlock = ^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (_serviceListArys.count == 0)
        {
            refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
                _getdataType = CZJHomeGetDataFromServerTypeTwo;
                self.page++;
                [self getStoreServiceListDataFromServer];;
            }];
            self.serviceTableView.footer = refreshFooter;
        }
        
        [self.serviceTableView.header endRefreshing];
        [self.serviceTableView.footer endRefreshing];
        
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (_getdataType == CZJHomeGetDataFromServerTypeTwo)
        {
            NSArray* tmpAry = [CZJStoreServiceForm objectArrayWithKeyValuesArray:dict];
            if (tmpAry.count > 0)
            {
                [_serviceListArys addObjectsFromArray:tmpAry];
                [self.serviceTableView reloadData];
            }
            else
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        else
        {
            _serviceListArys = [[CZJStoreServiceForm objectArrayWithKeyValuesArray:dict] mutableCopy];
            [self.serviceTableView reloadData];
        }
    };
    
    [CZJBaseDataInstance generalPost:storePostParams success:successBlock andServerAPI:kCZJServerAPIGetServiceList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJStoreServiceCell* cell  = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreServiceCell"];
    CZJStoreServiceForm* storeForm = _serviceListArys[indexPath.row];
    
    [cell.serviceImg sd_setImageWithURL:[NSURL URLWithString:storeForm.itemImg] placeholderImage:DefaultPlaceHolderImage];
    cell.storeName.text = storeForm.storeName;
    cell.distance.text = storeForm.distance;
    cell.serviceItemName.text = storeForm.itemName;
    NSString* currentPrice = [NSString stringWithFormat:@"￥%@",storeForm.currentPrice];
    cell.currentPrice.text = currentPrice;
    cell.priceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:currentPrice AndFontSize:15].width + 5;
    NSString* orginPrice = [NSString stringWithFormat:@"￥%@",storeForm.originalPrice];
    [cell.originPrice setAttributedText:[CZJUtils stringWithDeleteLine:orginPrice]];
    cell.originPriceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:orginPrice AndFontSize:12].width + 5;
    cell.goodRate.text = storeForm.goodEvalRate;
    cell.purchasedCount.text = storeForm.purchaseCount;
    cell.purchasedCountWidth.constant = [CZJUtils calculateTitleSizeWithString:storeForm.purchaseCount AndFontSize:12].width + 5;
    cell.serviceTypeImg.hidden = !storeForm.goStoreFlag;
    cell.separatorInset = HiddenCellSeparator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _serviceListArys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 126;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    self.serviceTableView.tintColor = RGBA(230, 230, 230, 1.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJStoreServiceForm* serviceForm = _serviceListArys[indexPath.row];
    _choosedStoreitemPid = serviceForm.storeItemPid;
    [self performSegueWithIdentifier:@"segueToServiceDetail" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    
    //判断是否是上拉（isDraggingDown = false）还是下滑（isDraggingDown = true）
    bool isDraggingDown = (lastContentOffsetY - contentOffsetY) > 0 ;
    lastContentOffsetY = contentOffsetY;
    if (UIGestureRecognizerStateChanged == scrollView.panGestureRecognizer.state)
    {
        if (isDraggingDown &&
            self.naviBarView.frame.origin.y < 0 &&
            _isTouch)
        {
            _isTouch = NO;
            DLog(@"下拉");
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.naviBarView.frame = CGRectMake(0, 20, PJ_SCREEN_WIDTH, 44);
                _pullDownMenu.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46);
                self.serviceTableView.frame = CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110);
            } completion:nil];
        }
        else if (!isDraggingDown &&
                 _pullDownMenu.frame.origin.y > 0 &&
                 _isTouch)
        {
            _isTouch = NO;
            DLog(@"上拉");
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.naviBarView.frame = CGRectMake(0, -110, PJ_SCREEN_WIDTH, 44);
                _pullDownMenu.frame = CGRectMake(0, -46, PJ_SCREEN_WIDTH, 46);
                self.serviceTableView.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
            } completion:nil];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isTouch = YES;
    DLog();
}

#pragma mark- 定位功能区
- (void)initRefreshLocationBarView
{
    [self.view.window addSubview:_refreshLocationBarView];
    [self.view.window bringSubviewToFront:_refreshLocationBarView];
    _locationButton.tag = CZJViewMoveOrientationLeft;
    [_locationButton addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self btnTouched:nil];
}

- (void)btnTouched:(id)sender
{
    if (CZJViewMoveOrientationLeft == _locationButton.tag)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveLocationBarViewOut) object:nil];
    }
    [self storeStartLocation];
}


- (void)storeStartLocation
{
    if (![[CCLocationManager shareLocation] isLocationEnable]) {
        self.locationNameLabel.text = @"亲，未开启定位功能哦~";
        return;
    }
    [self startSpin];
    [[CCLocationManager shareLocation] getAddress:^(NSString *addressString) {
        [self stopSpin];
        self.locationNameLabel.text = addressString;
        if (_locationButton.tag == CZJViewMoveOrientationRight)
        {
            [self performSelector:@selector(moveLocationBarViewIn) withObject:nil afterDelay:0.5];
        }
        if (_locationButton.tag == CZJViewMoveOrientationLeft)
        {
            [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:2.0];
        }
        
    }];
    
    [[MBProgressHUD showHUDAddedTo:self.view animated:YES] setLabelText:@"正在定位"];
    [[CCLocationManager shareLocation] getCity:^(NSString *addressString) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:addressString];
        _getdataType = CZJHomeGetDataFromServerTypeOne;
        [self getStoreServiceListDataFromServer];
        if (nil != addressString)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJChangeCurCityName object:self userInfo:@{@"cityname" : addressString}];
        }
        
    }];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         _locationButton.transform = CGAffineTransformRotate(_locationButton.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (_isAnimate) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!_isAnimate) {
        _isAnimate = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    _isAnimate = NO;
}

- (void)moveLocationBarViewOut
{
    [self moveLocationBarViewWithOrient:CZJViewMoveOrientationRight];
}

- (void)moveLocationBarViewIn
{
    [self moveLocationBarViewWithOrient:CZJViewMoveOrientationLeft];
}

- (void)moveLocationBarViewWithOrient:(CZJViewMoveOrientation)orient
{
    CGRect currentFrame = _refreshLocationBarView.frame;
    CGFloat originX;
    switch (orient) {
        case CZJViewMoveOrientationLeft:
            originX = 30;
            [_locationButton setTag:CZJViewMoveOrientationLeft];
            break;
        case CZJViewMoveOrientationRight:
            [_locationButton setTag:CZJViewMoveOrientationRight];
            originX = PJ_SCREEN_WIDTH - 40;
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.5 animations:^{
        _refreshLocationBarView.frame = CGRectMake(originX, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
    } completion:^(BOOL finished) {
        if (finished && CZJViewMoveOrientationLeft == orient)
        {
            [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:4.0];
        }
    }];
}


#pragma mark- CZJNavigationBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    UIButton* _btn = (UIButton*)sender;
    DLog(@"bar touched");
    if (_btn.tag == CZJButtonTypeNaviBarBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -  MXPullDownMenuDelegate
- (void)PullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row
{
    if (1 == column)
    {
    }
    if (2 == column)
    {
    }
    
    DLog(@"%ld, %ld",column, row);
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    sortType = [NSString stringWithFormat:@"%ld",row];
    [self getStoreServiceListDataFromServer];
}


- (void)pullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectCityName:(NSString *)cityName
{
    //根据城市名称
    cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:cityName];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
}

- (void)pullDownMenuDidSelectFiliterButton
{
    [self actionBtn];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)actionBtn{
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    [window makeKeyAndVisible];
    
    CZJServiceFilterController *serviceFilterController = [[CZJServiceFilterController alloc] init];
    serviceFilterController.delegate = self;
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:serviceFilterController];
    serviceFilterController.view.frame = window.bounds;
    window.rootViewController = nav;
    self.window = window;
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    //点击隐藏手势
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [view addGestureRecognizer:tap];
    //侧滑隐藏手势
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addSubview:view];
    self.upView = view;
    self.upView.alpha = 0.0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.window.frame = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        self.upView.alpha = 1.0;
    } completion:nil];
    
    
    __weak typeof(self) weak = self;
    [serviceFilterController setCancleBarItemHandle:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weak.window.frame = CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
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

- (void)tapAction{
    [UIView animateWithDuration:0.5 animations:^{
        self.window.frame = CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        self.upView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.upView removeFromSuperview];
            [self.window resignKeyWindow];
            self.window  = nil;
            self.upView = nil;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    [self tapAction];
}

#pragma mark -CZJServiceFilterDelegate
- (void)chooseFilterOK:(id)data
{
    //更新参数，重新请求数据刷新
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    modelId = [USER_DEFAULT valueForKeyPath:kUserDefaultChoosedCarModelID];
    goHouseFlag = @"";
    goStoreFlag = @"";
    self.typeId = [USER_DEFAULT valueForKey:kUserDefaultServiceTypeID];
    [self getStoreServiceListDataFromServer];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToServiceDetail"])
    {
        CZJDetailViewController* serviceDetailCon = segue.destinationViewController;
        serviceDetailCon.storeItemPid = _choosedStoreitemPid;
        serviceDetailCon.detaiViewType = CZJDetailTypeService;
        serviceDetailCon.promotionPrice = @"0";
        serviceDetailCon.promotionType = CZJGoodsPromotionTypeGeneral;
    }
}


@end
